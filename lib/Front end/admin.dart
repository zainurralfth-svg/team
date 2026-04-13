import 'package:flutter/material.dart';

// --- IMPORT SEMUA FILE HALAMAN DI SINI ---
import 'tambah_produk.dart'; 
import 'halaman_produk.dart';
import 'halaman_riwayat.dart';
import 'halaman_laporan.dart';
import 'halaman_pengguna.dart';
import 'halaman_pesanan.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE5B9), 
      body: Stack(
        children: [
          Container(
            height: 330,
            decoration: const BoxDecoration(
              color: Color(0xFFD27F30),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                // Kirim context supaya kartu stat bisa diklik pindah halaman
                _buildStatCards(context), 
                const SizedBox(height: 25),
                _buildIncomeCard(),
                const SizedBox(height: 15),
                _buildSectionTitle(),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildOrderList(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Dashboard Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFFD27F30), size: 30),
          ),
        ],
      ),
    );
  }

  // --- KARTU STATISTIK SEKARANG BISA DIKLIK ---
  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kartu 12 Produk
          _statCard('12\nProduk', Icons.pie_chart, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProduk()));
          }),
          // Kartu Riwayat Pesanan
          _statCard('Riwayat\nPesanan', Icons.shopping_bag, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()));
          }),
          // Kartu Laporan
          _statCard('Laporan', Icons.assignment, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
          }),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Fungsi klik
      child: Container(
        width: 105,
        height: 105,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.24), 
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Pendapatan',
            style: TextStyle(
              color: Color(0xFFD27F30),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '570.000',
            style: TextStyle(
              color: Color(0xFFD27F30),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD27F30),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Daftar Pesanan',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      itemCount: 4, 
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD27F30))),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mr.A',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Taro pudding 1x, Browkies 1x',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Rp 25.000',
                      style: TextStyle(
                        color: Color(0xFFD27F30),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5B9),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text('PROSES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    children: [
                      Icon(Icons.alarm, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('15 menit lalu', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- MENU BAWAH SEKARANG BISA DIKLIK ---
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFFD27F30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomNavItem(Icons.home, 'BERANDA', true, () {}),
          
          _bottomNavItem(Icons.person, 'PENGGUNA', false, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanPengguna()));
          }),
          
          _bottomNavItem(Icons.add_box, 'PRODUK BARU', false, () {
            // Ini manggil TambahProdukPage yang ada di file tambah_produk.dart
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahProdukPage())); 
          }),

          _bottomNavItem(Icons.add_circle_outline, 'PESANAN', false, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanPesanan()));
          }),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Memperbesar area klik
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFD27F30) : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
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