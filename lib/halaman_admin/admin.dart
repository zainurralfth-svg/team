import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import 'halaman_detail_pesanan.dart'; 
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; 
import 'halaman_produk.dart';
import 'riwayat_pesanan.dart'; 
import 'halaman_laporan.dart';
import 'halaman_pengguna.dart';
import 'halaman_profil_admin.dart';
import '../Widget/custom_navbar.dart';
import '../Widget/order_card.dart';
import '../Widget/sheet_tambah_pesanan.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  List<dynamic> _listPesanan = [];
  bool _isLoading = true;
  String _namaAdmin = "Sari Andini"; 
  String _currentUserId = "1";
  int _pendapatanBulanIni = 0;
  int _jumlahPesananHariIni = 0;

  @override
  void initState() {
    super.initState();
    _loadDataDashboard();
  }

  Future<void> _loadDataDashboard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('id_user') ?? "1";

      final profilData = await ApiService.getProfil(_currentUserId);
      final dataPesanan = await ApiService.getPesanan();

      if (mounted) {
        // 1. Hitung pendapatan dari SEMUA pesanan khusus yang SELESAI
        int hitungPendapatan = dataPesanan
            .where((p) => p['status_pesanan']?.toString().toUpperCase() == 'SELESAI')
            .fold(0, (sum, item) => sum + (int.tryParse(item['total_harga'].toString()) ?? 0));

        // 2. FILTER PESANAN: Sembunyikan yang SELESAI dan DIBATALKAN agar pindah ke Riwayat
        List<dynamic> pesananAktif = dataPesanan.where((item) {
          String status = item['status_pesanan']?.toString().toUpperCase() ?? '';
          return status != 'SELESAI' && status != 'DIBATALKAN';
        }).toList();

        setState(() {
          _namaAdmin = profilData['nama'] ?? "Admin UMKM";
          _listPesanan = pesananAktif; // Beranda HANYA nampilin pesanan aktif
          _jumlahPesananHariIni = pesananAktif.length; 
          _pendapatanBulanIni = hitungPendapatan; 
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal load data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  Future<void> _ubahStatusPesanan(String idPesanan, String statusBaru) async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.updateStatusPesanan(idPesanan, statusBaru);
      if (response['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status berhasil diubah ke $statusBaru ✓'), backgroundColor: AppColors.success));
        _loadDataDashboard(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengubah status: ${response['pesan']}'), backgroundColor: AppColors.error));
      }
    } catch (e) {
      debugPrint("Error update status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sistem Error: $e'), backgroundColor: AppColors.error, duration: const Duration(seconds: 4))
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama,
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PuddingKu', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('Panel Admin UMKM', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textBrown, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfilAdmin())),
                    child: Container(
                      width: 50, 
                      height: 50, 
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, 
                        image: DecorationImage(image: AssetImage('assets/images/profil admin.png'), fit: BoxFit.cover), 
                        color: AppColors.textWhite
                      )
                    ),
                  ),
                ],
              ),
            ),

            // === DASHBOARD & LIST PESANAN ===
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadDataDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KARTU ORANYE
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(32)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selamat pagi, Admin', style: TextStyle(color: AppColors.textWhite, fontSize: 12, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(_namaAdmin, style: const TextStyle(color: AppColors.textWhite, fontSize: 22, fontFamily: 'Sora', fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()), style: const TextStyle(color: AppColors.textWhite, fontSize: 11, fontFamily: 'Plus Jakarta Sans')),
                                  const SizedBox(height: 15),
                                  
                                  // === INI PERUBAHANNYA: Menggunakan Wrap agar tidak overflow ===
                                  Wrap(
                                    spacing: 8, // Jarak horizontal
                                    runSpacing: 8, // Jarak vertikal kalau turun baris
                                    children: [
                                      _buildGlassBadge('$_jumlahPesananHariIni Pesanan Baru'),
                                      _buildGlassBadge('+12% Minggu Ini'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(5)), child: Text(formatRupiah(_pendapatanBulanIni), style: const TextStyle(color: AppColors.textWhite, fontSize: 11, fontWeight: FontWeight.bold))),
                                  const SizedBox(height: 4),
                                  const Text('Pendapatan bulan ini', style: TextStyle(color: AppColors.textWhite, fontSize: 10)),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                    child: Column(children: [Text('$_jumlahPesananHariIni', style: const TextStyle(color: AppColors.textWhite, fontSize: 26, fontFamily: 'Sora', fontWeight: FontWeight.w800)), const Text('Pesanan\nHari Ini', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textWhite, fontSize: 10))]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // === TOMBOL TAMBAH PESANAN ===
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const SheetTambahPesanan(),
                          ).then((value) {
                            _loadDataDashboard(); 
                          });
                        },
                        child: Container(
                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
                          child: Row(
                            children: const [
                              Text('+', style: TextStyle(color: AppColors.textWhite, fontSize: 50, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
                              SizedBox(width: 15),
                              Text('Tambah Pesanan', style: TextStyle(color: AppColors.textWhite, fontSize: 32, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text('Daftar Pesanan', style: TextStyle(color: AppColors.textBrown, fontSize: 30, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      // === DAFTAR PESANAN ===
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          : _listPesanan.isEmpty
                          ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Belum ada pesanan aktif.", style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold))))
                          : ListView.builder(
                              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _listPesanan.length,
                              itemBuilder: (context, index) {
                                final item = _listPesanan[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HalamanDetailPesanan(dataPesanan: item),
                                      ),
                                    );
                                  },
                                  child: OrderCard(
                                    id: item['id_pesanan'].toString(),
                                    nama: item['nama_pemesan'] ?? 'Unknown',
                                    ringkasan: item['ringkasan_pesanan'] ?? 'Detail tidak tersedia',
                                    harga: formatRupiah(item['total_harga']),
                                    status: item['status_pesanan'] ?? 'PROSES',
                                    waktu: item['tanggal_pesanan'] ?? '15 menit lalu',
                                    onStatusChanged: (newStatus) {
                                      _ubahStatusPesanan(item['id_pesanan'].toString(), newStatus);
                                    },
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 30), 
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // === BOTTOM NAVIGATION BAR ===
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 2, 
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProduk()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat())); 
          if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanPengguna()));
        },
      ),
    );
  }

  Widget _buildGlassBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: AppColors.textWhite, fontSize: 10, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold)),
    );
  }
}