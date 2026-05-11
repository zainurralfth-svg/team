import 'package:flutter/material.dart';
import '../halaman_user/profil_pengguna.dart'; // Pastikan import halaman profilnya
import '../Core/Colour.dart'; // Import AppColors (14 Palet Baru)

class BuktiPemesanan extends StatelessWidget {
  const BuktiPemesanan({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. TANGKAP DATA BORONGAN DARI KONFIRMASI PESANAN
    final Map<String, dynamic>? dataPesanan = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // 2. PECAH DATANYA (Kasih nilai default kalau misal kosong)
    final String kodeResi = dataPesanan?['kode_resi'] ?? '#PUD0000';
    final String namaTampil = dataPesanan?['nama'] ?? 'Pelanggan';
    final String telpTampil = dataPesanan?['telp'] ?? '-';
    final int totalHarga = dataPesanan?['total'] ?? 0;
    final List<dynamic> items = dataPesanan?['items'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Menggunakan background krem utama
      body: Stack(
        children: [
          // ==========================================
          // ELEMEN DEKORATIF BACKGROUND
          // ==========================================
          Positioned(right: -20, top: 50, child: Opacity(opacity: 0.15, child: Image.asset('assets/images/dua.png', width: 150))),
          Positioned(left: -30, top: 150, child: Opacity(opacity: 0.15, child: Image.asset('assets/images/satu.png', width: 120))),
          Positioned(right: 40, bottom: 200, child: Opacity(opacity: 0.15, child: Image.asset('assets/images/tiga.png', width: 100))),
          Positioned(left: -10, bottom: 100, child: Opacity(opacity: 0.15, child: Image.asset('assets/images/empat.png', width: 160))),

          // ==========================================
          // KONTEN UTAMA (STRUK PEMESANAN)
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
                      color: AppColors.textWhite, // Latar struk putih
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 15, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        // Ikon Centang Hijau
                        Container(
                          width: 80, height: 80,
                          // Menggunakan warna sukses (hijau) dengan tingkat transparansi 20% untuk background lingkarannya
                          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Center(child: Icon(Icons.check, color: AppColors.success, size: 50)),
                        ),
                        const SizedBox(height: 15),

                        // ID Pesanan (Dinamis dari Database)
                        Text(
                          kodeResi,
                          style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // Judul Status
                        const Text(
                          'CEK OUT BERHASIL',
                          style: TextStyle(color: AppColors.primary, fontSize: 24, fontFamily: 'Tai Heritage Pro', fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 20),

                        const Divider(color: Colors.black54, thickness: 1),
                        const SizedBox(height: 15),

                        // Data Diri Pemesan (DINAMIS)
                        _buildInfoRow('Nama', ':', namaTampil),
                        const SizedBox(height: 10),
                        _buildInfoRow('No Telp', ':', telpTampil),
                        const SizedBox(height: 15),

                        const Divider(color: Colors.black54, thickness: 1),
                        const SizedBox(height: 15),

                        // ==========================================
                        // LIST BARANG (DINAMIS MELOOPING KERANJANG)
                        // ==========================================
                        ...items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _buildProductRow(
                              item['nama_produk'] ?? 'Produk', 
                              '${item['jumlah']}x', 
                              '${item['harga']}'
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 20), 

                        const Divider(color: Colors.black54, thickness: 1),
                        const SizedBox(height: 10),

                        // Total Harga
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: AppColors.textBrown, // Teks warna coklat tua
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              totalHarga.toString(), 
                              style: const TextStyle(
                                color: AppColors.primary, // Teks harga warna oranye
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
      // BOTTOM NAVIGATION BAR
      // ==========================================
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.primary, // Menggunakan warna utama oranye coklat
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/cek_pesanan'),
              child: _buildBottomNavItem(Icons.receipt_long, 'Pesanan', false, AppColors.primary),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/menu'), // Balik ke menu utama
              child: _buildBottomNavItem(Icons.cake, 'Produk', false, AppColors.primary),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfil())),
              child: _buildBottomNavItem(Icons.person, 'Profil', false, AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BANTUAN
  Widget _buildInfoRow(String label, String separator, String value) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textBrown, fontSize: 16, fontWeight: FontWeight.bold))),
        Text(separator, style: const TextStyle(color: AppColors.textBrown, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 15),
        Expanded(child: Text(value, style: const TextStyle(color: AppColors.textBrown, fontSize: 16, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildProductRow(String nama, String qty, String harga) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: Text(nama, style: const TextStyle(color: AppColors.textBrown, fontSize: 14, fontWeight: FontWeight.bold))),
        Expanded(flex: 1, child: Text(qty, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textBrown, fontSize: 14, fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text(harga, textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textBrown, fontSize: 14, fontWeight: FontWeight.bold))),
      ],
    );
  }

  // ==========================================
  // WIDGET ICON FOOTER
  // ==========================================
  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected, Color activeColor) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.textWhite : Colors.transparent, 
              shape: BoxShape.circle
            ),
            child: Icon(icon, color: isSelected ? activeColor : AppColors.textWhite, size: 24),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}