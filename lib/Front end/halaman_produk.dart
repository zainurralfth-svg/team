import 'package:flutter/material.dart';

// Class Halaman Produk (Bentuk Full Dashboard Manajemen Menu)
class HalamanProduk extends StatelessWidget {
  const HalamanProduk({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background krem disamakan persis dengan halaman Admin
      backgroundColor: const Color(0xFFFFE5B9), 
      body: Stack(
        children: [
          // Background Oranye di bagian atas (tingginya disamakan 330)
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
                _buildStatCards(),
                const SizedBox(height: 25),
                _buildIncomeCard(),
                const SizedBox(height: 15),
                
                // Judul "Manajemen Menu" dengan bentuk kapsul persis "Daftar Pesanan"
                _buildSectionTitle(),
                
                const SizedBox(height: 10),
                
                // Daftar Produk
                Expanded(
                  child: _buildMenuList(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // ==========================================
  // 1. HEADER (Selamat Datang & Avatar)
  // ==========================================
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

  // ==========================================
  // 2. KARTU STATISTIK 
  // ==========================================
  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard('12\nProduk', Icons.pie_chart),
          _statCard('Riwayat\nPesanan', Icons.shopping_bag),
          _statCard('Laporan', Icons.assignment),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon) {
    return Container(
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
    );
  }

  // ==========================================
  // 3. BARIS PENDAPATAN
  // ==========================================
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

  // ==========================================
  // 4. JUDUL MANAJEMEN MENU (Disamakan dengan Daftar Pesanan)
  // ==========================================
  Widget _buildSectionTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFC77833), // Warna cokelat oranye gelap
        borderRadius: BorderRadius.circular(15), // Melengkung di semua sudut (Kapsul)
      ),
      child: const Text(
        'Manajemen Menu',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==========================================
  // 5. DAFTAR KARTU PRODUK (Desain disesuaikan)
  // ==========================================
  Widget _buildMenuList() {
    final List<String> menuItems = [
      'BROWNIE BURNT CHEES CAKE',
      'JIGGLY PUDDING RABIT',
      'MILK BUN',
      'MANGGO MOUSE CAKE'
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // Sudut membulat
          ),
          child: Row(
            children: [
              // Kotak Gambar Produk (Abu-abu / Placeholder)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 15),
              // Nama Produk
              Expanded(
                child: Text(
                  menuItems[index],
                  style: const TextStyle(
                    fontSize: 14, // Ukuran font disesuaikan
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Ikon Edit dan Hapus (Sesuai posisi di gambar)
              const Icon(Icons.edit, color: Colors.green, size: 24),
              const SizedBox(width: 10),
              const Icon(Icons.delete, color: Colors.orange, size: 24),
              const SizedBox(width: 5),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 6. BOTTOM NAVIGATION BAR 
  // ==========================================
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 80, 
      color: const Color(0xFFD27F30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // BERANDA -> Saat diklik kembali ke admin
          _bottomNavItem(Icons.home, 'BERANDA', false, () {
             Navigator.pop(context); 
          }),
          
          _bottomNavItem(Icons.person, 'PENGGUNA', false, () {}),
          _bottomNavItem(Icons.add_box, 'PRODUK BARU', false, () {}),
          _bottomNavItem(Icons.add_circle_outline, 'PESANAN', false, () {}),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent, 
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFD27F30) : Colors.white,
                size: 28, 
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