import 'package:flutter/material.dart';
import '../Backend/api_service.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  
  // ID User (Pastikan sama dengan yang ada di menu.dart)
  final String currentUserId = "1"; 

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  // 1. Fungsi Menarik Data dari Database
  Future<void> _fetchCartData() async {
    try {
      final data = await ApiService.getKeranjang(currentUserId);
      setState(() {
        _cartItems = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Gagal mengambil keranjang: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. Fungsi Hitung Total Harga Otomatis
  int get _totalHarga {
    int total = 0;
    for (var item in _cartItems) {
      int harga = int.tryParse(item['harga'].toString()) ?? 0;
      int jumlah = int.tryParse(item['jumlah'].toString()) ?? 0;
      total += (harga * jumlah);
    }
    return total;
  }

  // 3. Fungsi Hitung Total Barang Otomatis
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
      backgroundColor: const Color(0xFFFFE5B9), // Warna background persis aslimu
      
      // HEADER (Desain aslimu)
      appBar: AppBar(
        backgroundColor: const Color(0xFFD27F30),
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('←', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontFamily: 'Oleo Script',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD27F30)))
          : _cartItems.isEmpty
              ? const Center(
                  child: Text(
                    "Keranjangmu masih kosong 🛒",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF270C0C)),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pesanan',
                        style: TextStyle(
                          color: Color(0xFF270C0C),
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ==========================================
                      // LIST PRODUK OTOMATIS (DARI MYSQL)
                      // ==========================================
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          String namaDB = item['nama_produk'] ?? 'Tanpa Nama';
                          String hargaDB = 'Rp ${item['harga']}';
                          int jumlahDB = int.tryParse(item['jumlah'].toString()) ?? 1;
                          
                          // Tarik foto asli pakai Uri.encodeFull anti-spasi
                          String namaFileGambar = item['gambar'] ?? '';
                          String urlGambarLengkap = Uri.encodeFull("${ApiService.baseUrl}/uploads/$namaFileGambar");

                          return _buildCartCard(namaDB, hargaDB, jumlahDB, urlGambarLengkap);
                        },
                      ),

                      const SizedBox(height: 25),
                      
                      // CATATAN PESANAN
                      const Text(
                        'Catatan Pesanan',
                        style: TextStyle(
                          color: Color(0xFF270C0C),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD27F30)),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Tambahkan Catatan (opsional)',
                            hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                            prefixIcon: Icon(Icons.edit_note, color: Color(0xFFD27F30)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==========================================
                      // RINGKASAN BELANJA (OTOMATIS DIHITUNG)
                      // ==========================================
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$_totalItem Item', style: const TextStyle(color: Colors.black, fontSize: 14)),
                                const Text('Subtotal', style: TextStyle(color: Colors.black, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Rp $_totalHarga',
                              style: const TextStyle(
                                color: Color(0xFFD27F30),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // TOMBOL KONFIRMASI
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Menuju Checkout... 🚀')),
                            );
                            // Navigator.pushNamed(context, '/konfirmasi');
                          },
                          child: Container(
                            width: 240,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1C574),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: const Color(0xFF270C0C)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Konfirmasi Pesanan',
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                
      // BOTTOM NAVIGATION (Sesuai desainmu)
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(color: Color(0xFFD27F30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag, color: Colors.white, size: 28),
                SizedBox(height: 5),
                Text('Pesanan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu, color: Colors.white, size: 28),
                  SizedBox(height: 5),
                  Text('Produk', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET KARTU PRODUK (Desainmu yang dibuat dinamis)
  // ==========================================
  Widget _buildCartCard(String nama, String harga, int jumlah, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar Produk
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imgUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 70, height: 70, color: Colors.grey[300],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // Info Produk & Tombol
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  harga,
                  style: const TextStyle(color: Color(0xFFD27F30), fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Tombol Min
                    _buildQtyBtn('-'),
                    // Jumlah
                    Container(
                      width: 30,
                      alignment: Alignment.center,
                      child: Text('$jumlah', style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    // Tombol Plus
                    _buildQtyBtn('+'),
                    const Spacer(),
                    // Ikon Hapus
                    GestureDetector(
                      onTap: () {
                         // Nanti kita isi logika hapus API di sini
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur hapus segera hadir!')));
                      },
                      child: const Icon(Icons.delete_outline, color: Color(0xFF270C0C), size: 22),
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
        color: const Color(0xFFFFE5B9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Color(0xFF270C0C), fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}