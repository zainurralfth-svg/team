import 'package:flutter/material.dart';
import '../Core/Colour.dart';

class HalamanPengguna extends StatelessWidget {
  const HalamanPengguna({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk list daftar pengguna
    final List<Map<String, dynamic>> dataPengguna = [
      {
        'huruf': 'A', 
        'nama': 'ANDA', 
        'telepon': '0812-3456-7890', 
        'email': 'hamba allah@gmail.com', 
        'status': 'Baru', 
        'warnaStatus': Colors.blue
      },
      {
        'huruf': 'P', 
        'nama': 'Pria solo', 
        'telepon': '0812-3456-7890', 
        'email': 'hamba allah@gmail.com', 
        'status': 'AKTIF', 
        'warnaStatus': Colors.green
      },
      {
        'huruf': 'A', 
        'nama': 'AKU', 
        'telepon': '0812-3456-7890', 
        'email': 'hamba allah@gmail.com', 
        'status': 'AKTIF', 
        'warnaStatus': Colors.green
      },
      {
        'huruf': 'A', 
        'nama': 'AKU', 
        'telepon': '0812-3456-7890', 
        'email': 'hamba allah@gmail.com', 
        'status': 'AKTIF', 
        'warnaStatus': Colors.green
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFD27F30), // Warna oranye utama
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Teks Selamat Datang & Avatar)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dashboard Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
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
                    // Ganti dengan aset gambar avatar-mu nanti
                    child: const Icon(Icons.person, color: Color(0xFFD27F30), size: 30),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. KARTU STATISTIK & PENDAPATAN
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('12\nProduk', Icons.inventory_2_outlined),
                  _buildStatCard('Riwayat\nPesanan', Icons.shopping_bag_outlined),
                  _buildStatCard('Laporan', Icons.bar_chart),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
            ),
            const SizedBox(height: 20),

            // ==========================================
            // 3. AREA DAFTAR PENGGUNA (Beige Background)
            // ==========================================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF0D5), // Warna krem/beige terang
                ),
                child: Column(
                  children: [
                    // Judul "Daftar Pengguna" berbentuk pil melayang
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD27F30),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                          ],
                        ),
                        child: const Text(
                          'Daftar Pengguna',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // List Data Pengguna
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        itemCount: dataPengguna.length,
                        itemBuilder: (context, index) {
                          final item = dataPengguna[index];
                          return _buildUserCard(item);
                        },
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
      bottomNavigationBar: Container(
        color: const Color(0xFFD27F30),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'BERANDA'),
            _buildNavItem(Icons.person, 'PENGGUNA', isActive: true), // Aktif di Pengguna
            _buildNavItem(Icons.add_box, 'PRODUK BARU'),
            _buildNavItem(Icons.list_alt, 'PESANAN'),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // WIDGET BANTUAN (Helper)
  // ----------------------------------------------------

  // Fungsi pembuat Kartu Statistik transparan di atas
  Widget _buildStatCard(String title, IconData icon) {
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

  // Fungsi pembuat desain satu Kartu Daftar Pengguna
  Widget _buildUserCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon Huruf di sebelah kiri
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0D5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Center(
              child: Text(
                item['huruf'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD27F30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // Detail Informasi Pengguna
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Nama & Label Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['nama'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0D5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: item['warnaStatus'], size: 10),
                          const SizedBox(width: 4),
                          Text(
                            item['status'], 
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Baris Telepon
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item['telepon'],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Baris Email & Ikon Hapus (Trash)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mail, color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item['email'],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    // Ikon Tempat Sampah
                    GestureDetector(
                      onTap: () {
                        // Tambahkan logika hapus pengguna di sini
                      },
                      child: const Icon(Icons.delete_outline, color: Colors.black54, size: 24),
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

  // Fungsi pembuat ikon di Bottom Navigation Bar
  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.transparent, // Background tetap transparan seperti permintaan sebelumnya
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white, // Warna ikon putih
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
    );
  }
}