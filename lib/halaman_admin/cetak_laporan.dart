import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Core/Colour.dart';
import '../Backend/api_service.dart';
import 'halaman_laporan.dart';
import '../Widget/notification_helper.dart';

// ─── SHARED PREFS ─────────────────────────────────────────────────────────────

// Key untuk menyimpan daftar bulan yang sudah diunduh di penyimpanan lokal perangkat
const String kDownloadedBulanKey = 'downloaded_bulan';

// Simpan catatan bahwa laporan bulan ini sudah diunduh beserta waktu downloadnya
Future<void> simpanBulanDownloaded(String bulan) async {
  final prefs = await SharedPreferences.getInstance();
  final existing = prefs.getStringList(kDownloadedBulanKey) ?? [];
  final waktuDownload = DateTime.now().toIso8601String();
  final entry = '$bulan|$waktuDownload';
  // Hapus entry lama untuk bulan ini kalau ada, ganti dengan yang baru
  existing.removeWhere((e) => e.startsWith('$bulan|'));
  existing.add(entry);
  await prefs.setStringList(kDownloadedBulanKey, existing);
}

// Baca daftar bulan yang pernah diunduh; kembalikan Map { "Mei 2026": DateTime }
Future<Map<String, DateTime>> getBulanDownloaded() async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(kDownloadedBulanKey) ?? [];
  final Map<String, DateTime> result = {};
  for (final entry in list) {
    final parts = entry.split('|');
    if (parts.length == 2) {
      try {
        result[parts[0]] = DateTime.parse(parts[1]);
      } catch (_) {}
    }
  }
  return result;
}

// ─── HELPER ───────────────────────────────────────────────────────────────────

// Versi formatRupiah khusus PDF; contoh: 150000 → "Rp 150.000"
String formatRupiahCetak(int value) {
  final str = value.toString();
  final result = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) result.write('.');
    result.write(str[i]);
    count++;
  }
  return 'Rp ${result.toString().split('').reversed.join()}';
}

// ─── PRINT BUTTON ─────────────────────────────────────────────────────────────

// Tombol ikon download; saat ditekan: generate PDF → share → catat → hapus pesanan → refresh halaman
class CetakLaporanButton extends StatelessWidget {
  final String bulan;
  final int totalTransaksi;
  final int totalPendapatan;
  final int rataPerHari;
  final List<Map<String, dynamic>> details;

  const CetakLaporanButton({
    super.key,
    required this.bulan,
    required this.totalTransaksi,
    required this.totalPendapatan,
    required this.rataPerHari,
    required this.details,
  });

  // Hapus semua pesanan berstatus "selesai" milik bulan ini dari server setelah laporan dicetak
  Future<void> _hapusPesananBulan() async {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];

    final rawPesanan = await ApiService.getPesanan();

    for (final item in rawPesanan) {
      final String status = (
        item['status_pesanan'] ?? item['status'] ?? ''
      ).toString().toLowerCase().trim();

      if (status != 'selesai') continue;

      final String? rawTanggal =
          item['tanggal_pesanan'] ?? item['created_at'] ?? item['tanggal'];
      if (rawTanggal == null || rawTanggal.isEmpty) continue;

      DateTime tgl;
      try {
        tgl = DateTime.parse(rawTanggal.split(' ')[0]);
      } catch (_) {
        continue;
      }

      final String kunciBulan = '${namaBulan[tgl.month]} ${tgl.year}';
      if (kunciBulan != bulan) continue;

      final dynamic id = item['id'] ?? item['id_pesanan'];
      if (id == null) continue;

      try {
        await ApiService.deletePesanan(id.toString());
      } catch (_) {
        // Lanjut ke pesanan berikutnya meski satu gagal dihapus
      }
    }
  }

  // Generate dokumen PDF A4 berisi header, ringkasan statistik, tabel detail harian, dan footer
  Future<pw.Document> _buildPdf() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header: nama app di kiri, label "LAPORAN BULANAN" di kanan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PuddingKu',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#E8701A'),
                        ),
                      ),
                      pw.Text(
                        'Panel Admin UMKM',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColor.fromHex('#6B4226'),
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'LAPORAN BULANAN',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#C45C10'),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 6),
              pw.Divider(color: PdfColor.fromHex('#E8701A'), thickness: 1.5),
              pw.SizedBox(height: 12),

              // Judul laporan bulan
              pw.Text(
                'Laporan $bulan',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#E8701A'),
                ),
              ),
              pw.SizedBox(height: 16),

              // Kotak ringkasan 3 statistik: total transaksi, rata/hari, total pendapatan
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFF3E8'),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(
                      color: PdfColor.fromHex('#E8701A'), width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _pdfStat('Total Transaksi', '${totalTransaksi}x'),
                    _pdfVerticalDivider(),
                    _pdfStat('Rata-rata/Hari', formatRupiahCetak(rataPerHari)),
                    _pdfVerticalDivider(),
                    _pdfStat('Total Pendapatan', formatRupiahCetak(totalPendapatan)),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                'Detail Harian',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#6B4226'),
                ),
              ),
              pw.SizedBox(height: 8),

              // Tabel harian: header oranye, baris selang-seling, baris TOTAL di bawah
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#E0D0C0'),
                  width: 0.5,
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1.5),
                  2: pw.FlexColumnWidth(2.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#E8701A')),
                    children: [
                      _pdfTableCell('Tanggal',
                          isHeader: true, align: pw.Alignment.centerLeft),
                      _pdfTableCell('Transaksi',
                          isHeader: true, align: pw.Alignment.center),
                      _pdfTableCell('Pendapatan',
                          isHeader: true, align: pw.Alignment.centerRight),
                    ],
                  ),
                  ...details.asMap().entries.map((entry) {
                    final i = entry.key;
                    final d = entry.value;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: i.isEven
                            ? PdfColors.white
                            : PdfColor.fromHex('#FFF8F2'),
                      ),
                      children: [
                        _pdfTableCell(d['tanggal'].toString(),
                            align: pw.Alignment.centerLeft),
                        _pdfTableCell('${d['jumlah']}x',
                            align: pw.Alignment.center),
                        _pdfTableCell(
                            formatRupiahCetak(d['pendapatan'] as int),
                            align: pw.Alignment.centerRight),
                      ],
                    );
                  }),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#C45C10')),
                    children: [
                      _pdfTableCell('TOTAL',
                          isHeader: true, align: pw.Alignment.centerLeft),
                      _pdfTableCell('${totalTransaksi}x',
                          isHeader: true, align: pw.Alignment.center),
                      _pdfTableCell(formatRupiahCetak(totalPendapatan),
                          isHeader: true, align: pw.Alignment.centerRight),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer: nama pencetak di kiri, nomor halaman di kanan
              pw.Divider(color: PdfColor.fromHex('#E0D0C0'), thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Dicetak oleh sistem PuddingKu',
                    style: pw.TextStyle(
                        fontSize: 9, color: PdfColor.fromHex('#A07850')),
                  ),
                  pw.Text(
                    'Halaman 1 dari 1',
                    style: pw.TextStyle(
                        fontSize: 9, color: PdfColor.fromHex('#A07850')),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }

  // Widget statistik PDF: label kecil di atas, nilai bold di bawah
  static pw.Widget _pdfStat(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 9, color: PdfColor.fromHex('#A07850'))),
        pw.SizedBox(height: 3),
        pw.Text(value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#6B4226'),
            )),
      ],
    );
  }

  // Garis vertikal tipis sebagai pemisah antar statistik di kotak ringkasan
  static pw.Widget _pdfVerticalDivider() {
    return pw.Container(
        width: 1, height: 36, color: PdfColor.fromHex('#E8701A'));
  }

  // Sel tabel PDF dengan padding; isHeader → teks putih bold, align → posisi teks dalam sel
  static pw.Widget _pdfTableCell(
    String text, {
    bool isHeader = false,
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      alignment: align,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColor.fromHex('#3D2000'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          final doc = await _buildPdf();
          final bytes = await doc.save();
          // Buka dialog share/simpan PDF ke perangkat
          await Printing.sharePdf(
            bytes: bytes,
            filename: 'Laporan_${bulan.replaceAll(" ", "_")}.pdf',
          );
          await simpanBulanDownloaded(bulan);
          await _hapusPesananBulan();
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HalamanLaporan()),
            );
          }
        } catch (e) {
          // Tampilkan snackbar merah jika proses unduh gagal
          if (context.mounted) {
            NotificationHelper.show(
              context,
              message: 'Gagal mengunduh PDF.',
              type: NotificationType.error,
            );
          }
        }
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.info,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.download_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}