import 'package:flutter/material.dart';
import 'product_detail.dart';
import '../Backend/api_service.dart';
import '../halaman_user/profil_pengguna.dart';
import '../Core/Colour.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

import '../Widget/custom_user_navbar.dart'; 

// =============================================
// ANIMASI TRANSISI HALAMAN
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
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;
  List<dynamic> _menuDariDatabase = [];
  bool _isLoading = true;

  int _cartItemCount = 0; 
  List<dynamic> _isiKeranjang = []; 
  
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['Pudding', 'Dessert', 'Cake', 'Brownies', 'Cookies'];
  final List<String> _banners = [
    'banner pudding.png',
    'banner dessert.png',
    'banner cake.png',
    'banner brownies.png',
    'banner cookies.png',
  ];

  String currentUserId = "0";

  @override
  void initState() {
    super.initState();
    _ambilDataMenu();
    _loadUserId(); 
  }

  Future<void> _ambilDataMenu() async {
    try {
      final data = await ApiService.getMenu();
      if (mounted) {
        setState(() {
          _menuDariDatabase = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUserId = prefs.getString('id_user') ?? "0";
      });
      _ambilDataKeranjang(); 
    }
  }

  Future<void> _ambilDataKeranjang() async {
    try {
      final data = await ApiService.getKeranjang(currentUserId);
      if (mounted) {
        setState(() {
          _isiKeranjang = data; 
          _cartItemCount = data.length;
        });
      }
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
    ).then((_) => _ambilDataKeranjang()); 
  }

  @override
  Widget build(BuildContext context) {
    final String activeBanner = _banners[_selectedIndex];
    final String activeName = _categories[_selectedIndex];
    final double screenWidth = MediaQuery.of(context).size.width;
    final double categoryBtnWidth = (screenWidth - 32 - 32) / 5;

    return Scaffold(
      backgroundColor: AppColors.bgUtama, 
      appBar: AppBar(
        backgroundColor: AppColors.primary, 
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/tulisan tampilan awal.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => const Text(
            'PUDDINGKU',
            style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: AppColors.textWhite),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 5),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.bgCard, 
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart, color: AppColors.primary),
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
                        color: AppColors.error, 
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$_cartItemCount',
                        style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 10, fontWeight: FontWeight.bold),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/$activeBanner',
                  width: double.infinity, 
                  height: 180, 
                  fit: BoxFit.fitWidth, 
                  errorBuilder: (c, e, s) => Container(
                    width: double.infinity, height: 180,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.4), borderRadius: BorderRadius.circular(20)),
                    child: Center(child: Text('Banner $activeName', style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _searchController, 
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase(); 
                  });
                },
                style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textDark), 
                decoration: InputDecoration(
                  hintText: 'Search Produk',
                  hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true, fillColor: AppColors.textWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.primaryDark, width: 0.5)), 
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.primaryDark, width: 0.5)),
                ),
              ),
              const SizedBox(height: 16),

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
                          color: isActive ? AppColors.primary : AppColors.bgCard, 
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppColors.primaryDark, width: isActive ? 2 : 1), 
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: TextStyle(fontFamily: 'Signika Negative', color: isActive ? AppColors.textWhite : AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13),
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
                  style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBrown, letterSpacing: 2), 
                ),
              ),
              const SizedBox(height: 16),

              Builder(
                builder: (context) {
                  if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

                  final produkFilter = _menuDariDatabase.where((produk) {
                    final bool cocokKategori = produk['kategori'] == activeName;
                    final String namaProduk = (produk['nama_produk'] ?? produk['nama_menu'] ?? produk['nama'] ?? '').toString().toLowerCase();
                    final bool cocokPencarian = namaProduk.contains(_searchQuery);

                    if (_searchQuery.isNotEmpty) {
                      return cocokPencarian;
                    }
                    return cocokKategori;
                  }).toList();

                  if (produkFilter.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Produk tidak ditemukan.", style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textBrown, fontWeight: FontWeight.bold))));
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
                        AppColors.bgCard, AppColors.primaryDark, AppColors.textBrown, AppColors.primary, 
                      );
                    },
                  );
                }, 
              ), 

            ], 
          ),  
        ),   
      ),    
            
      bottomNavigationBar: CustomUserNavbar(
        currentIndex: 1, 
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/cek_pesanan'); 
          } else if (index == 1) {
            // Biarin kosong
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProfil()));
          }
        },
      ),
    ); 
  }

  Widget _buildProductCard(BuildContext context, String idMenu, String name, String price,
      String imgUrl, String description, String stok,
      Color cardColor, Color borderColor, Color textColor, Color btnColor) {
    
    // Cek jumlah barang di keranjang
    int qtyDiKeranjang = 0;
    for (var item in _isiKeranjang) {
      if (item['id_produk'].toString() == idMenu) {
        qtyDiKeranjang = int.tryParse(item['jumlah'].toString()) ?? 0;
        break;
      }
    }
    int sisaStok = int.tryParse(stok) ?? 0;
    bool isStokHabis = sisaStok <= 0;
    
    // Ganti nama variabel biar logicnya lebih klop sama konsep "Habis Diambil"
    bool isHabisDiambil = qtyDiKeranjang >= sisaStok;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 5, offset: const Offset(0, 3))], 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _goToDetail(context, idMenu, name, price, imgUrl, description, stok),
              child: Hero(
                tag: 'product-$name',
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Image.network(
                        imgUrl,
                        width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: btnColor.withOpacity(0.2), child: Center(child: Icon(Icons.fastfood, color: btnColor, size: 40))),
                      ),
                    ),
                    if (isStokHabis)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Habis',
                            style: TextStyle(
                              fontFamily: 'Signika Negative',
                              color: AppColors.textWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 13, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(price, style: TextStyle(fontFamily: 'Signika Negative', color: textColor.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)), 
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _goToDetail(context, idMenu, name, price, imgUrl, description, stok),
                      child: const Text('Details', style: TextStyle(fontFamily: 'Signika Negative', fontSize: 10, decoration: TextDecoration.underline, color: AppColors.primaryDark, fontWeight: FontWeight.w600)), 
                    ),
                    GestureDetector(
                      onTap: isStokHabis
                          ? () {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$name sedang kehabisan stok 😔', style: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  duration: const Duration(milliseconds: 1800),
                                ),
                              );
                            }
                          : isHabisDiambil
                              ? () {
                                  // Munculin peringatan kalau stok habis karena udah masuk keranjang semua
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Stok udah habis masuk keranjang anda sekarang', style: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      duration: const Duration(milliseconds: 1800),
                                    ),
                                  );
                                }
                              : () async {
                                  // Masukin keranjang kalau aman
                                  var response = await ApiService.tambahKeranjang(currentUserId, idMenu, 1);
                                  if (!mounted) return;
                                  if (response['status'] == 'sukses') {
                                    // Refresh data biar UI langsung update
                                    _ambilDataKeranjang(); 
                                    
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$name ditambahkan pada keranjang! 🛒', style: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        duration: const Duration(milliseconds: 1500),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal: ${response['pesan']}', style: const TextStyle(fontFamily: 'Signika Negative')),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          // Tombol abu-abu kalau stok habis atau udah diambil maksimal ke keranjang
                          color: (isStokHabis || isHabisDiambil) ? Colors.grey.shade400 : btnColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          // PERUBAHAN TEKS: Kalau habis dari sananya ATAU udah habis diambil -> tulis "Habis"
                          (isStokHabis || isHabisDiambil) ? 'Habis' : '+ Order',
                          style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 10, fontWeight: FontWeight.bold),
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
}