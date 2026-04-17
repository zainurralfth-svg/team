import 'package:flutter/material.dart';

// =====================================================================
// ProductDetail - Halaman detail produk (full page)
// =====================================================================
class ProductDetailPage extends StatefulWidget {
  final String name;
  final String price;
  final String image;

  const ProductDetailPage({
    Key? key,
    required this.name,
    required this.price,
    required this.image,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _quantity = 1;
  bool _isFavorite = false;
  String _selectedSize = 'Large';

  // Data dummy untuk "favorite stats"
  final int _views = 100;
  final double _rating = 4.5;
  final int _likes = 145;

  // Deskripsi per produk (bisa dikembangkan sesuai kebutuhan)
  final Map<String, String> _descriptions = {
    'Cheese Cuit Strawberry':
        'Lapisan crepes tipis berpadu cream vanilla dan potongan strawberry, menghasilkan rasa manis segar yang ringan dan elegan.',
    'default':
        'Produk istimewa kami dibuat dengan bahan-bahan pilihan berkualitas tinggi untuk menghadirkan cita rasa yang tak terlupakan.',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _description {
    return _descriptions[widget.name] ?? _descriptions['default']!;
  }

  @override
  Widget build(BuildContext context) {
    const Color colorBg      = Color(0xFFF2D7A6);
    const Color colorPrimary = Color(0xFFC9792B);
    const Color colorCard    = Color(0xFFF7E6C4);
    const Color colorBorder  = Color(0xFF7A4A21);
    const Color colorText    = Color(0xFF3A1F0F);

    return Scaffold(
      backgroundColor: colorBg,
      body: Column(
        children: [
          // ── Gambar Produk (Hero + Stack tombol back & favorite) ──
          Stack(
            children: [
              // Gambar hero
              Hero(
                tag: 'product-${widget.name}',
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Image.asset(
                    'assets/images/${widget.image}',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: colorPrimary.withOpacity(0.3),
                      child: Center(
                        child: Icon(Icons.cake, color: colorPrimary, size: 80),
                      ),
                    ),
                  ),
                ),
              ),

              // Gradient overlay bawah agar info card menyatu
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorBg.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // Tombol Back
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Color(0xFF3A1F0F)),
                  ),
                ),
              ),

              // Tombol Favorite
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.elasticOut,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isFavorite
                          ? colorPrimary.withOpacity(0.9)
                          : Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.white : colorPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Info Card dengan Slide+Fade Animation ──
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2D7A6),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantity selector + Nama produk
                        Row(
                          children: [
                            // Quantity
                            Container(
                              decoration: BoxDecoration(
                                color: colorCard,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: colorBorder, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _qtyButton(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (_quantity > 1) setState(() => _quantity--);
                                    },
                                    color: colorPrimary,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '$_quantity',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF3A1F0F),
                                      ),
                                    ),
                                  ),
                                  _qtyButton(
                                    icon: Icons.add,
                                    onTap: () => setState(() => _quantity++),
                                    color: colorPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Nama produk
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF3A1F0F),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Deskripsi
                        Text(
                          _description,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorText.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Size
                        const Text(
                          'Size',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF3A1F0F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Small', 'Large', 'XL'].map((size) {
                            final bool isSelected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = size),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected ? colorPrimary : colorCard,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorBorder,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.white : colorBorder,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Favorite Stats
                        const Text(
                          'Favorite',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF3A1F0F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _statBox(Icons.search, '$_views', colorBorder, colorCard),
                            const SizedBox(width: 8),
                            _statBox(Icons.star_border, '$_rating', colorBorder, colorCard),
                            const SizedBox(width: 8),
                            _statBox(Icons.favorite_border, '$_likes', colorBorder, colorCard),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Harga
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Harga\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF3A1F0F),
                                ),
                              ),
                              TextSpan(
                                text: widget.price,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF3A1F0F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol Order
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${widget.name} x$_quantity ditambahkan ke keranjang'),
                                  backgroundColor: colorPrimary,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              '+ Order  •  ${widget.price}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _statBox(IconData icon, String value, Color borderColor, Color cardColor) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: borderColor, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: borderColor,
            ),
          ),
        ],
      ),
    );
  }
}


// =====================================================================
// PATCH untuk MenuPage - ganti bagian _buildProductCard
// Tambahkan Hero tag pada gambar dan navigasi ke ProductDetailPage
// dengan animasi Instagram-style (slide up + fade)
// =====================================================================

// Di dalam _buildProductCard, ganti bagian Image.asset menjadi:
//
//   Hero(
//     tag: 'product-$name',
//     child: Image.asset(...),
//   )
//
// Dan ganti GestureDetector tombol "Details" menjadi:
//
//   GestureDetector(
//     onTap: () {
//       Navigator.of(context).push(
//         _instagramSlideRoute(
//           ProductDetailPage(name: name, price: price, image: img),
//         ),
//       );
//     },
//     child: const Text('Details', ...),
//   )
//
// Tambahkan fungsi helper _instagramSlideRoute di luar class atau sebagai
// fungsi top-level:

PageRoute _instagramSlideRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Slide dari bawah ke atas (Instagram-style)
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      // Fade in
      final fade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      );

      // Halaman lama mengecil sedikit (seperti Instagram Stories)
      final scaleBack = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut),
      );

      return ScaleTransition(
        scale: scaleBack,
        child: SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: fade,
            child: child,
          ),
        ),
      );
    },
  );
}