import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Core/Colour.dart';

// ─── MODEL (copy dari halaman_laporan.dart, atau bisa di-import jika sudah ada) ─
// Jika TransaksiDetail & LaporanBulan sudah ada di halaman_laporan.dart,
// hapus bagian ini dan ganti dengan import ke file tersebut.
// Contoh: import 'halaman_laporan.dart' show TransaksiDetail, LaporanBulan, formatRupiah;

// ─── HELPER ───────────────────────────────────────────────────────────────────
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
class CetakLaporanButton extends StatelessWidget {
  final String bulan;
  final int totalTransaksi;
  final int totalPendapatan;
  final int rataPerHari;
  final List<Map<String, dynamic>> details;
  // detail item: {'tanggal': String, 'jumlah': int, 'pendapatan': int}

  const CetakLaporanButton({
    super.key,
    required this.bulan,
    required this.totalTransaksi,
    required this.totalPendapatan,
    required this.rataPerHari,
    required this.details,
  });

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
              // ── Header ────────────────────────────────────────────
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

              // ── Judul bulan ───────────────────────────────────────
              pw.Text(
                'Laporan $bulan',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#E8701A'),
                ),
              ),
              pw.SizedBox(height: 16),

              // ── Ringkasan statistik ───────────────────────────────
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

              // ── Tabel detail harian ───────────────────────────────
              pw.Text(
                'Detail Harian',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#6B4226'),
                ),
              ),
              pw.SizedBox(height: 8),

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
                  // Header tabel
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
                  // Baris data harian
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
                  // Baris total
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

              // ── Footer ────────────────────────────────────────────
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

  static pw.Widget _pdfVerticalDivider() {
    return pw.Container(
        width: 1, height: 36, color: PdfColor.fromHex('#E8701A'));
  }

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
          await Printing.layoutPdf(
            onLayout: (_) async => bytes,
            name: 'Laporan_${bulan.replaceAll(' ', '_')}.pdf',
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal membuat PDF: $e'),
                backgroundColor: Colors.red,
              ),
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
          child: Icon(Icons.print_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}