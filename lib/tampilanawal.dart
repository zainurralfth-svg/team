import 'package:flutter/material.dart';

class TampilanAwal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk responsivitas
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF2D7A6),
                  Color(0xFFE08A3A),
                ],
              ),
            ),
          ),

          // ===== ELEMEN DEKORATIF (GAMBAR 1-4) SESUAI GAMBAR PERTAMA =====
          
          // GAMBAR 1 - pojok kiri atas (agak besar)
          Positioned(
            left: -30,
            top: 20,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/satu.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // GAMBAR 2 - pojok kanan atas (sedang)
          Positioned(
            right: -20,
            top: 60,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/dua.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // GAMBAR 3 - kiri tengah (kecil)
          Positioned(
            left: 20,
            top: screenHeight * 0.35,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/tiga.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // GAMBAR 4 - kanan bawah (agak besar)
          Positioned(
            right: 20,
            bottom: 150,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/empat.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // GAMBAR 1 (ulangan) - pojok kiri bawah (kecil)
          Positioned(
            left: 40,
            bottom: 100,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/satu.png',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // GAMBAR 2 (ulangan) - tengah kanan (kecil)
          Positioned(
            right: 50,
            top: screenHeight * 0.5,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/dua.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // GAMBAR 3 (ulangan) - atas tengah (sangat kecil)
          Positioned(
            left: screenWidth * 0.45,
            top: 120,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/tiga.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // GAMBAR 4 (ulangan) - kiri atas (kecil)
          Positioned(
            left: 100,
            top: 180,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/empat.png',
                width: 65,
                height: 65,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ===== KONTEN UTAMA =====
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: screenHeight - MediaQuery.of(context).padding.top,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // LOGO UTAMA (tulisan PUDDINGKU! SMART SYSTEM)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: screenHeight * 0.2),
                      child: Image.asset(
                        'assets/images/tulisan_awal.png',
                        width: screenWidth * 0.85,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const Spacer(flex: 1),

                    // GAMBAR KUE (logo puding)
                    SizedBox(
                      height: screenHeight * 0.35,
                      child: Image.asset(
                        'assets/images/logo_puding.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // TOMBOL GET STARTED
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Container(
                        width: screenWidth * 0.75,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A1F0F),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
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