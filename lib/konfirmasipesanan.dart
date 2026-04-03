import 'package:flutter/material.dart';

class KonfirmasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna dasar untuk seluruh halaman
      backgroundColor: const Color(0xFFF2D7A6), // Background Krem/Beige
      
      // SafeArea berfungsi agar desain kita tidak tertabrak "poni" kamera HP atau status bar di atas layar
      body: SafeArea(
        // Column utama ini membagi layar menjadi 3 susunan dari atas ke bawah:
        // 1. Header (Atas)
        // 2. Isi Konten (Tengah - Bisa di scroll)
        // 3. Bottom Nav Bar (Bawah)
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (APP BAR CUSTOM)
            // ==========================================
            // Kita tidak pakai AppBar bawaan Flutter, tapi bikin sendiri pakai Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: const BoxDecoration(
                color: Color(0xFFD27F30), // Warna Oranye
              ),
              // Row digunakan untuk menyusun elemen menyamping (kiri ke kanan)
              child: Row(
                children: [
                  // --- Tombol Kembali ---
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Perintah untuk kembali ke halaman sebelumnya
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5), // Garis pinggir hitam
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Kembali',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  
                  // --- Judul Header ---
                  // Expanded digunakan agar teks ini mengambil seluruh SISA ruang kosong di tengah
                  // sehingga otomatis posisinya akan selalu berada di tengah layar.
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Konfirmasi Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Oleo Script',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // SizedBox kosong ini berfungsi sebagai "penyeimbang" berat tombol kembali di sisi kiri, 
                  // supaya judul benar-benar berada di poros tengah.
                  const SizedBox(width: 40), 
                ],
              ),
            ),

            // ==========================================
            // 2. ISI KONTEN (BISA DI-SCROLL)
            // ==========================================
            // Expanded di sini SANGAT PENTING! 
            // Dia menyuruh area scroll ini untuk mengisi seluruh ruang di antara Header dan Footer.
            Expanded(
              // SingleChildScrollView membuat konten di dalamnya bisa digeser (di-scroll) ke atas/bawah
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Agar semua teks rata kiri
                  children: [
                    
                    // --- BAGIAN A: RINGKASAN PEMESANAN ---
                    Row(
                      children: [
                        const Icon(Icons.receipt_long, color: Color(0xFF270C0C)),
                        const SizedBox(width: 10),
                        const Text(
                          'Ringkasan Pemesanan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF270C0C)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Kotak Putih untuk Ringkasan
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          // Memberi efek bayangan halus di bawah kotak
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Memanggil fungsi _buildItemRingkasan (didefinisikan di paling bawah)
                          // untuk menampilkan produk tanpa harus menulis kode desainnya berulang kali.
                          _buildItemRingkasan('Brownie Burnt Cheesecake', 'x2', 'Rp 36.000', 'assets/images/burn.jpeg'),
                          const SizedBox(height: 15),
                          _buildItemRingkasan('Death By Cokelat', 'x1', 'Rp 18.000', 'assets/images/death.jpeg'),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            // Divider adalah widget bawaan Flutter untuk membuat garis lurus pemisah
                            child: Divider(color: Colors.black, thickness: 1.5), 
                          ),
                          
                          // Total Harga
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Merenggangkan teks ke ujung kiri dan ujung kanan
                            children: [
                              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              const Text('Rp 54.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD27F30))),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25), // Jarak antar sesi

                    // --- BAGIAN B: DATA DIRI ---
                    Row(
                      children: [
                        const Icon(Icons.person, color: Color(0xFFD27F30)),
                        const SizedBox(width: 10),
                        const Text(
                          'Data Diri',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF270C0C)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Kotak Putih Besar untuk Form Data Diri
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input Nama Lengkap
                          const Text('NAMA LENGKAP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 5),
                          // Memanggil fungsi _buildTextField untuk membuat kolom isian
                          _buildTextField('Nama Kamu', Icons.person, const Color(0xFFFF9800)),
                          
                          const SizedBox(height: 15),
                          
                          // Input No Telp
                          const Text('NO. TELP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 5),
                          _buildTextField('No. Telp', Icons.phone_in_talk_outlined, Colors.black),
                          
                          const SizedBox(height: 30),

                          // --- Tombol Checkout Sekarang ---
                          Center(
                            // ElevatedButton.icon memungkinkan kita bikin tombol yang ada logo + teks di dalamnya sekaligus
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1C574), // Kuning krem
                                foregroundColor: Colors.black, // Warna teks tombol
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.black, width: 0.5), // Garis pinggir hitam tipis
                                ),
                              ),
                              icon: const Icon(Icons.shopping_bag, color: Color(0xFFFF7043), size: 20),
                              label: const Text('Checkout Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                // showDialog digunakan untuk memunculkan pop-up pemberitahuan
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Sukses!'),
                                    content: const Text('Pesanan Anda telah dikonfirmasi.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Menutup pop-up dialog
                                          Navigator.pushReplacementNamed(context, '/menu'); // Pergi ke menu utama
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 15),

                          // --- Tombol Kirim ---
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1C574), 
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.black, width: 0.5),
                                ),
                              ),
                              onPressed: () {
                                // SnackBar untuk memunculkan notifikasi kecil di bawah layar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Data akan dikirim ke admin'), duration: Duration(seconds: 1)),
                                );
                              },
                              child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          
                          const SizedBox(height: 20),

                          // --- Label Note (Nb) ---
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E0),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFD27F30)),
                              ),
                              child: const Text(
                                'Nb: Lakukan pembayaran di outlet',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // 3. BOTTOM NAVIGATION BAR (FOOTER)
            // ==========================================
            // Footer ini berada di luar Expanded, artinya dia akan selalu menempel mati di bawah layar (Sticky Bottom)
            Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFD27F30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Menyebarkan icon secara merata
                children: [
                  // Icon Pesanan
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag, color: Colors.white),
                        Text('Pesanan', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Icon Produk
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/menu'),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu, color: Colors.white),
                        Text('Produk', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HELPER 1: Baris Produk di Ringkasan
  // ==========================================
  // Dengan membuat fungsi ini, kalau kita punya 10 produk di keranjang, 
  // kita cukup memanggil fungsi ini 10 kali, tanpa harus mengulang kode Row berulang-ulang.
  Widget _buildItemRingkasan(String title, String qty, String price, String imagePath) {
    return Row(
      children: [
        // Kotak Gambar Produk
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 15),
        
        // Nama Produk & Jumlah (Pakai Expanded agar tulisan memanjang ke kanan dan mendorong Harga ke ujung)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
              Text(qty, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        
        // Harga Produk
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD27F30))),
      ],
    );
  }

  // ==========================================
  // WIDGET HELPER 2: Kotak Input Data Diri
  // ==========================================
  // Digunakan untuk merancang desain TextField (kolom ketik) agar seragam.
  Widget _buildTextField(String hint, IconData icon, Color iconColor) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint, // Teks bayangan (contoh: "Nama Kamu")
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: iconColor, size: 22), // Ikon di dalam kotak ketik
        fillColor: const Color(0xFFFEF6E8), // Warna latar belakang isian (krem sangat pudar)
        filled: true, // Mengaktifkan warna latar belakang
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        
        // Desain batas (border) saat sedang tidak diklik
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30)),
        ),
        
        // Desain batas (border) saat kotak sedang diklik/diisi
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30), width: 1.5),
        ),
      ),
    );
  }
}