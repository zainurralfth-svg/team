import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Widget/custom_text.dart';
import '../Core/Colour.dart';

// Menggunakan StatelessWidget karena halaman ini cuma bertugas "menampilkan" data aja,
// tidak ada perubahan status (state) atau nembak API langsung di sini.
class HalamanDetailPesanan extends StatelessWidget {
  // Data pesanan dikirim dari halaman sebelumnya lewat variabel ini
  final Map<String, dynamic> dataPesanan;

  const HalamanDetailPesanan({super.key, required this.dataPesanan});

  // 1. FUNGSI MENGUBAH ANGKA MENJADI FORMAT RUPIAH (Rp)
  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    // Coba ubah data dari database ke bentuk angka (int)
    int value = int.tryParse(angka.toString()) ?? 0;
    // Cetak jadi format mata uang Indonesia
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil ID / Kode Resi dari database. Kalo kosong, tampilin tanda minus (-)
    String idTampil = dataPesanan['kode_resi']?.toString() ?? '-';
    
    // LOGIKA STATUS: Ambil status dari database, paksa jadi HURUF BESAR semua.
    // Kalo di database ternyata null/kosong, otomatis set jadi 'BUTUH KONFIRMASI'
    String statusRaw = dataPesanan['status_pesanan']?.toString().toUpperCase() ?? '';
    if (statusRaw.isEmpty) statusRaw = 'BUTUH KONFIRMASI';

    // Panggil fungsi rupiah di atas tadi buat ngubah total harga pesanan
    String totalHarga = formatRupiah(dataPesanan['total_harga']);

    // LOGIKA PISAH TANGGAL & JAM:
    // Data 'created_at' di MySQL itu bentuknya gabung (Contoh: "2026-06-02 14:30:00").
    // Di sini kita pisah berdasarkan spasi (' ') biar tanggal ama jam-nya bisa dipajang terpisah.
    String fullWaktu = dataPesanan['created_at']?.toString() ?? '';
    String tglOrder = fullWaktu.isNotEmpty && fullWaktu.contains(' ') ? fullWaktu.split(' ')[0] : fullWaktu;
    String jamOrder = fullWaktu.isNotEmpty && fullWaktu.contains(' ') ? fullWaktu.split(' ')[1] : '-';

    // Ambil data catatan tambahan dari pembeli
    String catatan = dataPesanan['catatan']?.toString() ?? ''; 

    // LOGIKA MEMECAH ITEM PRODUK:
    // Kolom 'ringkasan_pesanan' di database lu bentuknya teks panjang dibatasi koma
    // (Contoh: "Pudding Cokelat x2, Pudding Mangga x1").
    // Di sini kita pecah teks itu pake .split(', ') biar berubah jadi List/Daftar produk terpisah.
    List<String> listProduk = [];
    if (dataPesanan['ringkasan_pesanan'] != null) {
      listProduk = dataPesanan['ringkasan_pesanan'].toString().split(', ');
    }

    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Krem dasar aplikasi Puddingku
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOMBOL KEMBALI (BACK)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 28),
                onPressed: () => Navigator.pop(context), // Klik ini buat balik ke halaman sebelumnya
              ),
            ),
            
            // AREA KONTEN UTAMA (Bisa di-scroll bawah-atas)
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
                          
                          // Menampilkan Tanggal & Jam Order berdampingan (Kiri & Kanan)
                          Row(
                            children: [
                              Expanded(child: _buildDetailRow('Tanggal Order', tglOrder)),
                              Expanded(child: _buildDetailRow('Waktu Order', jamOrder)),
                            ],
                          ),
                          const Divider(height: 20, color: AppColors.bgInput),
                          
                          // Status dikasih penanda khusus (isStatus: true) biar warnanya berubah otomatis
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
                        // Mengulang (Looping) listProduk tadi untuk ditampilkan satu-persatu ke bawah
                        children: listProduk.map((produk) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.cake_rounded, color: AppColors.primary, size: 20), // Ikon kue/pudding
                                const SizedBox(width: 12),
                                Expanded(child: CustomText(produk, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                              ],
                            ),
                          );
                        }).toList(), // Diubah kembali jadi bentuk List widget
                      ),
                    ),
                    
                    // ============================================================
                    // KOTAK 3 (KONDISIONAL): CATATAN PELANGGAN
                    // Sifatnya Reusable-Conditional. Kotak ini HANYA AKAN MUNCUL kalau
                    // si pelanggan beneran nulis catatan pas checkout. Kalo kosong, dia sembunyi.
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
                          border: Border.all(color: AppColors.primary, width: 1.5), // Border oranye biar admin ngeh
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomText(
                                '"$catatan"', // Dikasih tanda kutip biar estetik kayak kutipan pesan
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic, // Teks miring
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ============================================================

                    const SizedBox(height: 25),

                    // KOTAK 4: BANNER TOTAL PEMBAYARAN (ORANYE)
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

  // 2. REUSABLE WIDGET: Judul Section Kecil (Contoh: "Data Pemesan", "Item Produk")
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: CustomText(title, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textBrown),
    );
  }

  // 3. REUSABLE WIDGET: Baris Informasi Detail (Label di atas, Isinya di bawah)
  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    Color textColor = AppColors.textDark; // Warna default tulisan biasa
    
    // LOGIKA WARNA STATUS OTOMATIS: 
    // Kalo baris ini mendeteksi isStatus itu TRUE, dia bakal nyocokin isi teksnya
    // buat nentuin warna teks yang pas (Selesai = Hijau, Batal = Merah, Menunggu = Oranye)
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
        CustomText(label, fontSize: 12, color: AppColors.textHint), // Judul kecil di atas
        const SizedBox(height: 2),
        CustomText(value, fontSize: 16, fontWeight: FontWeight.bold, color: textColor), // Isi tebal di bawah
      ],
    );
  }
}