import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Widget/custom_text.dart';
import '../Core/Colour.dart';

// Menggunakan StatelessWidget karena halaman ini hanya berfungsi untuk menampilkan rincian data pesanan secara statis, tanpa ada perubahan status di dalam layar.
class HalamanDetailPesanan extends StatelessWidget {
  // Variabel penampung data pesanan yang dikirimkan dari halaman sebelumnya.
  final Map<String, dynamic> dataPesanan;

  const HalamanDetailPesanan({super.key, required this.dataPesanan});

  // =========================================================================
  // 1. FUNGSI FORMAT MATA UANG RUPIAH
  // =========================================================================
  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    // Memastikan data dari server diubah menjadi tipe angka (integer) agar bisa diformat.
    int value = int.tryParse(angka.toString()) ?? 0;
    // Mengembalikan nilai angka dalam bentuk format mata uang Indonesia (Rp).
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil Kode Resi pesanan. Jika data kosong, maka ditampilkan tanda strip (-).
    String idTampil = dataPesanan['kode_resi']?.toString() ?? '-';
    
    // LOGIKA STATUS PESANAN: Menyeragamkan teks status menjadi huruf kapital semua.
    // Jika status dari server kosong, maka otomatis diatur menjadi 'BUTUH KONFIRMASI'.
    String statusRaw = dataPesanan['status_pesanan']?.toString().toUpperCase() ?? '';
    if (statusRaw.isEmpty) statusRaw = 'BUTUH KONFIRMASI';

    // Memformat angka total harga menggunakan fungsi formatRupiah di atas.
    String totalHarga = formatRupiah(dataPesanan['total_harga']);

    // LOGIKA PEMISAHAN WAKTU: 
    // Data dari database biasanya tergabung (Contoh: "2026-06-02 14:30:00"). 
    // Di sini kita memisahkan tanggal dan jam berdasarkan spasi agar bisa ditampilkan di kolom yang berbeda secara rapi.
    String fullWaktu = dataPesanan['created_at']?.toString() ?? '';
    String tglOrder = fullWaktu.isNotEmpty && fullWaktu.contains(' ') ? fullWaktu.split(' ')[0] : fullWaktu;
    String jamOrder = fullWaktu.isNotEmpty && fullWaktu.contains(' ') ? fullWaktu.split(' ')[1] : '-';

    // Mengambil isi pesan atau catatan tambahan dari pelanggan.
    String catatan = dataPesanan['catatan']?.toString() ?? ''; 

    // LOGIKA DAFTAR PRODUK: 
    // Mengubah teks ringkasan pesanan dari database (yang biasanya dipisah dengan koma, contoh: "Puding Mangga x2, Puding Coklat x1") 
    // menjadi bentuk daftar (List) agar bisa dicetak baris demi baris ke bawah.
    List<String> listProduk = [];
    if (dataPesanan['ringkasan_pesanan'] != null) {
      listProduk = dataPesanan['ringkasan_pesanan'].toString().split(', ');
    }

    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Warna dasar latar belakang aplikasi.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOMBOL KEMBALI
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 28),
                onPressed: () => Navigator.pop(context), // Fungsi untuk kembali ke halaman sebelumnya.
              ),
            ),
            
            // AREA KONTEN UTAMA (Mendukung fungsi scroll jika isi layar memanjang).
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText('Rincian Pesanan', fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                    const SizedBox(height: 5),
                    CustomText('ID Pesanan: $idTampil', fontSize: 14, color: AppColors.textHint, fontWeight: FontWeight.bold),
                    const SizedBox(height: 20),

                    // KOTAK 1: DATA PEMESAN
                    _buildSectionTitle('Data Pemesan'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Nama Pelanggan', dataPesanan['nama_pemesan'] ?? 'Tidak diketahui'),
                          const Divider(height: 20, color: AppColors.bgInput),
                          
                          // Menampilkan letak Tanggal dan Waktu pesanan secara berdampingan.
                          Row(
                            children: [
                              Expanded(child: _buildDetailRow('Tanggal Order', tglOrder)),
                              Expanded(child: _buildDetailRow('Waktu Order', jamOrder)),
                            ],
                          ),
                          const Divider(height: 20, color: AppColors.bgInput),
                          
                          // Menampilkan status pesanan dengan indikator khusus (isStatus) agar warnanya menyesuaikan kondisi.
                          _buildDetailRow('Status Saat Ini', statusRaw, isStatus: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // KOTAK 2: ITEM PRODUK YANG DIBELI
                    _buildSectionTitle('Item Produk'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        // Menampilkan setiap produk yang dibeli satu per satu ke bawah secara berurutan.
                        children: listProduk.map((produk) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.cake_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(child: CustomText(produk, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                              ],
                            ),
                          );
                        }).toList(), 
                      ),
                    ),
                    
                    // ============================================================
                    // KOTAK 3: CATATAN PELANGGAN (KONDISIONAL)
                    // Kotak ini hanya akan digambar di layar jika pelanggan memang mengisi catatan. 
                    // Jika kosong, kotak ini otomatis disembunyikan agar tampilan tetap rapi.
                    // ============================================================
                    if (catatan.isNotEmpty && catatan != 'null') ...[
                      const SizedBox(height: 25),
                      _buildSectionTitle('Catatan dari Pelanggan'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.textWhite, 
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary, width: 1.5), // Memberikan garis pinggir berwarna agar mudah disadari oleh admin.
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomText(
                                '"$catatan"', // Menambahkan tanda kutip agar terlihat seperti pesan langsung.
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic, 
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ============================================================

                    const SizedBox(height: 25),

                    // KOTAK 4: TOTAL PEMBAYARAN
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText('Total Bayar:', color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                          CustomText(totalHarga, color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.w900),
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

  // =========================================================================
  // CETAKAN WIDGET BANTUAN
  // =========================================================================

  // Cetakan untuk membuat teks judul pada setiap bagian kotak informasi.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: CustomText(title, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textBrown),
    );
  }

  // Cetakan untuk membuat baris informasi detail (Teks judul kecil di atas, isi informasi cetak tebal di bawah).
  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    Color textColor = AppColors.textDark; // Warna bawaan untuk teks biasa.
    
    // LOGIKA PEWARNAAN STATUS: 
    // Jika parameter isStatus diaktifkan, program akan mengecek isi teks dan memberikan warna yang sesuai dengan kondisinya.
    if (isStatus) {
      if (value == 'SELESAI') textColor = AppColors.success;
      else if (value == 'DIBATALKAN') textColor = AppColors.error;
      else if (value == 'MENUNGGU') textColor = AppColors.primary;
      else if (value == 'BUTUH KONFIRMASI') textColor = AppColors.textHint; 
      else textColor = AppColors.info;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label, fontSize: 12, color: AppColors.textHint), 
        const SizedBox(height: 2),
        CustomText(value, fontSize: 16, fontWeight: FontWeight.bold, color: textColor), 
      ],
    );
  }
}