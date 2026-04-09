import 'package:flutter/material.dart';

void main() {
  runApp(const PuddingkuApp());
}

class PuddingkuApp extends StatelessWidget {
  const PuddingkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Puddingku Admin - Manajemen Menu',
      theme: ThemeData(
        fontFamily: 'Signika Negative', // Gunakan font Signika untuk seluruh aplikasi
      ),
      home: const ManajemenMenuPage(),
    );
  }
}

class ManajemenMenuPage extends StatelessWidget {
  const ManajemenMenuPage({super.key});

  // Warna Hex yang tepat dari gambar
  static const Color headerOrange = Color(0xFFD27F30);
  static const Color backgroundBeige = Color(0xFFC7BCA1);
  static const Color textOrange = Color(0xFFD27F30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBeige, // Warna background beige gelap
      body: Stack(
        children: [
          // Background Orange melengkung di bagian atas
          Container(
            height: 330,
            decoration: const BoxDecoration(
              color: headerOrange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 15),
                _buildStatCards(),
                const SizedBox(height: 25),
                _buildIncomeCard(),
                const SizedBox(height: 15),
                _buildSectionTitle(),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildMenuList(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Header dengan Teks Serif dan Avatar
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
                  fontFamily: 'Tai Heritage Pro', // Gunakan font serif yang sesuai
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Dashboard Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontFamily: 'Tai Heritage Pro', // Gunakan font serif yang sesuai
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Avatar Profil Bulat
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: headerOrange, size: 30),
          ),
        ],
      ),
    );
  }

  // Tiga Kartu Statistik Transparan
  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard('12 Produk', Icons.inventory_2_outlined),
          _statCard('Riwayat\nPesanan', Icons.shopping_bag_outlined),
          _statCard('Laporan', Icons.bar_chart),
        ],
      ),
    );
  }

  // Widget Kartu Statistik Tunggal
  Widget _statCard(String title, IconData icon) {
    return Container(
      width: 105,
      height: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.24), // Transparansi putih
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
              fontFamily: 'Signika Negative', // Font label stats
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Kartu Pendapatan Teks Orange
  Widget _buildIncomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Pill shape
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Pendapatan',
            style: TextStyle(
              color: textOrange,
              fontSize: 16,
              fontFamily: 'Signika Negative', // Font label
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '570.000',
            style: TextStyle(
              color: textOrange,
              fontSize: 16,
              fontFamily: 'Signika Negative', // Font label
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Judul Bagian "Manajemen Menu" Teks Putih
  Widget _buildSectionTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 20), // Tambahkan margin
      decoration: BoxDecoration(
        color: headerOrange,
        borderRadius: BorderRadius.circular(15), // Pill shape
      ),
      child: const Center(
        child: Text(
          'Manajemen Menu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Signika Negative', // Font judul
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // List Menu dengan Kartu Putih dan Teks Kapital
  Widget _buildMenuList() {
    // Data list menu persis dari gambar
    final List<String> menuItems = [
      'BROWNIE BURNT CHEESECAKE',
      'JIGGLY PUDDING RABIT',
      'MILK BUN',
      'MANGO MOUSE CAKE'
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Gambar Produk Kotak Gelap
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C6353), // Warna placeholder gelap
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/70x70"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Nama Produk Teks Kapital
              Expanded(
                child: Text(
                  menuItems[index],
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Signika Negative', // Font nama produk
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Tombol Aksi di far right, presisi vertikal dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green, size: 20),
                    onPressed: () {
                      // Aksi edit
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.orange, size: 20),
                    onPressed: () {
                      // Aksi delete
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Bottom Nav Bar Orange dengan Lingkaran Putih Presisi
  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: headerOrange,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomNavItem(Icons.home, 'BERANDA', true),
          _bottomNavItem(Icons.person, 'PENGGUNA', false),
          _bottomNavItem(Icons.add_box, 'PRODUK BARU', false),
          _bottomNavItem(Icons.description, 'PESANAN', false), // Gunakan ikon laporan/deskripsi
        ],
      ),
    );
  }

  // Widget Item Bottom Nav Tunggal
  Widget _bottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Lingkaran Putih Presisi untuk Item Aktif
            if (isSelected)
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(
              icon,
              color: isSelected ? headerOrange : Colors.white,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'Tai Heritage Pro', // Font label nav serif
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}