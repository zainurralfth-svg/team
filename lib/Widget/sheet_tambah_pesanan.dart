import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Backend/API_service.dart';
import 'dart:convert'; // Wajib ditambahkan agar bisa mengubah array jadi teks JSON
import '../Widget/custom_text.dart';

class SheetTambahPesanan extends StatefulWidget {
  const SheetTambahPesanan({super.key});

  @override
  State<SheetTambahPesanan> createState() => _SheetTambahPesananState();
}

class _SheetTambahPesananState extends State<SheetTambahPesanan> {
  // Katalog tidak lagi diisi manual, kita siapkan list kosong!
  List<Map<String, dynamic>> katalogProduk = [];
  bool isLoadingProduk = true; // Indikator loading saat narik data

  List<Map<String, dynamic>> keranjang = [];
  String searchQuery = '';
  final namaCtrl = TextEditingController();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProduk(); // Tarik data saat pop-up pertama kali dibuka
  }

  // === FUNGSI PENYEDOT DATA MENU ===
 // === FUNGSI PENYEDOT DATA MENU ===
  Future<void> _loadProduk() async {
    try {
      // Memanggil getProduk() yang ada di API_Service.dart
      final List<dynamic> data = await ApiService.getProduk();
      
      if (mounted) {
        setState(() {
          // Mengubah data mentah database menjadi format katalog kasir mini
          katalogProduk = data.map<Map<String, dynamic>>((item) {
            return {
              'id_produk': item['id_produk']?.toString() ?? '',
              'nama': item['nama_produk'] ?? item['nama_menu'] ?? 'Tanpa Nama',
              'harga': int.tryParse(item['harga'].toString()) ?? 0,
              'stok': int.tryParse(item['stok'].toString()) ?? 0,
              'gambar': item['gambar'] ?? '',
              'kategori': item['kategori'] ?? 'Pudding',
            };
          }).toList();
          
          isLoadingProduk = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingProduk = false);
      }
      debugPrint("🚨 GAGAL LOAD PRODUK DI KASIR: $e");
    }
  }
  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    // Filter produk berdasarkan ketikan (Search)
    List<Map<String, dynamic>> produkFiltered = katalogProduk.where((p) {
      return p['nama'].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
    }).toList();

    int totalHargaCart = keranjang.fold(
      0,
      (sum, item) => sum + ((item['harga'] as int) * (item['qty'] as int)),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFD27F30),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          children: [
            // --- Handle Bar ---
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // --- Header ---
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 15),
                CustomText('Tambah Pesanan',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,)
              ],
            ),
            const SizedBox(height: 20),

            // --- Nama Pemesan ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nama Pemesan',
                style: TextStyle(
                  fontFamily: 'Signika Negative',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5B9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: namaCtrl,
                style: const TextStyle(
                  fontFamily: 'Signika Negative',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ketik nama pelanggan...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                  prefixIcon: Icon(Icons.person_outline, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- Search Bar ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5B9).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(
                  fontFamily: 'Signika Negative',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black54, size: 28),
                  hintText: 'Cari menu (Pudding, Hampers, dll)...',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontFamily: 'Signika Negative',
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Hasil Pencarian (Dengan Indikator Loading) ---
            if (searchQuery.isNotEmpty)
              Container(
                height: 150,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: isLoadingProduk
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD27F30),
                        ),
                      )
                    : produkFiltered.isEmpty
                    ? const Center(
                        child: Text(
                          "Menu tidak ditemukan",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: produkFiltered.length,
                        itemBuilder: (context, index) {
                          final p = produkFiltered[index];
                          return ListTile(
                            title: Text(
                              p['nama'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Signika Negative',
                              ),
                            ),
                            // Menampilkan kategori kecil di bawah nama produk (jika ada)
                            subtitle: Text(
                              "${p['kategori']} • ${formatRupiah(p['harga'])}",
                              style: const TextStyle(
                                color: Color(0xFFD27F30),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                 int indexDiKeranjang = keranjang.indexWhere(
                                    (item) => item['id_produk'] == p['id_produk'], 
                                  );
                                  if (indexDiKeranjang != -1) {
                                    keranjang[indexDiKeranjang]['qty'] += 1;
                                  } else {
                                    keranjang.add({
                                      'id_produk': p['id_produk'], // ✅ INI YANG PALING PENTING DITAMBAHKAN!
                                      'nama': p['nama'],
                                      'harga': p['harga'],
                                      'qty': 1,
                                    });
                                  }
                                  searchQuery = '';
                                });
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          );
                        },
                      ),
              ),

            // --- Keranjang Terpilih ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Menu Terpilih',
                style: TextStyle(
                  fontFamily: 'Signika Negative',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: keranjang.isEmpty
                  ? Center(
                      child: Text(
                        isLoadingProduk
                            ? 'Memuat data menu dari server...'
                            : 'Silakan cari dan pilih menu di atas',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: keranjang.length,
                      itemBuilder: (context, index) {
                        final item = keranjang[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5B9),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama'],
                                      style: const TextStyle(
                                        fontFamily: 'Signika Negative',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      formatRupiah(item['harga']),
                                      style: const TextStyle(
                                        color: Color(0xFFD27F30),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => setState(() {
                                  if (item['qty'] > 1)
                                    item['qty'] -= 1;
                                  else
                                    keranjang.removeAt(index);
                                }),
                              ),
                              Text(
                                '${item['qty']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    setState(() => item['qty'] += 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // --- Footer (Total & Tombol) ---
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        formatRupiah(totalHargaCart),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : GestureDetector(
                          onTap: () async {
                            if (namaCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nama pemesan wajib diisi!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (keranjang.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Keranjang kasir masih kosong!',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            setState(() => isSaving = true);

                            try {
                            // ✅ BUNGKUS KERANJANG JADI JSON UTUH
                            String keranjangJson = jsonEncode(keranjang);

                            // Tembak data ke backend PHP
                            var hasil = await ApiService.tambahPesanan({
                              "nama_pemesan": namaCtrl.text.trim(),
                              "no_telp": "-", 
                              "keranjang": keranjangJson, // Data JSON dikirim ke sini!
                              "total_harga": totalHargaCart.toString(),
                              "status_pesanan": "PROSES",
                            });

                            setState(() => isSaving = false);

                            if (hasil['status'] == 'sukses') {
                              Navigator.pop(context, true); 
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pesanan berhasil ditambahkan! ✓'), backgroundColor: Colors.green),
                              );
                            } else {
                              // .... (sisanya biarkan sama)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal: ${hasil['pesan']}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Pengaman ganda: Jika ada error logika, loading wajib mati!
                              setState(() => isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sistem Error: $e'),
                                  backgroundColor: Colors.purple,
                                ),
                              );
                            }
                          },

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Konfirmasi',
                                  style: TextStyle(
                                    fontFamily: 'Signika Negative',
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
