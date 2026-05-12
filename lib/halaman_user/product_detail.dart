import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // IMPORT GUDANG WARNA (Palet 14 Warna Baru)

class ProductDetailPage extends StatefulWidget {
  // Parameter yang diterima dari halaman menu
  final String idMenu;
  final String name;
  final String price;
  final String image;
  final String description;
  final String stok;

  const ProductDetailPage({
    super.key,
    required this.idMenu,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.stok,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  // Controller untuk mengatur animasi
  late AnimationController _controller;

  // Animasi fade: konten muncul dari transparan ke terlihat
  late Animation<double> _fadeAnim;

  // Animasi slide: konten bergerak dari bawah ke posisi normal
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi dengan durasi 500ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Fade: dari 0 (transparan) ke 1 (terlihat penuh)
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Slide: konten bergerak dari sedikit di bawah (0.15) ke posisi asli (0)
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Jalankan animasi saat halaman dibuka
    _controller.forward();
  }

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar tidak memory leak
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Pakai background utama krem
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // =============================================
          // FOTO PRODUK — mengisi 40% tinggi layar
          // Hero: animasi transisi gambar dari halaman menu ke sini
          // =============================================
          Hero(
            tag: 'product-${widget.name}',
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.40,
              child: Image.network(
                widget.image,
                fit: BoxFit.cover,
                // Tampilkan icon jika gambar gagal dimuat
                errorBuilder: (c, e, s) => Container(
                  color: AppColors.bgInput, // Placeholder gambar error pakai warna input abu-krem
                  child: const Center(
                    child: Icon(Icons.cake, size: 80, color: AppColors.primaryDark), // Icon pakai oranye gelap
                  ),
                ),
              ),
            ),
          ),

          // =============================================
          // KONTEN BAWAH — nama, deskripsi, harga, stok
          // Dibungkus FadeTransition + SlideTransition
          // supaya muncul dengan animasi saat halaman dibuka
          // =============================================
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim, // animasi fade in
              child: SlideTransition(
                position: _slideAnim, // animasi geser dari bawah
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Nama produk — bold italic sesuai desain
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textDark, // Pakai teks gelap
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Deskripsi produk — rata kanan kiri
                      Text(
                        widget.description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textBrown, // Pakai teks coklat
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Label Harga
                      const Text(
                        'Harga',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textDark, // Pakai teks gelap
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Nilai harga dari halaman menu
                      Text(
                        widget.price,
                        style: const TextStyle(fontSize: 15, color: AppColors.textBrown), // Pakai teks coklat
                      ),
                      const SizedBox(height: 14),

                      // Label Stock
                      const Text(
                        'Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textDark, // Pakai teks gelap
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Nilai stok + keterangan tersedia/habis
                      // Jika stok > 0 tampil hijau "(tersedia)", jika 0 tampil merah "(habis)"
                      Text.rich(
                        TextSpan(
                          text: '${widget.stok} ',
                          style: const TextStyle(fontSize: 15, color: AppColors.textBrown), // Pakai teks coklat
                          children: [
                            TextSpan(
                              text: (int.tryParse(widget.stok) ?? 0) > 0
                                  ? '(tersedia)'
                                  : '(habis)',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: (int.tryParse(widget.stok) ?? 0) > 0
                                    ? AppColors.success // Pakai warna hijau seragam
                                    : AppColors.error,    // Pakai warna merah seragam
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =============================================
          // TOMBOL BACK — pojok kanan bawah
          // Kembali ke halaman menu sebelumnya
          // =============================================
          Padding(
            padding: const EdgeInsets.only(right: 22, bottom: 18),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark, // Pakai teks gelap
                  side: const BorderSide(color: AppColors.textDark, width: 1.5), // Pakai border gelap
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}