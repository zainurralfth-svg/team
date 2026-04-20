import 'package:flutter/material.dart';
import '../Backend/api_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String idMenu;
  final String name;
  final String price;
  final String image;
  final String description;

  const ProductDetailPage({
    super.key,
    required this.idMenu,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _quantity = 1;
  String _selectedSize = 'Large';
  
  final String currentUserId = "1"; 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _masukkanKeKeranjang() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memasukkan pesanan...'), duration: Duration(milliseconds: 500)));
    var response = await ApiService.tambahKeranjang(currentUserId, widget.idMenu, _quantity);

    if (response['status'] == 'sukses') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.name} ($_quantity) berhasil ditambah! 🛒'), backgroundColor: Colors.green));
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${response['pesan']}'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color colorBg = Color(0xFFF2D7A6);
    const Color colorPrimary = Color(0xFFC9792B);
    const Color colorCard = Color(0xFFF7E6C4);
    const Color colorBorder = Color(0xFF7A4A21);
    const Color colorText = Color(0xFF3A1F0F);

    return Scaffold(
      backgroundColor: colorBg,
      body: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'product-${widget.name}',
                child: SizedBox(
                  width: double.infinity, height: MediaQuery.of(context).size.height * 0.45,
                  child: Image.network(widget.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: colorPrimary.withOpacity(0.3), child: const Center(child: Icon(Icons.cake, color: colorPrimary, size: 80)))),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8, left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: colorText)),
                ),
              ),
            ],
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: colorBg),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: colorCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: colorBorder)),
                              child: Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.remove, color: colorPrimary), onPressed: () { if (_quantity > 1) setState(() => _quantity--); }),
                                  Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(icon: const Icon(Icons.add, color: colorPrimary), onPressed: () => setState(() => _quantity++)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorText)),
                        const SizedBox(height: 8),
                        Text(widget.description, style: TextStyle(fontSize: 14, color: colorText.withOpacity(0.8), height: 1.5)),
                        const SizedBox(height: 20),
                        const Text('Pilih Ukuran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorText)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Small', 'Large', 'XL'].map((size) {
                            final bool isSelected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = size),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(color: isSelected ? colorPrimary : colorCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: colorBorder)),
                                child: Text(size, style: TextStyle(color: isSelected ? Colors.white : colorBorder, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _masukkanKeKeranjang, 
                            style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            child: Text('+ Masukkan Keranjang  •  ${widget.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
}