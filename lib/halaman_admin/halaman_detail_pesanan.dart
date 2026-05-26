import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Widget/custom_text.dart';
import '../Core/Colour.dart';

class HalamanDetailPesanan extends StatelessWidget {
  final Map<String, dynamic> dataPesanan;

  const HalamanDetailPesanan({super.key, required this.dataPesanan});

  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    String idTampil = dataPesanan['kode_resi']?.toString() ?? '-';
    
    // Logika Status: Kalau null/kosong, ganti jadi BUTUH KONFIRMASI
    String statusRaw = dataPesanan['status_pesanan']?.toString().toUpperCase() ?? '';
    if (statusRaw.isEmpty) statusRaw = 'BUTUH KONFIRMASI';

    String totalHarga = formatRupiah(dataPesanan['total_harga']);

    // Logika Pisah Tanggal & Jam
    String fullWaktu = dataPesanan['created_at']?.toString() ?? '';
    String tglOrder = fullWaktu.isNotEmpty && fullWaktu.contains(' ') ? fullWaktu.split(' ')[0] : fullWaktu;
    String jamOrder = fullWaktu.isNotEmpty && fullWaktu.contains(' ') ? fullWaktu.split(' ')[1] : '-';

    // TAMBAHAN: Tarik data catatan
    String catatan = dataPesanan['catatan']?.toString() ?? ''; 

    List<String> listProduk = [];
    if (dataPesanan['ringkasan_pesanan'] != null) {
      listProduk = dataPesanan['ringkasan_pesanan'].toString().split(', ');
    }

    return Scaffold(
      backgroundColor: AppColors.bgUtama,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
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
                          // Tanggal dan Jam dipisah biar rapi
                          Row(
                            children: [
                              Expanded(child: _buildDetailRow('Tanggal Order', tglOrder)),
                              Expanded(child: _buildDetailRow('Waktu Order', jamOrder)),
                            ],
                          ),
                          const Divider(height: 20, color: AppColors.bgInput),
                          _buildDetailRow('Status Saat Ini', statusRaw, isStatus: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildSectionTitle('Item Produk'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(16)),
                      child: Column(
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
                    // TAMBAHAN: Kotak Khusus Catatan Pelanggan
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
                          border: Border.all(color: AppColors.primary, width: 1.5), // Border tegas biar admin notice
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomText(
                                '"$catatan"', // Dikasih tanda kutip biar kerasa kayak pesan langsung
                                fontSize: 15,
                                fontWeight: FontWeight.w600, // Agak ditebelin
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: CustomText(title, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textBrown),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    Color textColor = AppColors.textDark;
    if (isStatus) {
      if (value == 'SELESAI') textColor = AppColors.success;
      else if (value == 'DIBATALKAN') textColor = AppColors.error;
      else if (value == 'MENUNGGU') textColor = AppColors.primary;
      else if (value == 'BUTUH KONFIRMASI') textColor = AppColors.textHint; // Status baru
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