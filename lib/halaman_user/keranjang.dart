import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; // Palet 14 Warna Baru
import 'konfirmasipesanan.dart'; // Pastikan file ini sudah ada
import '../Widget/custom_user_navbar.dart';
import '../Widget/custom_text.dart'; 

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

  Future<void> _loadUserIdAndFetchCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUserId = prefs.getString('id_user') ?? "0";
      });
    }
    _fetchCartData(); 
  }

  Future<void> _fetchCartData() async {
    try {
      final data = await ApiService.getKeranjang(currentUserId);
      if (mounted) {
        setState(() {
          _cartItems = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching cart: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: CustomText("Gagal: ${response['pesan']}", color: Colors.white)),
      );
    }
  }

  void _hapusItem(String idProduk) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText("Hapus Item", fontWeight: FontWeight.bold),
        content: const CustomText("Apakah Anda yakin ingin menghapus item ini dari keranjang?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText("Batal", color: Colors.grey),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              final res = await ApiService.hapusKeranjang(currentUserId, idProduk);
              if (res['status'] == 'sukses') {
                _fetchCartData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: CustomText("Item berhasil dihapus", color: Colors.white)),
                );
              } else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: CustomText("Gagal: ${res['pesan']}", color: Colors.white)),
                );
              }
            },
            child: const CustomText("Hapus", color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  int get _totalHarga {
    int total = 0;
    for (var item in _cartItems) {
      String hargaStr = item['harga'].toString().replaceAll(RegExp(r'[^0-9]'), '');
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
      backgroundColor: AppColors.bgUtama, 
      appBar: AppBar(
        backgroundColor: AppColors.primary, 
        elevation: 0,
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        title: const CustomText(
          'Keranjang',
          color: AppColors.textWhite,
          fontSize: 24, 
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _cartItems.isEmpty
          ? const Center(
              child: CustomText(
                "Keranjangmu masih kosong 🛒",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
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
                    const CustomText(
                      'Pesanan',
                      color: AppColors.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
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
                          Uri.encodeFull("${ApiService.baseUrl}/uploads/${item['gambar']}"),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    // KOLOM CATATAN SUDAH DIHAPUS DARI SINI
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
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
                              CustomText(
                                '$_totalItem Item',
                                fontSize: 14, 
                                color: AppColors.textDark,
                              ),
                              const CustomText(
                                'Subtotal',
                                fontSize: 14, 
                                color: AppColors.textDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            'Rp $_totalHarga',
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                            color: AppColors.accent, 
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColors.textDark), 
                          ),
                          child: const Center(
                            child: CustomText(
                              'Konfirmasi Pesanan',
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildCartCard(String idProduk, String nama, String harga, int jumlah, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow, 
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
                CustomText(
                  nama,
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.textDark,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), 
                CustomText(
                  harga,
                  fontSize: 14, 
                  color: AppColors.primary, 
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _updateJumlah(idProduk, -1),
                      child: _buildQtyBtn('-'),
                    ),
                    SizedBox(
                      width: 30, 
                      child: Center(
                        child: CustomText('$jumlah', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark) 
                      )
                    ),
                    GestureDetector(
                      onTap: () => _updateJumlah(idProduk, 1),
                      child: _buildQtyBtn('+'),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _hapusItem(idProduk),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error, 
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
        color: AppColors.bgInput, 
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: CustomText(title, fontWeight: FontWeight.bold, color: AppColors.textDark),
      ),
    );
  }
}