import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // Palet 14 Warna Baru
import '../Widget/custom_text.dart'; // <-- IMPORT COMPONENT CUSTOM TEXT KITA BRO!

class TampilanAwal extends StatelessWidget {
  const TampilanAwal({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. WARNA BACKGROUND GRADASI MENGGUNAKAN PALET BARU
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgUtama, // Krem dari atas
                  AppColors.primary, // Mengarah ke Oranye Coklat di bawah
                ],
              ),
            ),
          ),

          // 2. ELEMEN DEKORATIF BACKGROUND (POLA KUE)
          Positioned(
            left: -20,
            top: 50,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/satu.png', width: 120),
            ),
          ),
          Positioned(
            right: -20,
            top: 100,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/dua.png', width: 100),
            ),
          ),
          Positioned(
            left: 20,
            top: screenHeight * 0.4,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/tiga.png', width: 90),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 120,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/empat.png', width: 140),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 60,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/satu.png', width: 80),
            ),
          ),

          // 3. KONTEN UTAMA
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Bagian Atas: Kosong untuk penyeimbang
                    const SizedBox(),

                    // 2. Bagian Tengah: Logo Utama dengan Efek Sederhana (Glow Belakang)
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Efek Cahaya di belakang logo
                        Container(
                          width: screenWidth * 0.5,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.4),
                                blurRadius: 80,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Logo Utama
                        Image.asset(
                          'assets/images/tulisan tampilan awal.png',
                          width: screenWidth * 0.85,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),

                    // --- BAGIAN BAWAH: TOMBOL "GET STARTED" ---
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Container(
                            width: screenWidth * 0.85,
                            height: 60,
                            decoration: BoxDecoration(
                              // Menggunakan warna utama untuk tombol
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              // ==========================================
                              // TEKS TOMBOL SEKARANG PAKAI CUSTOM TEXT!
                              // ==========================================
                              child: CustomText(
                                'Masuk Sekarang', // Teks tombol
                                color: AppColors.textWhite, // Teks putih
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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