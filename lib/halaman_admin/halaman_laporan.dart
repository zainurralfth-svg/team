import 'package:flutter/material.dart';
import 'halaman_produk.dart';
import 'riwayat_pesanan.dart';
import 'halaman_pengguna.dart';
import 'admin.dart';
import 'halaman_profil_admin.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart';
import '../Widget/custom_navbar.dart';
import 'cetak_laporan.dart';

// ─── MODEL ────────────────────────────────────────────────────────────────────

class TransaksiDetail {
  final String tanggal;
  final int jumlah;
  final int pendapatan;

  const TransaksiDetail({
    required this.tanggal,
    required this.jumlah,
    required this.pendapatan,
  });
}

class LaporanBulan {
  final String bulan;
  final int totalTransaksi;
  final int totalPendapatan;
  final List<TransaksiDetail> details;

  const LaporanBulan({
    required this.bulan,
    required this.totalTransaksi,
    required this.totalPendapatan,
    this.details = const [],
  });

  int get rataPerHari =>
      details.isEmpty ? 0 : totalPendapatan ~/ details.length;
}

// ─── HELPER ───────────────────────────────────────────────────────────────────

String formatRupiah(int value) {
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

// ─── PARSER ───────────────────────────────────────────────────────────────────

List<LaporanBulan> _parseLaporan(List<dynamic> rawPesanan) {
  const namaBulan = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  final Map<String, Map<String, Map<String, int>>> grupBulan = {};
  final Map<String, DateTime> urutan = {};

  for (final item in rawPesanan) {
    final String status = (
      item['status_pesanan'] ?? item['status'] ?? ''
    ).toString().toLowerCase().trim();

    if (status != 'selesai') continue;

    final String? rawTanggal =
        item['tanggal_pesanan'] ?? item['created_at'] ?? item['tanggal'];
    final dynamic rawHarga = item['total_harga'] ?? item['harga_total'] ?? 0;

    if (rawTanggal == null || rawTanggal.isEmpty) continue;

    DateTime tgl;
    try {
      tgl = DateTime.parse(rawTanggal.split(' ')[0]);
    } catch (_) {
      continue;
    }

    final int harga = int.tryParse(rawHarga.toString()) ?? 0;
    final String kunciBulan = '${namaBulan[tgl.month]} ${tgl.year}';
    final String kunciHari = '${tgl.day} ${namaBulan[tgl.month]}';

    urutan.putIfAbsent(kunciBulan, () => DateTime(tgl.year, tgl.month));
    grupBulan.putIfAbsent(kunciBulan, () => {});
    grupBulan[kunciBulan]!.putIfAbsent(kunciHari, () => {'jumlah': 0, 'pendapatan': 0});
    grupBulan[kunciBulan]![kunciHari]!['jumlah'] =
        (grupBulan[kunciBulan]![kunciHari]!['jumlah'] ?? 0) + 1;
    grupBulan[kunciBulan]![kunciHari]!['pendapatan'] =
        (grupBulan[kunciBulan]![kunciHari]!['pendapatan'] ?? 0) + harga;
  }

  final sortedKeys = urutan.keys.toList()
    ..sort((a, b) => urutan[b]!.compareTo(urutan[a]!));

  return sortedKeys.map((bulan) {
    final hariMap = grupBulan[bulan]!;
    final details = hariMap.entries.map((e) => TransaksiDetail(
      tanggal: e.key,
      jumlah: e.value['jumlah'] ?? 0,
      pendapatan: e.value['pendapatan'] ?? 0,
    )).toList()
      ..sort((a, b) {
        final da = int.tryParse(a.tanggal.split(' ')[0]) ?? 0;
        final db = int.tryParse(b.tanggal.split(' ')[0]) ?? 0;
        return da.compareTo(db);
      });

    return LaporanBulan(
      bulan: bulan,
      totalTransaksi: details.fold(0, (s, d) => s + d.jumlah),
      totalPendapatan: details.fold(0, (s, d) => s + d.pendapatan),
      details: details,
    );
  }).toList();
}

// ─── HALAMAN LAPORAN ──────────────────────────────────────────────────────────

class HalamanLaporan extends StatefulWidget {
  const HalamanLaporan({super.key});

  @override
  State<HalamanLaporan> createState() => _HalamanLaporanState();
}

class _HalamanLaporanState extends State<HalamanLaporan> {
  List<LaporanBulan> _laporan = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rawPesanan = await ApiService.getPesanan();
      setState(() {
        _laporan = rawPesanan.isEmpty ? [] : _parseLaporan(rawPesanan);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AppHeader(),
            const _PageLabel(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HalamanProduk()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeAdmin()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HalamanRiwayat()));
          if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HalamanPengguna()));
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.textBrown)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (_laporan.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, color: AppColors.textHint, size: 56),
            const SizedBox(height: 12),
            const Text('Belum ada data laporan.',
                style: TextStyle(color: AppColors.textHint, fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Muat Ulang', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        itemCount: _laporan.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LaporanCard(
            laporan: _laporan[i],
            initiallyExpanded: i == 0,
          ),
        ),
      ),
    );
  }
}

// ─── APP HEADER ───────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PuddingKu',
                  style: TextStyle(
                    fontFamily: 'Signika Negative',
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  )),
              SizedBox(height: 2),
              Text('Panel Admin UMKM',
                  style: TextStyle(
                    fontFamily: 'Signika Negative',
                    color: AppColors.textBrown,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HalamanProfilAdmin())),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/profil admin.png'),
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PAGE LABEL ───────────────────────────────────────────────────────────────

class _PageLabel extends StatelessWidget {
  const _PageLabel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text('LAPORAN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 1.5,
            )),
      ),
    );
  }
}

// ─── LAPORAN CARD ─────────────────────────────────────────────────────────────

class _LaporanCard extends StatefulWidget {
  final LaporanBulan laporan;
  final bool initiallyExpanded;

  const _LaporanCard({required this.laporan, this.initiallyExpanded = false});

  @override
  State<_LaporanCard> createState() => _LaporanCardState();
}

class _LaporanCardState extends State<_LaporanCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.initiallyExpanded ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.laporan;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: AppColors.shadow,
      child: Column(
        children: [
          // Header kartu
          InkWell(
            onTap: _toggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  _CardIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Laporan ${l.bulan}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            )),
                        const SizedBox(height: 2),
                        Text(
                          '${l.totalTransaksi} transaksi · ${formatRupiah(l.totalPendapatan)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ─── Tombol cetak dari cetak_laporan.dart ───────────
                  CetakLaporanButton(
                    bulan: l.bulan,
                    totalTransaksi: l.totalTransaksi,
                    totalPendapatan: l.totalPendapatan,
                    rataPerHari: l.rataPerHari,
                    details: l.details.map((d) => {
                      'tanggal': d.tanggal,
                      'jumlah': d.jumlah,
                      'pendapatan': d.pendapatan,
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Detail expand/collapse
          SizeTransition(
            sizeFactor: _anim,
            child: Column(
              children: [
                const Divider(color: AppColors.bgInput, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      _StatPill(label: 'Transaksi', value: '${l.totalTransaksi}x'),
                      const SizedBox(width: 8),
                      _StatPill(label: 'Rata/Hari', value: formatRupiah(l.rataPerHari)),
                      const SizedBox(width: 8),
                      _StatPill(label: 'Total', value: formatRupiah(l.totalPendapatan)),
                    ],
                  ),
                ),
                if (l.details.isNotEmpty) _LaporanTable(laporan: l),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CARD ICON ────────────────────────────────────────────────────────────────

class _CardIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.bgUtama,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(child: Text('📋', style: TextStyle(fontSize: 20))),
    );
  }
}

// ─── STAT PILL ────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHint,
                  letterSpacing: 0.3,
                )),
            const SizedBox(height: 3),
            Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBrown,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── LAPORAN TABLE ────────────────────────────────────────────────────────────

class _LaporanTable extends StatelessWidget {
  final LaporanBulan laporan;
  const _LaporanTable({required this.laporan});

  static const _tableHeadStyle = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textWhite,
  );
  static const _tableRowStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark,
  );
  static const _tableTotalStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textWhite,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header tabel
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              Expanded(child: Text('Tanggal', style: _tableHeadStyle)),
              Expanded(child: Text('Transaksi', textAlign: TextAlign.center, style: _tableHeadStyle)),
              Expanded(child: Text('Pendapatan', textAlign: TextAlign.right, style: _tableHeadStyle)),
            ],
          ),
        ),

        // Baris data harian
        ...laporan.details.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          return Container(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : AppColors.bgCard,
              border: const Border(bottom: BorderSide(color: AppColors.bgUtama)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(d.tanggal, style: _tableRowStyle)),
                Expanded(child: Text('${d.jumlah}x', textAlign: TextAlign.center, style: _tableRowStyle)),
                Expanded(child: Text(formatRupiah(d.pendapatan), textAlign: TextAlign.right, style: _tableRowStyle)),
              ],
            ),
          );
        }),

        // Baris total
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: [
              const Expanded(child: Text('TOTAL', style: _tableTotalStyle)),
              Expanded(child: Text('${laporan.totalTransaksi}x', textAlign: TextAlign.center, style: _tableTotalStyle)),
              Expanded(child: Text(formatRupiah(laporan.totalPendapatan), textAlign: TextAlign.right, style: _tableTotalStyle)),
            ],
          ),
        ),
      ],
    );
  }
}