import 'package:flutter/material.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; // File warna 14 Palet Baru
import 'halaman_pengguna.dart';
import 'halaman_pesanan.dart';
import 'admin.dart'; 
import 'halaman_profil_admin.dart'; 
import 'halaman_produk.dart'; // <-- BISA KLIK KE PRODUK
import 'halaman_laporan.dart'; // <-- BISA KLIK KE LAPORAN

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  List<dynamic> _listPesanan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataPesanan();
  }

  // ============================================================
  // FUNGSI MENYEDOT DATA DARI DATABASE (API)
  // ============================================================
  Future<void> _fetchDataPesanan() async {
    try {
      final data = await ApiService.getPesanan();
      setState(() {
        // ========================================================
        // KODE FILTER: HANYA Tampilkan status SELESAI & DIBATALKAN
        // ========================================================
        _listPesanan = data.where((item) {
          String status = item['status_pesanan'] ?? '';
          return status == 'SELESAI' || status == 'DIBATALKAN';
        }).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching pesanan: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Latar belakang utama pakai oranye coklat
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Sapaan Admin & Profil)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dashboard Admin',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // TOMBOL PROFIL INTERAKTIF
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HalamanProfilAdmin(),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.textWhite,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary, // Ikon profil warna utama
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. KARTU STATISTIK PENDEK (INTERAKTIF)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('12\nProduk', Icons.inventory_2_outlined, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HalamanProduk()),
                    );
                  }),
                  _buildStatCard('Riwayat\npesanan', Icons.shopping_bag, isActive: true, onTap: () {}),
                  _buildStatCard('Laporan', Icons.bar_chart, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HalamanLaporan()),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Baris Info Pendapatan
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pendapatan',
                    style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp -', 
                    style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // 3. AREA DAFTAR RIWAYAT PESANAN (Bagian Bawah)
            // ==========================================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.bgCard, // Background daftar pesanan pakai krem
                ),
                child: Column(
                  children: [
                    // Label Mengambang "Daftar Pesanan"
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))
                          ],
                        ),
                        child: const Text(
                          'Daftar Pesanan',
                          style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: _isLoading 
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : _listPesanan.isEmpty 
                          ? const Center(child: Text("Belum ada pesanan masuk", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
                          : RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: _fetchDataPesanan, 
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                itemCount: _listPesanan.length,
                                itemBuilder: (context, index) {
                                  return _buildOrderCard(_listPesanan[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // ==========================================
      // 4. BOTTOM NAVIGATION BAR 
      // ==========================================
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // ----------------------------------------------------
  // WIDGET BANTUAN (Helper)
  // ----------------------------------------------------

  // Fungsi membuat Card Statistik Pendek di Header
  Widget _buildStatCard(String title, IconData icon, {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        height: 105,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Efek kaca tembus pandang (translucent white)
          color: isActive ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.24),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textWhite, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FUNGSI PEMBUAT DESAIN KARTU PESANAN
  // ============================================================
  Widget _buildOrderCard(Map<String, dynamic> item) {
    String namaPemesan = item['nama_pemesan'] ?? 'Tanpa Nama';
    String hurufAwal = namaPemesan.isNotEmpty ? namaPemesan[0].toUpperCase() : '?';
    String ringkasan = item['ringkasan_pesanan'] ?? 'Detail Kosong';
    String harga = 'Rp ${item['total_harga'] ?? 0}';
    String status = item['status_pesanan'] ?? 'PROSES';
    
    String waktuLengkap = item['tanggal_pesan'] ?? '';
    String waktuSingkat = waktuLengkap.length > 16 ? waktuLengkap.substring(0, 16) : waktuLengkap;

    // Tentukan warna bullet poin status pesanan berdasarkan palet baru
    Color statusColor = status == 'SELESAI' ? AppColors.success : (status == 'DIBATALKAN' ? AppColors.error : AppColors.info);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kotak inisial nama
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Center(
              child: Text(
                hurufAwal,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      namaPemesan,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    // Label Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: statusColor, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            status == 'SELESAI' ? 'Selesai' : 'Dibatalkan', 
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ringkasan,
                  style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      harga,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          waktuSingkat,
                          style: const TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FUNGSI BOTTOM NAVIGATION 
  // ==========================================
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 70,
      color: AppColors.primary, // Latar bottom nav
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
           _bottomNavItem(Icons.assignment_outlined, 'Laporan', false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HalamanLaporan()),
            );
          }),
           _bottomNavItem(Icons.cake_outlined, 'Produk', false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HalamanProduk()),
            );
          }),
          _bottomNavItem(Icons.home_outlined, 'Beranda', false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdmin()),
            );
          }),
          _bottomNavItem(Icons.history, 'Riwayat', true, () {}),
          _bottomNavItem(Icons.person_outline, 'Pengguna', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanPengguna()),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET ITEM NAVIGASI
  // ==========================================
  Widget _bottomNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                // Efek lingkar di belakang ikon navigasi jika diklik
                color: isSelected ? AppColors.textWhite.withOpacity(0.2) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textWhite,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}