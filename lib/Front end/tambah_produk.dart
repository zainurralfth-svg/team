import 'package:flutter/material.dart';
import '../Core/Colour.dart';

class TambahProdukPage extends StatelessWidget {
  const TambahProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange, // Background utama (Oranye Kecoklatan)
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Tombol Kembali, Teks, Avatar)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sisi Kiri (Tombol Kembali + Teks Selamat Datang)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tombol Kembali
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context); // Fungsi kembali ke halaman sebelumnya
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Kembali',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Judul
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
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
                  
                  // Sisi Kanan (Avatar)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    // Ganti dengan Icon orang karena belum ada gambar asset aslinya
                    child: const Icon(Icons.person, color: AppColors.primaryOrange, size: 30),
                  ),
                ],
              ),
            ),
            
            // ==========================================
            // 2. KARTU STATISTIK & PENDAPATAN (Tengah Atas)
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
            
            // Kartu Putih Pendapatan
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Bentuk pil/kapsul
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Pendapatan',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '570.000',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),

            // ==========================================
            // 3. AREA FORM TAMBAH PRODUK (Bawah Melengkung)
            // ==========================================
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange, // Warnanya nyaru, tapi dia menimpa putih nanti jika diubah
                  // Di desain asli sepertinya ada background melengkung ke atas, kita beri lengkungan
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  // Efek bayangan tipis ke atas
                  boxShadow: [
                     BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                     )
                  ]
                ),
                child: SingleChildScrollView( // Agar form bisa di-scroll
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header "Tambah Produk" dengan Logo Kotak
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // Warna kotak abu
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.add_box, color: Colors.black87, size: 30),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'Tambah Produk',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 25),

                      // Kolom-kolom Input
                      _buildInputLabel('Nama Produk'),
                      _buildInputField('Ketik Disini...', Icons.inventory_2),
                      
                      const SizedBox(height: 15),
                      
                      _buildInputLabel('Harga Produk'),
                      _buildInputField('Ketik Disini...', Icons.monetization_on),

                      const SizedBox(height: 15),
                      
                      _buildInputLabel('Stok Produk'),
                      _buildInputField('Ketik Disini...', Icons.layers),

                      const SizedBox(height: 15),
                      
                      _buildInputLabel('Deskripsi Produk'),
                      _buildInputField('Ketik Disini...', Icons.description),

                      const SizedBox(height: 15),
                      
                      _buildInputLabel('Tambah Foto Produk'),
                      // Area Upload Foto Custom
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg, // Warna krem latar input
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image, color: Colors.black54),
                            const SizedBox(width: 10),
                            // Tombol Pilih File Putih
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text('Pilih File...', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Tidak Ada File Yang Di Pilih',
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // Tombol Konfirmasi Produk
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bgCream, // Krem terang
                            foregroundColor: Colors.black, // Teks hitam
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.check, color: Colors.green, size: 24),
                          label: const Text(
                            'Konfirmasi Produk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                             // Aksi simpan produk di sini
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Produk berhasil ditambahkan!')),
                             );
                             Navigator.pop(context); // Otomatis kembali ke admin
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
  // WIDGET BANTUAN (Helper) AGAR KODE TIDAK BERULANG PAAJANG
  // ----------------------------------------------------

  // Fungsi pembuat label tulisan putih di atas kotak input
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 10.0),
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

  // Fungsi pembuat kotak input teks (TextField) bentuk pil/kapsul
  Widget _buildInputField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black54),
        fillColor: AppColors.inputBg, // Krem dari color.dart
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none, // Hilangkan garis pinggir
        ),
      ),
    );
  }

  // Fungsi pembuat Kartu Statistik transparan di atas
  Widget _buildStatCard(String title, IconData icon) {
    return Container(
      width: 105,
      height: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.24), // Transparan 24%
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
}