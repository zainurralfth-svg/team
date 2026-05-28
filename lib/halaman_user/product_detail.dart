import 'package:flutter/material.dart';
import '../Backend/api_service.dart'; // Pastikan path ini benar
import '../Core/Colour.dart'; 

class ProductDetailPage extends StatefulWidget {
  final String idMenu;
  final String name;
  final String price;
  final String image;
  final String description;
  final String stok; // Tetap dikirim, sebagai cadangan/awal

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
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  
  // Variabel untuk stok real-time
  int _stokRealtime = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal pakai stok dari widget, sambil nunggu API
    _stokRealtime = int.tryParse(widget.stok) ?? 0;
    
    // Langsung cek ke database begitu halaman dibuka
    _fetchStokTerbaru();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  // FUNGSI INI YANG AKAN NGE-PING DATABASE
  Future<void> _fetchStokTerbaru() async {
    try {
      final data = await ApiService.getMenu(); 
      
      // TAMBAHAN: Kita print buat ngintip datanya di terminal VS Code
      print("DATA API YANG DITERIMA: $data");
      
      final produk = data.firstWhere((p) => p['id_produk'].toString() == widget.idMenu);
      
      // TAMBAHAN: Print stok spesifik produk ini
      print("STOK PRODUK ${produk['nama_produk']} ADALAH: ${produk['stok']}");
      
      if (mounted) {
        setState(() {
          _stokRealtime = int.tryParse(produk['stok'].toString()) ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("ERROR FETCH STOK: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'product-${widget.name}',
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.40,
              child: Image.network(
                widget.image,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: AppColors.bgInput,
                  child: const Center(child: Icon(Icons.cake, size: 80, color: AppColors.primaryDark)),
                ),
              ),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: AppColors.textDark, height: 1.2)),
                      const SizedBox(height: 10),
                      Text(widget.description, textAlign: TextAlign.justify, style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 13, color: AppColors.textBrown, height: 1.65)),
                      const SizedBox(height: 18),
                      const Text('Harga', style: TextStyle(fontFamily: 'Signika Negative', fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: AppColors.textDark)),
                      Text(widget.price, style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 15, color: AppColors.textBrown)),
                      const SizedBox(height: 14),
                      const Text('Stock', style: TextStyle(fontFamily: 'Signika Negative', fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: AppColors.textDark)),
                      const SizedBox(height: 4),

                      // DISPLAY STOK LIVE
                      _buildStokDisplay(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 22, bottom: 18),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.textDark, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                ),
                child: const Text('Back', style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget terpisah biar kodenya rapi
  Widget _buildStokDisplay() {
    if (_isLoading) {
      return const Text("Memuat stok...", style: TextStyle(fontFamily: 'Signika Negative', fontSize: 14, color: Colors.grey));
    }
    
    final bool tersedia = _stokRealtime > 0;
    return Text.rich(
      TextSpan(
        text: '$_stokRealtime ',
        style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 15, color: AppColors.textBrown),
        children: [
          TextSpan(
            text: tersedia ? '(tersedia)' : '(habis)',
            style: TextStyle(
              fontFamily: 'Signika Negative',
              fontStyle: FontStyle.italic,
              color: tersedia ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}