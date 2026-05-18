import 'package:flutter/material.dart';

class HalamanDetailPesanan extends StatelessWidget {
  final Map<String, dynamic> dataPesanan;

  // Menerima lemparan data lengkap dari halaman beranda admin
  const HalamanDetailPesanan({super.key, required this.dataPesanan});

  @override
  Widget build(BuildContext context) {
    const Color bgCream = Color(0xFFFFE5B9);
    const Color primaryOrange = Color(0xFFD27F30);
    const Color textDark = Color(0xFF2D2D2D);

    // Contoh pemisahan string jika pesanan banyak dipisah koma (misal: "Pudding Taro x1, Dessert Box x2")
    List<String> listProduk = [];
    if (dataPesanan['ringkasan_pesanan'] != null) {
      listProduk = dataPesanan['ringkasan_pesanan'].toString().split(', ');
    }

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOMBOL KEMBALI SIMPEL ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryOrange, size: 28),
                onPressed: () => Navigator.pop(context), // Balik ke Home Admin
              ),
            ),

            // ── KONTEN UTAMA DETAIL ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Pesanan Lengkap',
                      style: TextStyle(fontFamily: 'Signika Negative', fontSize: 26, fontWeight: FontWeight.bold, color: primaryOrange),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ID Pesanan: #${dataPesanan['id_pesanan'] ?? '-'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // ── KARTU INFORMASI PELANGGAN ──
                    _buildSectionTitle('Data Pemesan'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Nama Pelanggan', dataPesanan['nama_pemesan'] ?? 'Tidak diketahui'),
                          const Divider(height: 20),
                          _buildDetailRow('Waktu Order', dataPesanan['tanggal_pesanan'] ?? 'Baru saja'),
                          const Divider(height: 20),
                          _buildDetailRow('Status Saat Ini', dataPesanan['status_pesanan'] ?? 'PROSES', isStatus: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ── KARTU ITEM-ITEM YANG DIBELI (Bisa memanjang ke bawah tanpa batasan) ──
                    _buildSectionTitle('Item Produk Yang Dibeli'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: listProduk.map((produk) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.cake_rounded, color: primaryOrange, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    produk,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textDark),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ── TOTAL PEMBAYARAN ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Bayar:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            dataPesanan['total_harga']?.toString() ?? 'Rp 0',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Komponen pembantu untuk Judul Bagian
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFC17F3E))),
    );
  }

  // Komponen pembantu baris data detail
  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: isStatus ? const Color(0xFF2196F3) : const Color(0xFF2D2D2D)
          ),
        ),
      ],
    );
  }
}