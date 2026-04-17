import 'package:flutter/material.dart';
import '../Core/Colour.dart'; 

class TampilanAwal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. WARNA BACKGROUND GRADASI MENGGUNAKAN APPCOLORS
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gradasiAtas,  // <-- Panggil dari AppColors
                  AppColors.gradasiBawah, // <-- Panggil dari AppColors
                ],
              ),
            ),
          ),

          // 2. ELEMEN DEKORATIF BACKGROUND (POLA KUE)
          Positioned(
            left: -20, top: 50,
            child: Opacity(
              opacity: 0.15, 
              child: Image.asset('assets/images/satu.png', width: 120),
            ),
          ),
          Positioned(
            right: -20, top: 100,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/dua.png', width: 100),
            ),
          ),
          Positioned(
            left: 20, top: screenHeight * 0.4,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/tiga.png', width: 90),
            ),
          ),
          Positioned(
            right: 10, bottom: 120,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/empat.png', width: 140),
            ),
          ),
          Positioned(
            left: 30, bottom: 60,
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
                    // --- BAGIAN ATAS: LOGO TULISAN ---
                    Column(
                      children: [
                        const SizedBox(height: 30), 
                        Image.asset(
                          'assets/images/tulisan_awal.png', 
                          width: screenWidth * 0.65, 
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),

                    // --- BAGIAN TENGAH: GAMBAR KUE STRAWBERRY UTAMA ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Image.asset(
                        'assets/images/logo_puding.png', 
                        width: screenWidth * 0.50, 
                        fit: BoxFit.contain,
                      ),
                    ),

                    // --- BAGIAN BAWAH: TOMBOL "GET STARTED" ---
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/masuk');
                          },
                          child: Container(
                            width: screenWidth * 0.85, 
                            height: 60, 
                            decoration: BoxDecoration(
                              color: AppColors.tombolGetStarted, // <-- Panggil dari AppColors
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
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold, 
                                ),
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