import 'package:flutter/material.dart';

class HalamanPesanan extends StatefulWidget {
  const HalamanPesanan({super.key});

  @override
  State<HalamanPesanan> createState() => _HalamanPesananState();
}

class _HalamanPesananState extends State<HalamanPesanan> {
  // Variabel untuk menyimpan pilihan menu di Dropdown
  String? _selectedMenu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD27F30), // Warna oranye utama
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Kembali, Selamat Datang, Avatar)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Kembali
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Kembali',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Teks Tengah (Selamat Datang)
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Tai Heritage Pro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Dashboard Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Tai Heritage Pro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Avatar Pengguna
                  Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Color(0xFFD27F30), size: 28),
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
                  _buildStatCard('Riwayat\nPesanan', Icons.shopping_bag),
                  _buildStatCard('Laporan', Icons.bar_chart),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Baris Pendapatan
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
            // 3. AREA FORM TAMBAH PESANAN
            // ==========================================
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFFC67727), // Oranye sedikit lebih gelap untuk form
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Form "Tambah pesanan"
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.add, color: Colors.green, size: 40),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'Tambah pesanan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Input Fields
                      _buildInputLabel('Kode/Nama'),
                      _buildTextField(),
                      const SizedBox(height: 15),

                      _buildInputLabel('Menu'),
                      _buildDropdown(),
                      const SizedBox(height: 15),

                      _buildInputLabel('Jumlah'),
                      _buildTextField(isNumber: true),
                      const SizedBox(height: 15),

                      _buildInputLabel('Harga'),
                      _buildTextField(isNumber: true),
                      const SizedBox(height: 40),

                      // Tombol Buat Pesanan
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFE8C4), // Warna krem/beige
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: const Text(
                            'Buat pesanan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            // Tambahkan aksi saat tombol ditekan di sini
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pesanan berhasil dibuat!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // WIDGET BANTUAN (Helper)
  // ----------------------------------------------------

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

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({bool isNumber = false}) {
    return TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        fillColor: const Color(0xFFFFE8C4),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // Menghilangkan garis pinggir
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8C4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedMenu,
          hint: const Text('Pilih Menu', style: TextStyle(color: Colors.black54)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 30),
          // Sesuaikan daftar menu ini dengan kebutuhan aplikasi kamu
          items: <String>[
            'Taro Pudding',
            'Brownie Burnt Cheesecake',
            'Death By Chocolate',
            'Mango Pudding'
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedMenu = newValue;
            });
          },
        ),
      ),
    );
  }
}