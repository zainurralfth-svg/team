import 'package:flutter/material.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart';
import 'halaman_pengguna.dart';
import 'halaman_pesanan.dart';
import 'admin.dart';
import 'halaman_profil_admin.dart';
import 'halaman_produk.dart';
import 'halaman_laporan.dart';

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

  Future<void> _fetchDataPesanan() async {
    try {
      final data = await ApiService.getPesanan();
      setState(() {
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
      backgroundColor: const Color(0xFFF9E4C5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==========================================
            // 1. HEADER
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
                        'PuddingKu',
                        style: TextStyle(
                          color: Color(0xFFA66428),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Panel Admin UMKM',
                        style: TextStyle(
                          color: Color(0xFFD27F30),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeAdmin(),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profil admin.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. SEARCH BAR
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 253, 251),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search...',
                      style: TextStyle(
                        color: Color(0xFFD27F30),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.search,
                      color: Color(0xFFD27F30),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ==========================================
            // 3. LABEL RIWAYAT PESANAN
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Riwayat Pesanan',
                style: TextStyle(
                  color: Color(0xFFA66428),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ==========================================
            // 4. DAFTAR RIWAYAT PESANAN
            // ==========================================
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _listPesanan.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada riwayat pesanan",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _fetchDataPesanan,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
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

      // ==========================================
      // 5. BOTTOM NAVIGATION BAR
      // ==========================================
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // ============================================================
  // FUNGSI PEMBUAT DESAIN KARTU PESANAN
  // ============================================================
  Widget _buildOrderCard(Map<String, dynamic> item) {
    String namaPemesan = item['nama_pemesan'] ?? 'Tanpa Nama';
    String ringkasan = item['ringkasan_pesanan'] ?? 'Detail Kosong';
    String harga = 'Rp ${item['total_harga'] ?? 0}';
    String status = item['status_pesanan'] ?? 'PROSES';

    String waktuLengkap = item['tanggal_pesan'] ?? '';
    String waktuSingkat = waktuLengkap.length > 16
        ? waktuLengkap.substring(0, 16)
        : waktuLengkap;

    Color statusColor = status == 'SELESAI'
        ? AppColors.success
        : (status == 'DIBATALKAN' ? AppColors.error : AppColors.info);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ringkasan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      harga,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          waktuSingkat,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
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
      color: AppColors.primary,
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
                color: isSelected
                    ? const Color(0xFF3A1F0F).withOpacity(0.2)
                    : Colors.transparent,
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