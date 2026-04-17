import 'package:flutter/material.dart';
import '../Core/Colour.dart'; 

class BuktiPemesanan extends StatelessWidget {
  const BuktiPemesanan({super.key});

  @override
  Widget build(BuildContext context) {
    // TANGKAP DATA DARI HALAMAN SEBELUMNYA
    final Map<String, dynamic>? dataPesanan = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Ambil variabel nama dan telepon. Kalau tidak ada, defaultnya "Dono" dan "0812..."
    final String namaTampil = dataPesanan?['nama'] ?? 'Dono';
    final String telpTampil = dataPesanan?['telp'] ?? '0812-3456-7890';

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5B9), 
      body: Stack(
        children: [
          // ==========================================
          // 1. ELEMEN DEKORATIF BACKGROUND
          // ==========================================
          Positioned(
            right: -20, top: 50,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/dua.png', width: 150),
            ),
          ),
          Positioned(
            left: -30, top: 150,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/satu.png', width: 120),
            ),
          ),
          Positioned(
            right: 40, bottom: 200,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/tiga.png', width: 100),
            ),
          ),
          Positioned(
            left: -10, bottom: 100,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/empat.png', width: 160),
            ),
          ),

          // ==========================================
          // 2. KONTEN UTAMA (STRUK PEMESANAN)
          // ==========================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        // Ikon Centang Hijau
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8DE88D), 
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.check, color: Colors.green, size: 50),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ID Pesanan
                        const Text(
                          '#e1234',
                          style: TextStyle(
                            color: Color(0xFFD27F30),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Judul Status
                        const Text(
                          'CEK OUT BERHASIL',
                          style: TextStyle(
                            color: Color(0xFFD27F30),
                            fontSize: 24,
                            fontFamily: 'Tai Heritage Pro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Garis Pembatas 1
                        const Divider(color: Colors.black54, thickness: 1),
                        const SizedBox(height: 15),

                        // Data Diri Pemesan (SEKARANG DINAMIS)
                        _buildInfoRow('Nama', ':', namaTampil),
                        const SizedBox(height: 10),
                        _buildInfoRow('No Telp', ':', telpTampil),
                        const SizedBox(height: 15),

                        // Garis Pembatas 2
                        const Divider(color: Colors.black54, thickness: 1),
                        const SizedBox(height: 15),

                        // List Barang Pesanan
                        _buildProductRow('Brownie Burnt Cheescake', '2x', '36.000'),
                        const SizedBox(height: 10),
                        _buildProductRow('Death By Chocolate', '1x', '18.000'),
                        const SizedBox(height: 30), 

                        // Garis Pembatas Bawah
                        const Divider(color: Colors.black54, thickness: 1),
                        const SizedBox(height: 10),

                        // Total Harga
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Total',
                              style: TextStyle(
                                color: Color(0xFFD27F30),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '54.000',
                              style: TextStyle(
                                color: Color(0xFFD27F30),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ==========================================
      // 3. BOTTOM NAVIGATION BAR
      // ==========================================
      bottomNavigationBar: Container(
        color: const Color(0xFFD27F30),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCustomNavItem('assets/images/icon_pesanan.png', 'Pesanan'),
            _buildCustomNavItem('assets/images/icon_produk.png', 'Produk'),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // WIDGET BANTUAN (Helper)
  // ----------------------------------------------------

  Widget _buildInfoRow(String label, String separator, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD27F30),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          separator,
          style: const TextStyle(color: Color(0xFFD27F30), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD27F30),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductRow(String nama, String qty, String harga) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            nama,
            style: const TextStyle(
              color: Color(0xFFD27F30),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            qty,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD27F30),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            harga,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFD27F30),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomNavItem(String imagePath, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Image.asset(imagePath, width: 30, height: 30, errorBuilder: (context, error, stackTrace) {
               return const Icon(Icons.image, color: Colors.grey); 
            }),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Tai Heritage Pro',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}