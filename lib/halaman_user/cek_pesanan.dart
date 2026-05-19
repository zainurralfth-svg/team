import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Core/Colour.dart'; 
import '../Backend/api_service.dart'; 
import 'profil_pengguna.dart';
import '../Widget/custom_user_navbar.dart'; // <-- NAVBAR CUSTOM UDAH DIIMPORT

class CekPesananPage extends StatefulWidget {
  const CekPesananPage({super.key});

  @override
  State<CekPesananPage> createState() => _CekPesananPageState();
}

class _CekPesananPageState extends State<CekPesananPage> {
  bool _isLoading = true;
  String _currentUserId = "";

  List<dynamic> _pesananAktif = [];
  List<dynamic> _pesananRiwayat = [];

  @override
  void initState() {
    super.initState();
    _fetchPesananUser();
  }

  // Format Rupiah Helper
  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // =========================================================
  // MESIN WAKTU: Bikin tanggal jadi "5 menit lalu", dll
  // =========================================================
  String _formatWaktu(Map<String, dynamic> item) {
    String? rawTime = item['tanggal_pesanan'] ?? item['created_at'] ?? item['tanggal'] ?? item['waktu'];
    if (rawTime == null || rawTime.isEmpty) return 'Baru saja';
    try {
      DateTime orderTime = DateTime.parse(rawTime);
      Duration diff = DateTime.now().difference(orderTime);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (e) {
      return rawTime.length > 15 ? rawTime.substring(0, 15) : rawTime;
    }
  }

  // Tarik data pesanan KHUSUS akun ini aja
  Future<void> _fetchPesananUser() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('id_user') ?? ""; 

      if (_currentUserId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final semuaPesanan = await ApiService.getPesanan();

      // 1. Filter cuma pesanan milik user ini
      final pesananSaya = semuaPesanan.where((p) => p['id_user'].toString() == _currentUserId).toList();

      List<dynamic> aktif = [];
      List<dynamic> riwayat = [];

      // 2. Pisahkan ke Aktif dan Riwayat
      for (var p in pesananSaya) {
        String status = p['status_pesanan']?.toString().toUpperCase() ?? 'MENUNGGU';
        if (status == 'SELESAI' || status == 'DIBATALKAN') {
          riwayat.add(p);
        } else {
          aktif.add(p);
        }
      }

      setState(() {
        _pesananAktif = aktif;
        _pesananRiwayat = riwayat;
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pesanan: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // Fungsi Batalkan Pesanan oleh User
  Future<void> _batalkanPesanan(String idPesanan) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin nih mau batalin pesanan puddingnya? 🥺'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nggak Jadi', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              
              // Tembak API update status jadi DIBATALKAN
              final response = await ApiService.updateStatusPesanan(idPesanan, 'DIBATALKAN');
              
              if (response['status'] == 'sukses') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pesanan berhasil dibatalkan.'), backgroundColor: AppColors.success),
                );
                _fetchPesananUser(); // Refresh data
              } else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: ${response['pesan']}'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tab: Aktif & Riwayat
      child: Scaffold(
        backgroundColor: AppColors.bgUtama,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 70,
          iconTheme: const IconThemeData(color: AppColors.textWhite),
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontFamily: 'Oleo Script', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            indicatorWeight: 4,
            labelColor: AppColors.textWhite,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Signika Negative'),
            tabs: [
              Tab(text: 'Saat Ini'),
              Tab(text: 'Riwayat Pesanan'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : TabBarView(
                children: [
                  // TAB 1: PESANAN AKTIF
                  _buildListPesanan(_pesananAktif, isRiwayat: false),
                  
                  // TAB 2: RIWAYAT PESANAN
                  _buildListPesanan(_pesananRiwayat, isRiwayat: true),
                ],
              ),

        // ==============================================================
        // FOOTER SUDAH PAKAI CUSTOM NAVBAR
        // ==============================================================
        bottomNavigationBar: CustomUserNavbar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              // Biarin kosong
            } else if (index == 1) {
              // UBAH JADI INI BIAR GAK ERROR POP!
              Navigator.pushReplacementNamed(context, '/menu'); 
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProfil()));
            }
          },
        ),
      ),
    );
  }

  // WIDGET BUILDER UNTUK LIST
  Widget _buildListPesanan(List<dynamic> listData, {required bool isRiwayat}) {
    if (listData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isRiwayat ? Icons.history : Icons.shopping_bag_outlined, size: 60, color: AppColors.textHint.withOpacity(0.5)),
            const SizedBox(height: 10),
            Text(
              isRiwayat ? 'Belum ada riwayat pesanan.' : 'Belum ada pesanan aktif nih.',
              style: const TextStyle(color: AppColors.textHint, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchPesananUser,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: listData.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(listData[index], isRiwayat);
        },
      ),
    );
  }

  // WIDGET KARTU PESANAN
  Widget _buildOrderCard(Map<String, dynamic> dataPesanan, bool isRiwayat) {
    String idPesanan = dataPesanan['id_pesanan']?.toString() ?? '-';
    
    // Perbaikan biar nggak kosong melompong
    String statusRaw = dataPesanan['status_pesanan']?.toString().toUpperCase() ?? '';
    String status = statusRaw.isEmpty ? 'MENUNGGU' : statusRaw; 
    
    String totalHarga = formatRupiah(dataPesanan['total_harga']);
    String waktuTampil = _formatWaktu(dataPesanan); // <-- Panggil mesin waktu di sini!
    
    List<String> listProduk = [];
    if (dataPesanan['ringkasan_pesanan'] != null) {
      listProduk = dataPesanan['ringkasan_pesanan'].toString().split(RegExp(r',\s*'));
    }

    // Tentukan warna status
    Color warnaStatus = AppColors.primary; // Orange untuk MENUNGGU
    if (status == 'PROSES') warnaStatus = AppColors.info; // Biru
    if (status == 'SELESAI') warnaStatus = AppColors.success; // Hijau
    if (status == 'DIBATALKAN') warnaStatus = AppColors.error; // Merah

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu: ID & Tanggal/Waktu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#$idPesanan', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(waktuTampil, style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.bold)), // Tampil waktu pintar
            ],
          ),
          const Divider(color: AppColors.bgInput, thickness: 1, height: 25),
          
          // List Item
          ...listProduk.map((produk) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fastfood_rounded, size: 16, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(produk, style: const TextStyle(color: AppColors.textBrown, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }),
          
          const Divider(color: AppColors.bgInput, height: 20),

          // Footer Kartu: Total Harga & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Bayar', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                  Text(totalHarga, style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Status', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: warnaStatus, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(5)),
                        child: Text(status, style: const TextStyle(color: AppColors.textDark, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // LOGIKA TOMBOL BATAL (ALA SHOPEE)
          if (!isRiwayat && status == 'MENUNGGU') ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _batalkanPesanan(idPesanan),
                child: const Text('Batalkan Pesanan', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else if (!isRiwayat && status == 'PROSES') ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Text(
                'Pesanan sedang disiapkan, tidak bisa dibatalkan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ]
        ],
      ),
    );
  }
}