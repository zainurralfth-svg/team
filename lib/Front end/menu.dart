import 'package:flutter/material.dart';

// =====================================================================
// MenuPage - Halaman utama untuk menampilkan menu produk
// Menggunakan StatefulWidget agar kategori bisa berpindah
// =====================================================================
class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  // State: index kategori yang sedang aktif (default = 4 / Cookies)
  int _selectedIndex = 4;

  // Urutan nama kategori
  final List<String> _categories = [
    'Pudding',
    'Dessert',
    'Patite Cake',
    'Brownies',
    'Cookies',
  ];

  // Banner per kategori
  final List<String> _banners = [
    'banner pudding.png',
    'banner dessert.png',
    'banner cake.png',
    'banner brownies.png',
    'banner cookies.png',
  ];

  // Data produk per kategori
  final List<List<Map<String, String>>> _allProducts = [
    // Pudding (8 produk)
    [
      {'name': 'Silky Pudding Taro',     'price': 'Rp. 4.000', 'image': 'Silky Pudding Taro.png'},
      {'name': 'Tripple Choco Pudding',    'price': 'Rp. 4.000', 'image': 'Tripple Choco Pudding.png'},
      {'name': 'Silky Pudding Chocolate', 'price': 'Rp. 4.000', 'image': 'Silky Pudding Chocolate.png'},
      {'name': 'Silky Pudding Manggo',     'price': 'Rp. 4.000', 'image': 'Silky Pudding Mango.png'},
      {'name': 'Silky Pudding Banana',       'price': 'Rp. 4.000', 'image': 'Silky Pudding Banana.png'},
      {'name': 'Silky Pudding Bubble Gum',     'price': 'Rp. 4.000', 'image': 'Silky Pudding Bubble Gum.png'},
      {'name': 'Silky Pudding Strawberry',      'price': 'Rp. 4.000', 'image': 'Silky Pudding Strawberry.png'},
      {'name': 'Silky Pudding Leci',    'price': 'Rp. 4.000', 'image': 'Silky Pudding Leci.png'},
    ],
    // Dessert (6 produk)
    [
      {'name': 'Dessert Box Banafe',      'price': 'Rp. 20.000', 'image': 'Dessert Box Banafe.png'},
      {'name': 'Cheese Cuit Strawberry',     'price': 'Rp. 18.000', 'image': 'Cheese Cuit Strawberry.png'},
      {'name': 'Death By Chocolate', 'price': 'Rp. 18.000', 'image': 'Death By Chocolate.png'},
      {'name': 'Milk Bath Chocolate',       'price': 'Rp. 20.000', 'image': 'Milk Bath Chocolate.png'},
      {'name': 'Milk Bath Keju',       'price': 'Rp. 20.000', 'image': 'Milk Bath Keju.png'},
      {'name': 'Milk Bun',    'price': 'Rp. 20.000', 'image': 'Milk Bun.png'},
    ],
    // Cake (8 produk)
    [
      {'name': 'Mango Mouse Cake',   'price': 'Rp. 15.000', 'image': 'Mango Mouse Cake.png'},
      {'name': 'Cookies and Cream Mouse Cake',    'price': 'Rp. 15.000', 'image': 'Cookies and  Cream Mouse.png'},
      {'name': 'Peach Mouse Cake', 'price': 'Rp. 15.000', 'image': 'Peach Mouse Cake.png'},
      {'name': 'Taro Mouse Cake',        'price': 'Rp. 15.000', 'image': 'Taro Mouse Cake.png'},
      {'name': 'Strawberry Mouse Cake',    'price': 'Rp. 15.000', 'image': 'Strawberry Petite Cake.png'},
      {'name': 'Tiramisu Mouse Cake',      'price': 'Rp. 15.000', 'image': 'Tiramisu Mouse Cake.png'},
      {'name': 'Matcha Mouse Cake',  'price': 'Rp. 15.000', 'image': 'Matcha Mouse Cake.png'},
      {'name': 'Strawberry Short Cake',        'price': 'Rp. 15.000', 'image': 'Strawberry Mouse Cake.png'},
    ],
    // Brownies (3 produk)
    [
      {'name': 'Browkies',      'price': 'Rp. 12.000', 'image': 'Browkies.png'},
      {'name': 'Brownie Burn Cheese Cake', 'price': 'Rp. 15.000', 'image': 'Brownie Burn Cheesecake.png'},
      {'name': 'Brownies Bites',         'price': 'Rp. 15.000', 'image': 'Brownies Bites.png'},
    ],
    // Cookies (5 produk)
    [
      {'name': 'Cookies Choco Chips', 'price': 'Rp. 5.000', 'image': 'chocochips.png'},
      {'name': 'Cookies Oat Milk',    'price': 'Rp. 5.000', 'image': 'oat_milk.png'},
      {'name': 'Cookies Red Velvet',  'price': 'Rp. 5.000', 'image': 'red_velvet.png'},
      {'name': 'Cookies Chocolate',   'price': 'Rp. 5.000', 'image': 'chocolate.png'},
      {'name': 'Cookies Oreo',        'price': 'Rp. 5.000', 'image': 'oreo.png'},
    ],
  ];

  // Fungsi ganti kategori saat tombol ditekan
  void _onCategoryTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color colorBg      = Color(0xFFF2D7A6);
    const Color colorPrimary = Color(0xFFC9792B);
    const Color colorCard    = Color(0xFFF7E6C4);
    const Color colorBorder  = Color(0xFF7A4A21);
    const Color colorText    = Color(0xFF3A1F0F);

    final String activeBanner                      = _banners[_selectedIndex];
    final String activeName                        = _categories[_selectedIndex];
    final List<Map<String, String>> activeProducts = _allProducts[_selectedIndex];

    // Ambil lebar layar untuk hitung lebar tombol kategori
    final double screenWidth = MediaQuery.of(context).size.width;
    // Total padding kiri kanan halaman = 16 + 16 = 32
    // Jarak antar 5 tombol = 4 celah x 8px = 32
    // Lebar 1 tombol = (screenWidth - 32 - 32) / 5
    final double categoryBtnWidth = (screenWidth - 32 - 32) / 5;

    return Scaffold(
      backgroundColor: colorBg,

      // AppBar
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/tulisanmenu.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => const Text(
            'PUDDINGKU',
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
          // Background pattern transparan
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Banner - berubah sesuai kategori aktif
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/$activeBanner',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: colorPrimary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Banner $activeName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Produk',
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
                  const SizedBox(height: 16),

                  // ==============================================================
                  // TOMBOL KATEGORI
                  // Pakai Row + SizedBox dengan lebar dihitung dari lebar layar
                  // agar semua tombol pas penuh 1 baris & ukurannya sama rata
                  // ==============================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_categories.length, (index) {
                      final bool isActive = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () => _onCategoryTap(index),
                        child: SizedBox(
                          // Lebar tombol dihitung otomatis dari lebar layar
                          width: categoryBtnWidth,
                          height: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isActive ? colorPrimary : colorCard,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: colorBorder,
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: colorPrimary.withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                _categories[index],
                                style: TextStyle(
                                  color: isActive ? Colors.white : colorBorder,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Judul Kategori Aktif
                  Center(
                    child: Text(
                      activeName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorText,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid Produk - jumlah item sesuai kategori aktif
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final product = activeProducts[index];
                      return _buildProductCard(
                        context,
                        product['name']!,
                        product['price']!,
                        product['image']!,
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

      // Bottom Navigation Bar
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
            _buildBottomNavItem(Icons.receipt_long, 'Pesanan'),
            _buildBottomNavItem(Icons.cake, 'Produk'),
          ],
        ),
      ),
    );
  }

  // Widget kartu produk
  Widget _buildProductCard(
    BuildContext context,
    String name,
    String price,
    String img,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color btnColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.asset(
                'assets/images/$img',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: btnColor.withOpacity(0.2),
                  child: Center(
                    child: Icon(Icons.image, color: btnColor, size: 40),
                  ),
                ),
              ),
            ),
          ),
          // Info produk
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Details
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Details $name')),
                        );
                      },
                      child: const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 10,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    // Tombol + Order
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
                          '+ Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget item bottom nav
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