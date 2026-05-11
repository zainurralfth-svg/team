import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
import '../Backend/api_service.dart';
import '../Core/Colour.dart';
import 'halaman_produk.dart';
import 'halaman_riwayat.dart';
import 'halaman_laporan.dart';
import 'halaman_pengguna.dart';
import 'halaman_pesanan.dart';
import 'halaman_profil_admin.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  // === VARIABEL BACKEND ===
  List<dynamic> _listPesanan = [];
  bool _isLoading = true;
  String _namaAdmin = "Sari Andini"; // Akan ditimpa data XAMPP
  String _currentUserId = "1";
  int _pendapatanBulanIni = 0;
  int _jumlahPesananHariIni = 0;

  @override
  void initState() {
    super.initState();
    _loadDataDashboard();
  }

  // === FUNGSI MENYEDOT DATA DARI XAMPP ===
  // === FUNGSI MENYEDOT DATA DARI XAMPP ===
  Future<void> _loadDataDashboard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('id_user') ?? "1";

      final profilData = await ApiService.getProfil(_currentUserId);
      final dataPesanan = await ApiService.getPesanan();

      if (mounted) {
        setState(() {
          _namaAdmin = profilData['nama'] ?? "Admin UMKM";
          _listPesanan = dataPesanan; 
          _jumlahPesananHariIni = _listPesanan.length; 
          _pendapatanBulanIni = _listPesanan
              .where((p) => p['status_pesanan']?.toString().toUpperCase() == 'SELESAI')
              .fold(0, (sum, item) => sum + (int.tryParse(item['total_harga'].toString()) ?? 0));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal load data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // === FORMAT RUPIAH ===
  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // FUNGSI UNTUK MENGUPDATE STATUS KE DATABASE XAMPP
  Future<void> _ubahStatusPesanan(String idPesanan, String statusBaru) async {
    setState(() => _isLoading = true);
    try {
      // Pastikan di API_Service.dart abang sudah ada fungsi updateStatusPesanan
      final response = await ApiService.updateStatusPesanan(idPesanan, statusBaru);

      if (response['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status berhasil diubah ke $statusBaru ✓'), backgroundColor: Colors.green)
        );
        _loadDataDashboard(); // Refresh data biar statusnya berubah di layar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: ${response['pesan']}'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      debugPrint("Error update status: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna dari Desain Figma Abang
    const Color bgCream = Color(0xFFFFE5B9);
    const Color primaryOrange = Color(0xFFD27F30);
    const Color textBrown = Color(0xFFC17F3E);
    const Color lightBrown = Color(0xFFA89070);

    return Scaffold(
      backgroundColor: bgCream, // Latar belakang utama krem sesuai Figma
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Logo & Profil)
            // ==========================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'PuddingKu',
                        style: TextStyle(
                          color: textBrown,
                          fontSize: 24,
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Panel Admin UMKM',
                        style: TextStyle(
                          color: lightBrown,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Foto Profil
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfilAdmin())),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profil admin.png'), // Sesuaikan path gambar abang
                          fit: BoxFit.cover,
                        ),
                        color: Colors.white, // Fallback warna
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // BAGIAN TENGAH (Bisa di-scroll)
            // ==========================================
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: _loadDataDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==========================================
                      // 2. DASHBOARD CARD (Kartu Oranye Utama)
                      // ==========================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KIRI: Info & Badge
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selamat pagi, Admin', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(_namaAdmin, style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Sora', fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()), style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Plus Jakarta Sans')),
                                  
                                  const SizedBox(height: 15),
                                  // Badges Kaca (Transparan)
                                  Row(
                                    children: [
                                      _buildGlassBadge('$_jumlahPesananHariIni Pesanan Baru'),
                                      const SizedBox(width: 8),
                                      _buildGlassBadge('+12% Minggu Ini'),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // KANAN: Statistik Angka
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(formatRupiah(_pendapatanBulanIni), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Pendapatan bulan ini', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('$_jumlahPesananHariIni', style: const TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'Sora', fontWeight: FontWeight.w800)),
                                        const Text('Pesanan\nHari Ini', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==========================================
                      // 3. TOMBOL TAMBAH PESANAN (Besar sesuai Figma)
                      // ==========================================
                      InkWell(
                        onTap: () {
                          // Navigasi ke menu produk atau halaman tambah pesanan
                          Navigator.pushNamed(context, '/menu');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: primaryOrange,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: const [
                              Text('+', style: TextStyle(color: Colors.white, fontSize: 50, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
                              SizedBox(width: 15),
                              Text('Tambah Pesanan', style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==========================================
                      // 4. JUDUL DAFTAR PESANAN
                      // ==========================================
                      const Text(
                        'Daftar Pesanan',
                        style: TextStyle(
                          color: primaryOrange,
                          fontSize: 30,
                          fontFamily: 'Signika Negative',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ==========================================
                      // 5. LIST PESANAN (Dinamis dari Database XAMPP)
                      // ==========================================
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                          : _listPesanan.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text("Belum ada pesanan masuk.", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold)),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _listPesanan.length,
                                  itemBuilder: (context, index) {
                                    final item = _listPesanan[index];
                                    return _buildOrderCard(
                                      id: item['id_pesanan'].toString(),
                                      nama: item['nama_pemesan'] ?? 'Unknown',
                                      ringkasan: item['ringkasan_pesanan'] ?? 'Detail tidak tersedia',
                                      harga: formatRupiah(item['total_harga']),
                                      status: item['status_pesanan'] ?? 'PROSES',
                                      waktu: item['tanggal_pesanan'] ?? '15 menit lalu',
                                    );
                                  },
                                ),
                      const SizedBox(height: 30), // Spasi bawah biar tidak nabrak footer
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // ==========================================
      // 6. BOTTOM NAVIGATION BAR (Sesuai Figma)
      // ==========================================
      bottomNavigationBar: Container(
        height: 75,
        decoration: const BoxDecoration(
          color: primaryOrange,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavIcon(Icons.assignment_outlined, 'Laporan', false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()))),
            _buildNavIcon(Icons.cake_outlined, 'Produk', false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProduk()))),
            _buildNavIcon(Icons.home_outlined, 'Beranda', true, () {}), // Home Aktif
            _buildNavIcon(Icons.history, 'Riwayat', false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()))),
            _buildNavIcon(Icons.person_outline, 'Pengguna', false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanPengguna()))),
          ],
        ),
      ),
    );
  }

  // === WIDGET KECIL UNTUK BADGE KACA (Transparan) ===
  Widget _buildGlassBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
      ),
    );
  }

  // === WIDGET KARTU PESANAN (100% SESUAI FIGMA) ===
  Widget _buildOrderCard({
    required String id, // Tambahkan parameter ID
    required String nama, 
    required String ringkasan, 
    required String harga, 
    required String status, 
    required String waktu
  }) {
    // Logika warna titik status
    Color dotColor;
    switch (status.toUpperCase()) {
      case 'SELESAI': dotColor = Colors.green; break;
      case 'MENUNGGU': dotColor = Colors.orange; break;
      case 'PROSES': dotColor = Colors.blueAccent; break;
      default: dotColor = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar Initial
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFFFF3DE), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(nama.isNotEmpty ? nama[0].toUpperCase() : 'A', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 15),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    
                    // ==========================================
                    // INTERACTIVE STATUS (PopupMenuButton)
                    // ==========================================
                    PopupMenuButton<String>(
                      onSelected: (String value) => _ubahStatusPesanan(id, value),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(value: 'MENUNGGU', child: Text('⏳ MENUNGGU')),
                        const PopupMenuItem(value: 'PROSES', child: Text('🔄 PROSES')),
                        const PopupMenuItem(value: 'SELESAI', child: Text('✅ SELESAI')),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5B9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.black54), // Indikator bisa diklik
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(ringkasan, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.52))),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(harga, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFD27F30))),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(waktu, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET IKON NAVIGASI BAWAH (Desain Bawaan Abang) ===
  Widget _buildNavIcon(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black.withOpacity(0.3) : Colors.transparent, // Efek lingkaran gelap saat aktif
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          Text(label, style: const TextStyle(fontFamily: 'Signika Negative', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}