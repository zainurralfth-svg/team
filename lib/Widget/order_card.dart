import 'package:flutter/material.dart';

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
    Color dotColor;
    switch (status.toUpperCase()) {
      case 'SELESAI': dotColor = Colors.green; break;
      case 'MENUNGGU': dotColor = Colors.orange; break;
      case 'PROSES': dotColor = Colors.blueAccent; break;
      case 'DIBATALKAN': dotColor = Colors.red; break;
      default: dotColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFFFF3DE), borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                nama.isNotEmpty ? nama[0].toUpperCase() : 'A', 
                style: const TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)
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
                    Text(nama, style: const TextStyle(fontSize: 16, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: Colors.black)),
                    
                    // MENU STATUS KLIK (POPUP)
                   // MENU STATUS KLIK (POPUP)
                    PopupMenuButton<String>(
                      // INI KABELNYA BUNG! HARUS DIPASANG!
                      onSelected: onStatusChanged, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(value: 'PROSES', child: Text('🔄 PROSES')),
                        const PopupMenuItem(value: 'SELESAI', child: Text('✅ SELESAI')),
                        const PopupMenuItem(value: 'DIBATALKAN', child: Text('❌ DIBATALKAN')),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFFE5B9), borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: Colors.black)),
                            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(ringkasan, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontFamily: 'Signika Negative', fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.52))),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(harga, style: const TextStyle(fontSize: 14, fontFamily: 'Signika Negative', fontWeight: FontWeight.w800, color: Color(0xFFD27F30))),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.black.withOpacity(0.46)), 
                        const SizedBox(width: 4), 
                        Text(waktu.length > 15 ? waktu.substring(0, 15) : waktu, style: TextStyle(fontSize: 10, fontFamily: 'Signika Negative', color: Colors.black.withOpacity(0.46), fontWeight: FontWeight.bold))
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}