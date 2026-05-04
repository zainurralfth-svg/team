import 'package:flutter/material.dart';
import 'product_detail.dart';
import '../Backend/api_service.dart';
import 'halaman_profil.dart';

// =============================================
// ANIMASI TRANSISI HALAMAN — gaya Instagram
// =============================================
PageRoute instagramSlideRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      final fade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      );

      final scaleBack = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut),
      );

      return ScaleTransition(
        scale: scaleBack,
        child: SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        ),
      );
    },
  );
}

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;
  List<dynamic> _menuDariDatabase = [];
  bool _isLoading = true;

  // VARIABEL BARU: Menyimpan jumlah item di keranjang
  int _cartItemCount = 0; 

  final List<String> _categories = ['Pudding', 'Dessert', 'Cake', 'Brownies', 'Cookies'];
  final List<String> _banners = [
    'banner pudding.png',
    'banner dessert.png',
    'banner cake.png',
    'banner brownies.png',
    'banner cookies.png',
  ];

  final String currentUserId = "1";

  @override
  void initState() {
    super.initState();
    _ambilDataMenu();
    _ambilDataKeranjang(); // Ambil jumlah keranjang saat start
  }

  // Fungsi ambil semua data menu dari API
  Future<void> _ambilDataMenu() async {
    try {
      final data = await ApiService.getMenu();
      setState(() {
        _menuDariDatabase = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // FUNGSI BARU: Mengambil jumlah item yang ada di keranjang dari database
  Future<void> _ambilDataKeranjang() async {
    try {
      // Pastikan method getKeranjang tersedia di ApiService Anda
      final data = await ApiService.getKeranjang(currentUserId);
      setState(() {
        _cartItemCount = data.length;
      });
    } catch (e) {
      debugPrint("Gagal mengambil data keranjang: $e");
    }
  }

  void _onCategoryTap(int index) {
    setState(() => _selectedIndex = index);
  }

  void _goToDetail(BuildContext context, String idMenu, String name, String price, String imgUrl, String description, String stok) {
    Navigator.of(context).push(
      instagramSlideRoute(ProductDetailPage(
        idMenu: idMenu,
        name: name,
        price: price,
        image: imgUrl,
        description: description,
        stok: stok,
      )),
    ).then((_) => _ambilDataKeranjang()); // Update angka saat kembali dari detail
  }

  @override
  Widget build(BuildContext context) {
    const Color colorBg = Color(0xFFF2D7A6);
    const Color colorPrimary = Color(0xFFC9792B);
    const Color colorCard = Color(0xFFF7E6C4);
    const Color colorBorder = Color(0xFF7A4A21);
    const Color colorText = Color(0xFF3A1F0F);

    final String activeBanner = _banners[_selectedIndex];
    final String activeName = _categories[_selectedIndex];
    final double screenWidth = MediaQuery.of(context).size.width;
    final double categoryBtnWidth = (screenWidth - 32 - 32) / 5;

    return Scaffold(
      backgroundColor: colorBg,
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
          // =============================================
          // IKON KERANJANG DENGAN BADGE NOTIFIKASI
          // =============================================
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 5),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  backgroundColor: colorCard,
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart, color: colorPrimary),
                    onPressed: () => Navigator.pushNamed(context, '/keranjang').then((_) => _ambilDataKeranjang()),
                  ),
                ),
                if (_cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red, // Warna merah notifikasi
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$_cartItemCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Kategori
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/$activeBanner',
                  width: double.infinity, height: 180, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: double.infinity, height: 180,
                    decoration: BoxDecoration(color: colorPrimary.withOpacity(0.4), borderRadius: BorderRadius.circular(20)),
                    child: Center(child: Text('Banner $activeName', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Produk',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: colorBorder, width: 0.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: colorBorder, width: 0.5)),
                ),
              ),
              const SizedBox(height: 16),

              // Tab Kategori
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_categories.length, (index) {
                  final bool isActive = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => _onCategoryTap(index),
                    child: SizedBox(
                      width: categoryBtnWidth, height: 42,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isActive ? colorPrimary : colorCard,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: colorBorder, width: isActive ? 2 : 1),
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: TextStyle(color: isActive ? Colors.white : colorBorder, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  activeName.toUpperCase(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorText, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 16),

              // Grid Produk
              Builder(
                builder: (context) {
                  if (_isLoading) return const Center(child: CircularProgressIndicator(color: colorPrimary));

                  final produkFilter = _menuDariDatabase
                      .where((produk) => produk['kategori'] == activeName)
                      .toList();

                  if (produkFilter.isEmpty) {
                    return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("Belum ada produk di kategori $activeName.", style: const TextStyle(color: colorText, fontWeight: FontWeight.bold))));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: produkFilter.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final product = produkFilter[index];
                      String idMenu = product['id_produk']?.toString() ?? '';
                      String namaDB = product['nama_produk'] ?? 'Tanpa Nama';
                      String hargaDB = 'Rp ${product['harga']}';
                      String namaFileGambar = product['gambar'] ?? '';
                      String urlGambarLengkap = Uri.encodeFull("${ApiService.baseUrl}/uploads/$namaFileGambar");
                      String deskripsiDB = product['deskripsi'] ?? 'Deskripsi tidak tersedia.';
                      String stokDB = product['stok']?.toString() ?? '0';

                      return _buildProductCard(
                        context, idMenu, namaDB, hargaDB,
                        urlGambarLengkap, deskripsiDB, stokDB,
                        colorCard, colorBorder, colorText, colorPrimary,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: colorPrimary,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/cek_pesanan'),
              child: _buildBottomNavItem(Icons.receipt_long, 'Pesanan', false, colorPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: _buildBottomNavItem(Icons.cake, 'Produk', true, colorPrimary),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfil())),
              child: _buildBottomNavItem(Icons.person, 'Profil', false, colorPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String idMenu, String name, String price,
      String imgUrl, String description, String stok,
      Color cardColor, Color borderColor, Color textColor, Color btnColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _goToDetail(context, idMenu, name, price, imgUrl, description, stok),
              child: Hero(
                tag: 'product-$name',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    imgUrl,
                    width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: btnColor.withOpacity(0.2), child: Center(child: Icon(Icons.fastfood, color: btnColor, size: 40))),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(price, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _goToDetail(context, idMenu, name, price, imgUrl, description, stok),
                      child: const Text('Details', style: TextStyle(fontSize: 10, decoration: TextDecoration.underline, color: Color(0xFF7A4A21), fontWeight: FontWeight.w600)),
                    ),
                    GestureDetector(
                      onTap: () async {
                        var response = await ApiService.tambahKeranjang(currentUserId, idMenu, 1);

                        if (response['status'] == 'sukses') {
                          // UPDATE: Menambah angka notifikasi di ikon keranjang atas
                          setState(() {
                            _cartItemCount++; 
                          });

                          // --- NOTIFIKASI MELAYANG (INFO PRODUK SAJA) ---
                          ScaffoldMessenger.of(context).clearSnackBars(); 
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name ditambahkan pada keranjang! 🛒', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating, // BIKIN MELAYANG
                              margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20), // JARAK DARI BAWAH BIAR GAK KETUTUP FOOTER
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                              duration: const Duration(milliseconds: 1500), // MUNCUL BENTAR AJA
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal: ${response['pesan']}'), 
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                              duration: const Duration(seconds: 2)
                            )
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: btnColor, borderRadius: BorderRadius.circular(10)),
                        child: const Text('+ Order', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected, Color activeColor) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, shape: BoxShape.circle),
            child: Icon(icon, color: isSelected ? activeColor : Colors.white, size: 24),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}