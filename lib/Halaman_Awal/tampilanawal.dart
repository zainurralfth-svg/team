import 'package:flutter/material.dart';
import '../Core/Colour.dart';
import '../Widget/custom_text.dart';

// Halaman pertama yang muncul saat aplikasi baru dibuka (Splash/Welcome Screen)
class TampilanAwal extends StatelessWidget {
  const TampilanAwal({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran lebar dan tinggi layar HP secara otomatis agar tampilan tidak berantakan di beda HP
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Memakai Stack karena kita mau menumpuk gambar: dari warna background paling belakang sampai tombol di paling depan
      body: Stack(
        children: [
          // =========================================================================
          // LAPISAN 1: WARNA BACKGROUND PALING BELAKANG
          // =========================================================================
          Container(
            width: double.infinity, // Memaksa lebar agar memenuhi seluruh layar
            height:
                double.infinity, // Memaksa tinggi agar memenuhi seluruh layar
            decoration: const BoxDecoration(
              // Membuat warna gradasi yang menyatu dari atas ke bawah
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgUtama, // Warna krem di bagian atas
                  AppColors
                      .primary, // Menyatu jadi warna oranye cokelat di bagian bawah
                ],
              ),
            ),
          ),

          // =========================================================================
          // LAPISAN 2: GAMBAR-GAMBAR KUE SEBAGAI HIASAN BACKGROUND
          // =========================================================================
          // Positioned: Untuk menaruh gambar di posisi X dan Y yang pas (seperti nempel stiker)
          // Opacity (0.15): Agar gambarnya transparan/samar dan tidak menutupi tulisan di depannya

          // Hiasan 1: Di pojok kiri atas
          Positioned(
            left: -20,
            top: 50,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/satu.png', width: 120),
            ),
          ),

          // Hiasan 2: Di pojok kanan atas
          Positioned(
            right: -20,
            top: 100,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/dua.png', width: 100),
            ),
          ),

          // Hiasan 3: Di kiri tengah (posisi tingginya menyesuaikan 40% dari tinggi layar HP)
          Positioned(
            left: 20,
            top: screenHeight * 0.4,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/tiga.png', width: 90),
            ),
          ),

          // Hiasan 4: Di pojok kanan bawah
          Positioned(
            right: 10,
            bottom: 120,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/empat.png', width: 140),
            ),
          ),

          // Hiasan 5: Di pojok kiri bawah
          Positioned(
            left: 30,
            bottom: 60,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/satu.png', width: 80),
            ),
          ),

          // =========================================================================
          // LAPISAN 3: ISI UTAMA HALAMAN (LOGO DAN TOMBOL)
          // =========================================================================
          // SafeArea: Menjaga agar konten tidak tertutup oleh poni HP (notch) atau kamera depan
          SafeArea(
            // SingleChildScrollView: Mencegah error layar kuning-hitam (overflow) kalau aplikasi dibuka di HP layar kecil
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ), // Memberi jarak pinggir agar konten tidak nempel ke bingkai HP
                // Memastikan tinggi area ini sama persis dengan tinggi layar yang tersedia
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top,
                ),
                // Column: Menyusun logo dan tombol dari atas ke bawah
                child: Column(
                  // SpaceBetween: Mendorong elemen ke atas dan ke bawah agar letaknya proporsional
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ruang kosong pembantu agar letak logo bisa agak turun dan pas di tengah
                    const SizedBox(),

                    // KELOMPOK LOGO UTAMA
                    // Pakai Stack di sini untuk memberi efek cahaya di belakang gambar logo
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Efek cahaya bersinar (glow) di belakang logo
                        Container(
                          width: screenWidth * 0.5,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.4),
                                blurRadius:
                                    80, // Seberapa luas cahayanya menyebar
                                spreadRadius: 10, // Seberapa terang cahayanya
                              ),
                            ],
                          ),
                        ),
                        // Gambar tulisan logo aplikasi
                        Image.asset(
                          'assets/images/tulisan tampilan awal.png',
                          width:
                              screenWidth *
                              0.85, // Lebar logo diatur 85% dari lebar HP agar pas
                          fit: BoxFit
                              .contain, // Menjaga gambar agar tidak gepeng atau berubah bentuk
                        ),
                      ],
                    ),

                    // KELOMPOK TOMBOL BAWAH
                    Column(
                      children: [
                        // GestureDetector: Mengubah desain kotak biasa menjadi tombol yang bisa ditekan
                        GestureDetector(
                          onTap: () {
                            // Perintah untuk pindah ke halaman Login setelah tombol ditekan
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Container(
                            width:
                                screenWidth *
                                0.85, // Lebar tombol disamakan dengan lebar logo biar rapi
                            height:
                                60, // Tinggi tombol yang pas untuk ditekan jari
                            decoration: BoxDecoration(
                              color: AppColors.primary, // Warna dasar tombol
                              borderRadius: BorderRadius.circular(
                                20,
                              ), // Membuat ujung tombol jadi melengkung/tumpul
                              boxShadow: [
                                // Memberi efek bayangan kecil agar tombol terlihat timbul (3D)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(
                                    0,
                                    4,
                                  ), // Bayangan jatuh ke bawah sedikit
                                ),
                              ],
                            ),
                            child: const Center(
                              // Memakai CustomText buatan sendiri agar desain dan ukuran tulisan selalu seragam
                              child: CustomText(
                                'Get Started',
                                color: AppColors.textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight
                                    .bold, // Ditebalkan karena ini tombol aksi penting
                              ),
                            ),
                          ),
                        ),
                        // Jarak kosong di bawah tombol biar tidak terlalu mepet dengan ujung bawah HP
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
