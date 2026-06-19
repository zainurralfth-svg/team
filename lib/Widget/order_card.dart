import 'package:flutter/material.dart';
import '../Core/Colour.dart';
import 'custom_text.dart';

class OrderCard extends StatelessWidget {
  final String id;
  final String nama;
  final String ringkasan;
  final String harga;
  final String status;
  final String waktu;
  final ValueChanged<String> onStatusChanged;

  const OrderCard({
    super.key,
    required this.id,
    required this.nama,
    required this.ringkasan,
    required this.harga,
    required this.status,
    required this.waktu,
    required this.onStatusChanged,
  });

  void _showKonfirmasiDialog({
    required BuildContext context,
    required String judul,
    required String pesan,
    required String labelTombolAksi,
    required Color warnaAksi,
    required VoidCallback onKonfirmasi,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          judul,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(pesan),
        actions: [
          // TOMBOL BATAL
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // TOMBOL AKSI (Konfirmasi / Batalkan / Selesai)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onKonfirmasi();
            },
            style: TextButton.styleFrom(
              backgroundColor: warnaAksi,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              labelTombolAksi,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String statusRaw = status.trim().toUpperCase();
    String displayStatus = statusRaw.isEmpty ? 'MENUNGGU' : statusRaw;

    Color dotColor;
    switch (displayStatus) {
      case 'SELESAI': dotColor = AppColors.success; break;
      case 'MENUNGGU': dotColor = AppColors.primary; break;
      case 'PROSES': dotColor = AppColors.info; break;
      case 'DIBATALKAN': dotColor = AppColors.error; break;
      default: dotColor = AppColors.textHint;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: CustomText(
                nama.isNotEmpty ? nama[0].toUpperCase() : 'A',
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(nama, fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          CustomText(displayStatus, fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                CustomText(ringkasan, maxLines: 2, overflow: TextOverflow.ellipsis, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHint),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(harga, fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        CustomText(
                          waktu.length > 15 ? waktu.substring(0, 15) : waktu,
                          fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),

                // TOMBOL STATUS MENUNGGU → Konfirmasi & Dibatalkan
                if (displayStatus == 'MENUNGGU') ...[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: () => _showKonfirmasiDialog(
                            context: context,
                            judul: 'Konfirmasi Pesanan',
                            pesan: 'Apakah kamu yakin ingin mengkonfirmasi pesanan dari $nama?',
                            labelTombolAksi: 'Konfirmasi',
                            warnaAksi: AppColors.success,
                            onKonfirmasi: () => onStatusChanged('PROSES'),
                          ),
                          child: const CustomText('Konfirmasi', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showKonfirmasiDialog(
                            context: context,
                            judul: 'Batalkan Pesanan',
                            pesan: 'Apakah kamu yakin ingin membatalkan pesanan dari $nama? Tindakan ini tidak dapat diurungkan.',
                            labelTombolAksi: 'Konfirmasi',
                            warnaAksi: AppColors.error,
                            onKonfirmasi: () => onStatusChanged('DIBATALKAN'),
                          ),
                          child: const CustomText('Dibatalkan', fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ]

                // TOMBOL STATUS PROSES → Pesanan Selesai
                else if (displayStatus == 'PROSES') ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 81, 210, 48),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      onPressed: () => _showKonfirmasiDialog(
                        context: context,
                        judul: 'Selesaikan Pesanan',
                        pesan: 'Apakah kamu yakin pesanan dari $nama sudah selesai?',
                        labelTombolAksi: 'Selesai',
                        warnaAksi: const Color.fromARGB(255, 81, 210, 48),
                        onKonfirmasi: () => onStatusChanged('SELESAI'),
                      ),
                      label: const CustomText('Pesanan Selesai', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}