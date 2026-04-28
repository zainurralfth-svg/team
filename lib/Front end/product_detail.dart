import 'package:flutter/material.dart';
import '../Backend/api_service.dart';

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

  // ID user yang sedang login (sementara hardcode, nanti bisa diganti dinamis)
  final String currentUserId = "1";

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

  // Fungsi untuk menambahkan produk ke keranjang via API
  Future<void> _masukkanKeKeranjang() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memasukkan pesanan...'),
        duration: Duration(milliseconds: 500),
      ),
    );

    // Kirim request ke API dengan jumlah default 1
    var response = await ApiService.tambahKeranjang(currentUserId, widget.idMenu, 1);

    if (response['status'] == 'sukses') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.name} berhasil ditambah! 🛒'),
          backgroundColor: Colors.green,
        ),
      );
      // Kembali ke halaman menu setelah berhasil
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${response['pesan']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna utama halaman detail
    const Color colorBg = Color(0xFFF5E6C8);      // Latar krem
    const Color colorText = Color(0xFF2A1200);     // Teks judul coklat gelap
    const Color colorSubText = Color(0xFF3A2010);  // Teks isi coklat medium

    return Scaffold(
      backgroundColor: colorBg,
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
                  color: const Color(0xFFD6B98A),
                  child: const Center(
                    child: Icon(Icons.cake, size: 80, color: Color(0xFF7A4A21)),
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
                          color: colorText,
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
                          color: colorSubText,
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
                          color: colorText,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Nilai harga dari halaman menu
                      Text(
                        widget.price,
                        style: const TextStyle(fontSize: 15, color: colorSubText),
                      ),
                      const SizedBox(height: 14),

                      // Label Stock
                      const Text(
                        'Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: colorText,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Nilai stok + keterangan tersedia/habis
                      // Jika stok > 0 tampil hijau "(tersedia)", jika 0 tampil merah "(habis)"
                      Text.rich(
                        TextSpan(
                          text: '${widget.stok} ',
                          style: const TextStyle(fontSize: 15, color: colorSubText),
                          children: [
                            TextSpan(
                              text: (int.tryParse(widget.stok) ?? 0) > 0
                                  ? '(tersedia)'
                                  : '(habis)',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: (int.tryParse(widget.stok) ?? 0) > 0
                                    ? Colors.green[700]
                                    : Colors.red,
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
                  foregroundColor: colorText,
                  side: const BorderSide(color: colorText, width: 1.5),
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