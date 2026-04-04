import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definisi Warna sesuai request
    const Color colorBg = Color(0xFFF2D7A6);
    const Color colorPrimary = Color(0xFFC9792B);
    const Color colorCard = Color(0xFFF7E6C4);
    const Color colorBorder = Color(0xFF7A4A21);
    const Color colorText = Color(0xFF3A1F0F);

    return Scaffold(
      backgroundColor: colorBg,
      // 1. Header / AppBar
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/tulisanmenu.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => const Text(
            "PUDDINGKU",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: colorCard,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart, color: colorPrimary),
                onPressed: () => Navigator.pushNamed(context, '/keranjang'),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Pattern
          Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/tiramisu.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. FOTO COOKIES DI ATAS SEARCH PRODUK (BANNER) - PAKAI ya.png
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/images/banner cookies.png', // ✅ PAKAI ya.png
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading banner: $error');
                          return Container(
                            color: colorPrimary.withOpacity(0.3),
                            child: const Center(
                              child: Text(
                                'Banner Cookies',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search Produk",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: colorBorder, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: colorBorder, width: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Kategori Produk
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildCategoryButton('Pudding', false, colorPrimary, colorCard, colorBorder),
                      _buildCategoryButton('Dessert', false, colorPrimary, colorCard, colorBorder),
                      _buildCategoryButton('Cake', false, colorPrimary, colorCard, colorBorder),
                      _buildCategoryButton('Brownies', false, colorPrimary, colorCard, colorBorder),
                      _buildCategoryButton('Cookies', true, colorPrimary, colorCard, colorBorder),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 5. Judul Section
                  const Center(
                    child: Text(
                      'COOKIES',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorText,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 6. Grid Produk
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (context, index) {
                      // Data produk berbeda untuk setiap index
                      List<Map<String, String>> products = [
                        {'name': 'Cookies Choco Chips', 'price': 'Rp. 5.000', 'image': 'chocochips.png'},
                        {'name': 'Cookies Oat Milk', 'price': 'Rp. 5.000', 'image': 'oat_milk.png'},
                        {'name': 'Cookies Red Velvet', 'price': 'Rp. 5.000', 'image': 'red_velvet.png'},
                        {'name': 'Cookies Chocolate', 'price': 'Rp. 5.000', 'image': 'chocolate.png'},
                        {'name': 'Cookies Oreo', 'price': 'Rp. 5.000', 'image': 'oreo.png'},
                      ];
                      
                      return _buildProductCard(
                        context,
                        products[index]['name']!,
                        products[index]['price']!,
                        products[index]['image']!,
                        colorCard,
                        colorBorder,
                        colorText,
                        colorPrimary,
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // 7. Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: colorPrimary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.receipt_long, "Pesanan"),
            _buildBottomNavItem(Icons.cake, "Produk"),
          ],
        ),
      ),
    );
  }

  // Widget Button Kategori
  Widget _buildCategoryButton(String label, bool isActive, Color primary, Color card, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? primary : card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : border,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget Card Produk
  Widget _buildProductCard(BuildContext context, String name, String price, String img, Color cardColor, Color borderColor, Color textColor, Color btnColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                image: DecorationImage(
                  image: AssetImage('assets/images/$img'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                const SizedBox(height: 4),
                Text(price, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Details $name')),
                        );
                      },
                      child: const Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 10,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$name ditambahkan ke keranjang')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "+ Order",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Item Bottom Nav
  Widget _buildBottomNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}