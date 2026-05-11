import 'package:flutter/material.dart';
import 'package:puddingku_smart_system/main.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; // Palet 14 Warna Baru
import 'profil_pengguna.dart';
import 'konfirmasipesanan.dart'; // Pastikan file ini sudah ada
import 'package:shared_preferences/shared_preferences.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  String currentUserId = "0";

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchCart();
  }

  // Fungsi untuk mengambil ID dari brankas memori HP
  Future<void> _loadUserIdAndFetchCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUserId = prefs.getString('id_user') ?? "0";
      });
    }
    _fetchCartData(); // Setelah ID dapat, baru ambil data keranjang ke XAMPP
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _fetchCartData() async {
    try {
      final data = await ApiService.getKeranjang(currentUserId);
      setState(() {
        _cartItems = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateJumlah(String idProduk, int delta) async {
    final item = _cartItems.firstWhere(
      (e) => e['id_produk'].toString() == idProduk,
    );
    int jumlahSekarang = int.tryParse(item['jumlah'].toString()) ?? 1;
    if (delta == -1 && jumlahSekarang <= 1) return;

    setState(() => _isLoading = true);
    final response = await ApiService.tambahKeranjang(
      currentUserId,
      idProduk,
      delta,
    );
    if (response['status'] == 'sukses') {
      await _fetchCartData();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: ${response['pesan']}")));
    }
  }

  void _hapusItem(String idProduk) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur hapus memerlukan api_hapus.php")),
    );
  }

  int get _totalHarga {
    int total = 0;
    for (var item in _cartItems) {
      String hargaStr = item['harga'].toString().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      int harga = int.tryParse(hargaStr) ?? 0;
      int jumlah = int.tryParse(item['jumlah'].toString()) ?? 0;
      total += (harga * jumlah);
    }
    return total;
  }

  int get _totalItem {
    int total = 0;
    for (var item in _cartItems) {
      total += int.tryParse(item['jumlah'].toString()) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Background krem dari Colour.dart
      appBar: AppBar(
        backgroundColor: AppColors.primary, // Diseragamkan pakai warna utama oranye coklat
        elevation: 0,
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 28,
            fontFamily: 'Oleo Script',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _cartItems.isEmpty
          ? const Center(
              child: Text(
                "Keranjangmu masih kosong 🛒",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchCartData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pesanan',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return _buildCartCard(
                          item['id_produk'].toString(),
                          item['nama_produk'] ?? 'Tanpa Nama',
                          'Rp ${item['harga']}',
                          int.tryParse(item['jumlah'].toString()) ?? 1,
                          Uri.encodeFull(
                            "${ApiService.baseUrl}/uploads/${item['gambar']}",
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Catatan Pesanan',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Tambahkan Catatan (opsional)',
                          hintStyle: TextStyle(color: AppColors.textHint),
                          prefixIcon: Icon(
                            Icons.edit_note,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow, // Panggil shadow dari Colour.dart
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_totalItem Item',
                                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                              ),
                              const Text(
                                'Subtotal',
                                style: TextStyle(fontSize: 14, color: AppColors.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Rp $_totalHarga',
                            style: const TextStyle(
                              color: AppColors.primary, // Warna oranye utama untuk harga
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (_cartItems.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const KonfirmasiPage(),
                                settings: RouteSettings(
                                  arguments: {
                                    'items': _cartItems,
                                    'total': _totalHarga,
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 240,
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppColors.accent, // Warna kuning aksen untuk tombol checkout
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColors.textDark), // Border gelap tegas
                          ),
                          child: const Center(
                            child: Text(
                              'Konfirmasi Pesanan',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.primary, // Warna bottom nav oranye utama
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/cek_pesanan');
              },
              child: _buildBottomNavItem(Icons.receipt_long, 'Pesanan'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: _buildBottomNavItem(Icons.cake, 'Produk'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HalamanProfil(),
                  ),
                );
              },
              child: _buildBottomNavItem(Icons.person, 'Profil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartCard(
    String idProduk,
    String nama,
    String harga,
    int jumlah,
    String imgUrl,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow, // Ganti ke shadow standar Colour.dart
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imgUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 70, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  harga,
                  style: const TextStyle(
                    color: AppColors.primary, // Oranye utama
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _updateJumlah(idProduk, -1),
                      child: _buildQtyBtn('-'),
                    ),
                    SizedBox(width: 30, child: Center(child: Text('$jumlah', style: const TextStyle(color: AppColors.textDark)))),
                    GestureDetector(
                      onTap: () => _updateJumlah(idProduk, 1),
                      child: _buildQtyBtn('+'),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _hapusItem(idProduk),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error, // Ganti ikon tempat sampah jadi merah error Colour.dart
                        size: 24,
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

  Widget _buildQtyBtn(String title) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: AppColors.bgInput, // Warna background tombol +/- pakai abu dari bgInput
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textWhite),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textWhite, fontSize: 12),
          ),
        ],
      ),
    );
  }
}