import 'package:flutter/material.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; 

class ProductDetailPage extends StatefulWidget {
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
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  
  int _stokRealtime = 0; 
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _stokRealtime = int.tryParse(widget.stok) ?? 0;
    _fetchStokTerbaru();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  Future<void> _fetchStokTerbaru() async {
    try {
      final data = await ApiService.getMenu(); 
      final produk = data.firstWhere((p) => p['id_produk'].toString() == widget.idMenu);
      
      if (mounted) {
        setState(() {
          _stokRealtime = int.tryParse(produk['stok'].toString()) ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
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
      body: Stack(
        children: [
          // 1. GAMBAR PRODUK (FULL HEADER)
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Hero(
              tag: 'product-${widget.name}',
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

          // 2. KONTEN INFO (OVERLAP DI ATAS GAMBAR)
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.40, 
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgUtama,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, -5))
                ],
              ),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    // Tambah padding bawah extra biar konten nggak ketutup tombol back
                    padding: const EdgeInsets.only(top: 30, left: 25, right: 25, bottom: 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NAMA PRODUK & HARGA
                        Text(
                          widget.name, 
                          style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.price, // 👈 UDAH LANGSUNG PAKE DATA DARI MENU.DART, GAK AKAN NOL LAGI
                          style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // INFO STOK (BADGE KEKINIAN)
                        _buildStokDisplay(),

                        const SizedBox(height: 25),
                        const Divider(color: Colors.black12, thickness: 1.5),
                        const SizedBox(height: 15),

                        // DESKRIPSI
                        const Text(
                          'Deskripsi Produk', 
                          style: TextStyle(fontFamily: 'Signika Negative', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.description, 
                          textAlign: TextAlign.justify, 
                          style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 15, color: AppColors.textBrown, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. TOMBOL BACK (MELAYANG DI KANAN BAWAH)
          Positioned(
            bottom: 25,
            right: 25,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgUtama, // Biar ada background dan gak transparan
                foregroundColor: AppColors.textDark,
                side: const BorderSide(color: AppColors.textDark, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                elevation: 4, // Kasih bayangan dikit biar mantap
              ),
              child: const Text('Back', style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET KHUSUS BUAT NAMPILIN STOK
  Widget _buildStokDisplay() {
    if (_isLoading) {
      return const Text("Memuat stok...", style: TextStyle(fontFamily: 'Signika Negative', fontSize: 14, color: Colors.grey));
    }
    
    final bool tersedia = _stokRealtime > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: tersedia ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tersedia ? AppColors.success : AppColors.error, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tersedia ? Icons.check_circle_rounded : Icons.cancel_rounded, 
            size: 18, 
            color: tersedia ? AppColors.success : AppColors.error
          ),
          const SizedBox(width: 8),
          Text(
            tersedia ? 'Sisa Stok: $_stokRealtime' : 'Stok Habis',
            style: TextStyle(
              fontFamily: 'Signika Negative',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: tersedia ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}