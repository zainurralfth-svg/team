import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Core/Colour.dart'; 
import '../Backend/api_service.dart'; 
import 'custom_text.dart';    

class SheetTambahPesanan extends StatefulWidget {
  const SheetTambahPesanan({super.key});

  @override
  State<SheetTambahPesanan> createState() => _SheetTambahPesananState();
}

class _SheetTambahPesananState extends State<SheetTambahPesanan> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _semuaMenu = [];
  bool _isLoading = true; 

  final Map<int, int> _jumlahPesanan = {};

  @override
  void initState() {
    super.initState();
    _fetchDataMenu(); 

    _searchController.addListener(() {
      setState(() {}); // Biar ngetik langsung responsif nyari
    });
  }

  Future<void> _fetchDataMenu() async {
    try {
      final response = await ApiService.getMenu(); 
      setState(() {
        _semuaMenu = response; 
        for (var menu in _semuaMenu) {
          _jumlahPesanan[int.parse(menu['id_produk'].toString())] = 0;
        }
        _isLoading = false; 
      });
        } catch (e) {
      setState(() { _isLoading = false; });
      print("Gagal load database menu: $e");
    }
  }

  // LOGIKA 1: Ambil data khusus untuk HASIL PENCARIAN
  List<dynamic> get _hasilPencarian {
    String keyword = _searchController.text.toLowerCase().trim();
    if (keyword.isEmpty) return []; // Kalo kosong, gak nampilin hasil pencarian
    
    return _semuaMenu.where((item) {
      return item['nama_produk'].toString().toLowerCase().contains(keyword);
    }).toList();
  }

  // LOGIKA 2: Ambil data khusus untuk MENU TERPILIH (yang udah di-klik)
  List<dynamic> get _menuTerpilih {
    return _semuaMenu.where((item) {
      int idProduk = int.parse(item['id_produk'].toString());
      return (_jumlahPesanan[idProduk] ?? 0) > 0;
    }).toList();
  }

  int get _hitungTotalHarga {
    int total = 0;
    for (var menu in _semuaMenu) {
      int idProduk = int.parse(menu['id_produk'].toString());
      int qty = _jumlahPesanan[idProduk] ?? 0;
      int harga = int.tryParse(menu['harga'].toString()) ?? 0;
      total += qty * harga;
    }
    return total;
  }

  String formatRupiah(dynamic angka) {
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalHargaNota = _hitungTotalHarga;
    var listPencarian = _hasilPencarian;
    var listTerpilih = _menuTerpilih;
    String keyword = _searchController.text.trim();

    return Container(
      padding: EdgeInsets.only(
        top: 15,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.add, color: Colors.green, size: 28),
                ),
                const SizedBox(width: 15),
                const CustomText('Tambah Pesanan', color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
              ],
            ),
            const SizedBox(height: 20),

            // 1. INPUT NAMA
            const CustomText('Nama Pemesan', color: AppColors.textWhite, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            TextField(
              controller: _namaController,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEFE6D5),
                hintText: "Masukkan nama pemesan...", 
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textBrown),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 15),

            // 2. INPUT PENCARIAN
            const CustomText('Cari Menu', color: AppColors.textWhite, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEFE6D5),
                hintText: "Ketik nama menu produk yang di cari...", 
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textBrown),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            
            // 3. AREA HASIL PENCARIAN (MUNCUL KALAU LAGI NGETIK AJA)
            if (keyword.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                // Biar gak ngular, kita kasih batas maksimal tinggi 200, isinya bisa di-scroll
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: listPencarian.isEmpty 
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: CustomText('Menu "$keyword" tidak ditemukan', color: Colors.grey[600], fontSize: 14),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: listPencarian.length,
                      itemBuilder: (context, index) {
                        var item = listPencarian[index];
                        int idProduk = int.parse(item['id_produk'].toString());
                        int harga = int.tryParse(item['harga'].toString()) ?? 0;
                        int stokTersedia = int.tryParse(item['stok'].toString()) ?? 0; // 👈 1. Ambil data stok dari API

                        return ListTile(
                          title: CustomText(item['nama_produk'].toString(), fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
                          // 👈 2. Tampilin info sisa stok di layar pencarian
                          subtitle: CustomText('${formatRupiah(harga)}  •  Sisa Stok: $stokTersedia', color: stokTersedia > 0 ? AppColors.textBrown : Colors.red, fontSize: 12),
                          // 👈 3. Kalau stok habis, tombol + berubah jadi abu-abu
                          trailing: Icon(Icons.add_circle, color: stokTersedia > 0 ? Colors.orange : Colors.grey),
                          onTap: () {
                            // 👈 4. SATPAM FRONTEND: Cegah masuk keranjang kalau stok habis
                            if (stokTersedia <= 0) {
                              FocusScope.of(context).unfocus(); // Tutup keyboard
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Stok habis! Tidak bisa ditambahkan ke pesanan.'), backgroundColor: Colors.red));
                              return; // Stop proses di sini!
                            }

                            // KLIK DISINI BUAT MASUKIN KE KERANJANG TERPILIH
                            setState(() {
                              if ((_jumlahPesanan[idProduk] ?? 0) == 0) {
                                _jumlahPesanan[idProduk] = 1; // Otomatis set 1 karena stok udah dijamin > 0
                              }
                              // Bersihin kolom pencarian biar list pencarian ketutup
                              _searchController.clear();
                              FocusScope.of(context).unfocus(); // Tutup keyboard
                            });
                          },
                        );
                      },
                    ),
              ),
            ],

            const SizedBox(height: 20),

            // 4. AREA MENU TERPILIH (KERANJANG)
            const CustomText('Menu Terpilih', color: AppColors.textWhite, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),

            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Colors.white)))
            else if (listTerpilih.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFFDF0D5), borderRadius: BorderRadius.circular(20)),
                child: const Center(
                  child: CustomText('Silakan cari dan klik menu untuk memilih', color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              )
            else
              // Bikin list menu terpilih ngga ikut nge-scroll sendiri (gabung sama scroll utama)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: listTerpilih.length,
                itemBuilder: (context, index) {
                  var item = listTerpilih[index];
                  int idProduk = int.parse(item['id_produk'].toString());
                  int hargaSatuan = int.tryParse(item['harga'].toString()) ?? 0;
                  int maxStok = int.tryParse(item['stok'].toString()) ?? 0;
                  int qtySekarang = _jumlahPesanan[idProduk] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0D5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(item['nama_produk'].toString(), fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              const SizedBox(height: 4),
                              CustomText(formatRupiah(hargaSatuan), fontSize: 13, color: const Color(0xFFC67C28), fontWeight: FontWeight.bold),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFF3E5D8), borderRadius: BorderRadius.circular(6)),
                                child: CustomText('Sisa Stok Tersedia: $maxStok pcs', fontSize: 11, color: AppColors.textBrown, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (qtySekarang > 0) _jumlahPesanan[idProduk] = qtySekarang - 1;
                                });
                              },
                              child: Icon(Icons.remove_circle_outline, color: Colors.red, size: 28),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: CustomText('$qtySekarang', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (qtySekarang < maxStok) {
                                  setState(() => _jumlahPesanan[idProduk] = qtySekarang + 1);
                                } else {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Maksimal stok sisa $maxStok'), backgroundColor: AppColors.error));
                                }
                              },
                              child: const Icon(Icons.add_circle_outline, color: Colors.green, size: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText('Total Harga', color: AppColors.textWhite, fontSize: 12),
                    CustomText(formatRupiah(totalHargaNota), color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_namaController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama pemesan wajib diisi ya'), backgroundColor: Colors.red));
                      return;
                    }

                    List<Map<String, dynamic>> listKeranjangFix = [];
                    for (var menu in _semuaMenu) {
                      int idProduk = int.parse(menu['id_produk'].toString());
                      int qty = _jumlahPesanan[idProduk] ?? 0;
                      if (qty > 0) {
                        listKeranjangFix.add({
                          "id_produk": idProduk,
                          "nama_produk": menu['nama_produk'],
                          "jumlah": qty,
                          "harga": int.tryParse(menu['harga'].toString()) ?? 0,
                        });
                      }
                    }

                    if (listKeranjangFix.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal 1 menu dulu'), backgroundColor: Colors.red));
                      return;
                    }

                    Map<String, dynamic> dataPesananBaru = {
                      "nama_pemesan": _namaController.text.trim(),
                      "no_telp": "-", 
                      "keranjang": jsonEncode(listKeranjangFix), 
                      "total_harga": totalHargaNota,
                      "status_pesanan": "PROSES",
                    };

                    try {
                      final response = await ApiService.tambahPesanan(dataPesananBaru);
                      if (response['status'] == 'sukses' || response['status'] == 'success') {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil masuk database! 🔥'), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${response['pesan']}'), backgroundColor: Colors.red));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Jaringan: $e'), backgroundColor: Colors.red));
                    }
                  },
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}