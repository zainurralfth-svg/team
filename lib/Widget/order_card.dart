import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // <-- Pastikan path AppColors lo bener di sini

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

  @override
  Widget build(BuildContext context) {
    // ==============================================================
    // PERBAIKAN DI SINI BRO: Paksa string kosong "" jadi 'MENUNGGU'
    // ==============================================================
    String statusRaw = status.trim().toUpperCase();
    String displayStatus = statusRaw.isEmpty ? 'MENUNGGU' : statusRaw;

    Color dotColor;
    switch (displayStatus) {
      case 'SELESAI': dotColor = AppColors.success; break;
      case 'MENUNGGU': dotColor = AppColors.primary; break; // Orange utama
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
          // Bunderan inisial nama
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                nama.isNotEmpty ? nama[0].toUpperCase() : 'A', 
                style: const TextStyle(color: AppColors.textDark, fontSize: 20, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)
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
                    Text(nama, style: const TextStyle(fontSize: 16, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    
                    // LABEL STATUS (Sudah pakai displayStatus biar anti-kosong)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(displayStatus, style: const TextStyle(fontSize: 10, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(ringkasan, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontFamily: 'Signika Negative', fontWeight: FontWeight.w600, color: AppColors.textHint)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(harga, style: const TextStyle(fontSize: 14, fontFamily: 'Signika Negative', fontWeight: FontWeight.w800, color: AppColors.primary)),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: AppColors.textHint), 
                        const SizedBox(width: 4), 
                        Text(waktu.length > 15 ? waktu.substring(0, 15) : waktu, style: const TextStyle(fontSize: 10, fontFamily: 'Signika Negative', color: AppColors.textHint, fontWeight: FontWeight.bold))
                      ],
                    )
                  ],
                ),

                // ==============================================================
                // LOGIKA TOMBOL AKSI ADMIN (Sudah disesuaikan dengan displayStatus)
                // ==============================================================
                
                // JIKA STATUS MASIH MENUNGGU: Muncul tombol Konfirmasi & Tolak
                if (displayStatus == 'MENUNGGU') ...[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => onStatusChanged('DIBATALKAN'),
                          child: const Text('Tolak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: () => onStatusChanged('PROSES'),
                          child: const Text('Konfirmasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ] 
                
                // JIKA STATUS PROSES: Muncul tombol Selesaikan
                else if (displayStatus == 'PROSES') ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      onPressed: () => onStatusChanged('SELESAI'),
                      label: const Text('Pesanan Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}