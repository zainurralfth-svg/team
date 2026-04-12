import 'package:flutter/material.dart';

// Class ini adalah halaman pertama banget yang dilihat user pas buka aplikasi
class TampilanAwal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. MENGAMBIL UKURAN LAYAR
    // Kode ini pintar! Dia otomatis ngukur lebar dan tinggi HP yang dipakai user.
    // Jadi tampilannya nggak akan gepeng atau kepotong walaupun HP-nya beda-beda.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // 2. MENGGUNAKAN STACK UNTUK NUMPUK DESAIN
      // Kita pakai 'Stack' supaya bisa bikin lapisan desain kayak kue lapis.
      // Lapis paling bawah itu warna background, lalu gambar-gambar pudar, 
      // dan lapis paling atas baru tombol dan logonya.
      body: Stack(
        children: [
          // ==========================================
          // LAPISAN BAWAH: WARNA BACKGROUND GRADASI
          // ==========================================
          // Ini bukan warna solid biasa. Kita pakai 'LinearGradient' supaya warnanya 
          // memudar dari krem/peach di bagian atas HP turun jadi oranye gelap di bawah HP.
          Container(
            width: double.infinity, // Artinya "Lebar selebar layar HP"
            height: double.infinity, // Artinya "Tinggi setinggi layar HP"
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,    // Dimulai dari atas tengah
                end: Alignment.bottomCenter,   // Berakhir di bawah tengah
                colors: [
                  Color(0xFFF7CC98), // Warna krem/peach (Atas)
                  Color(0xFFCE7F31), // Warna oranye gelap (Bawah)
                ],
              ),
            ),
          ),

          // ==========================================
          // LAPISAN TENGAH: ELEMEN DEKORATIF (POLA KUE)
          // ==========================================
          // Kita pakai 'Positioned' buat naruh gambar kecil-kecil ini secara spesifik 
          // pakai koordinat (contoh: letaknya -20 dari kiri, 50 dari atas).
          // 'Opacity' itu buat bikin gambarnya jadi transparan (cuma 15% kelihatan), 
          // jadinya efeknya kayak pola/bayangan kue doang di background.
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

          // ==========================================
          // LAPISAN ATAS: KONTEN UTAMA (LOGO, KUE UTAMA, TOMBOL)
          // ==========================================
          // 'SafeArea' itu pelindung! Dia nahan desain kita supaya nggak ketutupan
          // sama "poni" kamera depan atau bar baterai di HP.
          SafeArea(
            // 'SingleChildScrollView' ini senjata rahasia biar aplikasinya nggak error 
            // kuning-hitam (overflow) kalau layar HP-nya kependekan. Kalau kepanjangan, 
            // user otomatis bisa scroll ke bawah.
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                
                // 'BoxConstraints' ini tugasnya maksa konten minimal setinggi layar HP.
                // Kenapa? Supaya tombol "Get Started" tetep nempel rapi di paling bawah layar, 
                // nggak terbang ngambang di tengah-tengah.
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top,
                ),
                
                // 'Column' buat nyusun elemen dari atas ke bawah
                child: Column(
                  // 'spaceBetween' ini tugasnya bagi jarak merata. Logo otomatis kepepet ke atas, 
                  // Kue otomatis ke tengah, dan Tombol otomatis kepentok ke bawah layar.
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    
                    // --- BAGIAN ATAS: LOGO TULISAN ---
                    Column(
                      children: [
                        const SizedBox(height: 30), // Ngasih jarak kosong sedikit dari atas
                        Image.asset(
                          'assets/images/tulisan_awal.png', 
                          // Lebar logo diatur 65% dari total lebar layar HP (screenWidth * 0.65)
                          // Biar proporsinya tetep cakep di HP gede maupun kecil.
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
                        // Lebar gambar kue diatur setengah layar HP aja (50%)
                        width: screenWidth * 0.50, 
                        fit: BoxFit.contain,
                      ),
                    ),

                    // --- BAGIAN BAWAH: TOMBOL "GET STARTED" ---
                    Column(
                      children: [
                        // 'GestureDetector' bikin kotak yang tadinya diam jadi bisa diklik kayak tombol
                        GestureDetector(
                          onTap: () {
                            // Saat diklik, ini ngasih perintah ke aplikasi buat pindah
                            // navigasi ke halaman login (dengan rute '/masuk').
                            Navigator.pushNamed(context, '/masuk');
                          },
                          child: Container(
                            width: screenWidth * 0.85, // Lebar tombol hampir penuh layar (85%)
                            height: 60, // Tinggi tombol dibuat lumayan besar biar gampang dipencet jempol
                            decoration: BoxDecoration(
                              color: const Color(0xFF220A05), // Warna cokelat gelap pekat mirip dark chocolate
                              borderRadius: BorderRadius.circular(20), // Bikin ujung tombolnya melengkung
                              boxShadow: [
                                // Nambahin efek bayangan di bawah tombol biar keliatan lebih 3D/timbul
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              // Teks tulisan di tengah tombol
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
                        // 'SizedBox' ini cuma buat ngasih bantalan jarak antara tombol 
                        // sama batas paling bawah HP, biar nggak terlalu mepet mentok bawah.
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