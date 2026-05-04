import 'package:flutter/material.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart';
import 'profil_pengguna.dart';
import 'konfirmasipesanan.dart'; // Pastikan file ini sudah ada

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  final String currentUserId = "1";

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCartData();
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
      backgroundColor: AppColors.adminBg,
      appBar: AppBar(
        backgroundColor: AppColors.adminPrimary,
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
              child: CircularProgressIndicator(color: AppColors.adminPrimary),
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
                        border: Border.all(color: AppColors.adminPrimary),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Tambahkan Catatan (opsional)',
                          prefixIcon: Icon(
                            Icons.edit_note,
                            color: AppColors.adminPrimary,
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
                            color: Colors.black.withOpacity(0.1),
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
                                style: const TextStyle(fontSize: 14),
                              ),
                              const Text(
                                'Subtotal',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Rp $_totalHarga',
                            style: const TextStyle(
                              color: AppColors.adminPrimary,
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
                            color: const Color(0xFFF1C574),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColors.textDark),
                          ),
                          child: const Center(
                            child: Text(
                              'Konfirmasi Pesanan',
                              style: TextStyle(
                                color: Colors.black,
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
          color: AppColors.adminPrimary,
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
            color: Colors.black.withOpacity(0.1),
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
              errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 70),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  harga,
                  style: const TextStyle(
                    color: AppColors.adminPrimary,
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
                    SizedBox(width: 30, child: Center(child: Text('$jumlah'))),
                    GestureDetector(
                      onTap: () => _updateJumlah(idProduk, 1),
                      child: _buildQtyBtn('+'),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _hapusItem(idProduk),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.textDark,
                        size: 22,
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
        color: AppColors.adminBg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
