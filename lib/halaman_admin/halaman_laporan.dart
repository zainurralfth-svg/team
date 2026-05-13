import 'package:flutter/material.dart';
import 'halaman_produk.dart';
import 'halaman_riwayat.dart';
import 'halaman_pengguna.dart';
import 'admin.dart';
import 'halaman_profil_admin.dart';

// ─── MODEL ────────────────────────────────────────────────────────────────────

// Model data satu transaksi harian (tanggal, jumlah, pendapatan).
class TransaksiDetail {
  final String tanggal;
  final int jumlah;
  final int pendapatan;

  const TransaksiDetail({
    required this.tanggal,
    required this.jumlah,
    required this.pendapatan,
  });

  factory TransaksiDetail.fromJson(Map<String, dynamic> json) {
    return TransaksiDetail(
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      pendapatan: json['pendapatan'] ?? 0,
    );
  }
}

// Model data laporan satu bulan beserta daftar transaksi hariannya.
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

  // Getter: hitung rata-rata pendapatan per hari dari jumlah data detail.
  int get rataPerHari =>
      details.isEmpty ? 0 : totalPendapatan ~/ details.length;

  factory LaporanBulan.fromJson(Map<String, dynamic> json) {
    final detailList = (json['details'] as List<dynamic>? ?? [])
        .map((e) => TransaksiDetail.fromJson(e))
        .toList();
    return LaporanBulan(
      bulan: json['bulan'] ?? '',
      totalTransaksi: json['total_transaksi'] ?? 0,
      totalPendapatan: json['total_pendapatan'] ?? 0,
      details: detailList,
    );
  }
}

// ─── DUMMY DATA (hapus jika sudah pakai API) ──────────────────────────────────

// Data statis sementara pengganti API; hapus dan ganti dengan data asli.
final List<LaporanBulan> _dummyLaporan = [
  const LaporanBulan(
    bulan: 'Juli 2026',
    totalTransaksi: 12,
    totalPendapatan: 337000,
    details: [
      TransaksiDetail(tanggal: 'Januari 4', jumlah: 2, pendapatan: 70000),
      TransaksiDetail(tanggal: 'Januari 6', jumlah: 10, pendapatan: 267000),
    ],
  ),
  const LaporanBulan(bulan: 'Juni 2026', totalTransaksi: 12, totalPendapatan: 337000),
  const LaporanBulan(bulan: 'Mei 2026', totalTransaksi: 12, totalPendapatan: 337000),
  const LaporanBulan(bulan: 'April 2026', totalTransaksi: 12, totalPendapatan: 337000),
  const LaporanBulan(bulan: 'Maret 2026', totalTransaksi: 12, totalPendapatan: 337000),
  const LaporanBulan(bulan: 'Februari 2026', totalTransaksi: 12, totalPendapatan: 337000),
  const LaporanBulan(bulan: 'Januari 2026', totalTransaksi: 12, totalPendapatan: 337000),
];

// ─── HELPER ───────────────────────────────────────────────────────────────────

// Mengubah angka integer menjadi format "Rp 337.000".
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

// ─── WARNA ────────────────────────────────────────────────────────────────────

// Kumpulan konstanta warna tema cokelat/krem untuk seluruh halaman.
class _C {
  static const cream = Color(0xFFFFF3DC);
  static const brown = Color(0xFF8B5E2D);
  static const brownDark = Color(0xFF6B4520);
  static const accentOrange = Color(0xFFE8841A);
  static const textLight = Color(0xFFB08050);
  static const textDark = Color(0xFF3D2400);
  static const blue = Color(0xFF4A90D9);
  static const blueDark = Color(0xFF2E6DB4);
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

  // Memuat data laporan saat halaman dibuka; ganti dummy dengan API nyata di sini.
  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _laporan = _dummyLaporan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFD27F30);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
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
      bottomNavigationBar: Container(
        height: 75,
        color: primaryOrange,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavIcon(context, Icons.assignment_outlined, 'Laporan', true, () {}), // Aktif
            _buildNavIcon(context, Icons.cake_outlined, 'Produk', false,
                () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HalamanProduk()))),
            _buildNavIcon(context, Icons.home_outlined, 'Beranda', false,
                () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeAdmin()))),
            _buildNavIcon(context, Icons.history, 'Riwayat', false,
                () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HalamanRiwayat()))),
            _buildNavIcon(context, Icons.person_outline, 'Pengguna', false,
                () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HalamanPengguna()))),
          ],
        ),
      ),
    );
  }

  // Item navigasi bawah; lingkaran gelap muncul di belakang ikon yang sedang aktif.
  Widget _buildNavIcon(BuildContext context, IconData icon, String label,
      bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.black.withOpacity(0.3)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          Text(label,
              style: const TextStyle(
                fontFamily: 'Signika Negative',
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  // Menampilkan spinner saat loading, pesan error jika gagal, atau daftar kartu laporan.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _C.accentOrange),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _C.accentOrange, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: _C.textLight)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() { _isLoading = true; _error = null; });
                _loadData();
              },
              style: ElevatedButton.styleFrom(backgroundColor: _C.brown),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: _C.accentOrange,
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

// Header atas: nama app & subtitle di kiri, foto profil admin di kanan.
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
              Text(
                'PuddingKu',
                style: TextStyle(
                  color: Color(0xFFC17F3E),
                  fontSize: 24,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Panel Admin UMKM',
                style: TextStyle(
                  color: Color(0xFFA89070),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(
            context,
          MaterialPageRoute(builder: (_) => const HalamanProfilAdmin()),
          ),
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

// Label bertuliskan "LAPORAN" sebagai penanda judul halaman.
class _PageLabel extends StatelessWidget {
  const _PageLabel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: _C.brown, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'LAPORAN',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _C.brownDark,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── LAPORAN CARD ─────────────────────────────────────────────────────────────

// Kartu expandable per bulan; kartu pertama terbuka secara default.
class _LaporanCard extends StatefulWidget {
  final LaporanBulan laporan;
  final bool initiallyExpanded;

  const _LaporanCard({required this.laporan, this.initiallyExpanded = false});

  @override
  State<_LaporanCard> createState() => _LaporanCardState();
}

// Mengelola animasi buka/tutup kartu dengan AnimationController 250ms.
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

  // Membalik state expand dan menjalankan animasi maju atau mundur.
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
      shadowColor: _C.brown.withOpacity(0.2),
      child: Column(
        children: [
          // Header kartu – selalu terlihat, ditekan untuk buka/tutup detail.
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
                        Text(
                          'Laporan ${l.bulan}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.accentOrange,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l.totalTransaksi} transaksi · ${formatRupiah(l.totalPendapatan)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _C.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _PrintButton(bulan: l.bulan),
                ],
              ),
            ),
          ),

          // Bagian detail yang muncul/hilang dengan animasi SizeTransition.
          SizeTransition(
            sizeFactor: _anim,
            child: Column(
              children: [
                const Divider(color: Color(0xFFF5EAD8), height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      _StatPill(label: 'Transaksi', value: '${l.totalTransaksi}x'),
                      const SizedBox(width: 8),
                      _StatPill(
                        label: 'Rata/Hari',
                        value: formatRupiah(
                          l.details.isEmpty
                              ? l.totalPendapatan ~/ 2
                              : l.rataPerHari,
                        ),
                      ),
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

// Kotak bergradient dengan emoji 📋 sebagai ikon dekoratif header kartu.
class _CardIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8BB), Color(0xFFFFF3DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _C.brown.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(child: Text('📋', style: TextStyle(fontSize: 20))),
    );
  }
}

// ─── PRINT BUTTON ─────────────────────────────────────────────────────────────

// Tombol cetak biru; saat ini hanya tampilkan SnackBar, belum implementasi cetak.
class _PrintButton extends StatelessWidget {
  final String bulan;
  const _PrintButton({required this.bulan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mencetak laporan $bulan...'),
            backgroundColor: _C.brown,
          ),
        );
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_C.blue, _C.blueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _C.blue.withOpacity(0.4),
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

// ─── STAT PILL ────────────────────────────────────────────────────────────────

// Pill ringkasan statistik (label + nilai) yang dibagi rata dalam tiga kolom.
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
          color: _C.cream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.textLight,
                  letterSpacing: 0.3,
                )),
            const SizedBox(height: 3),
            Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _C.brownDark,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── LAPORAN TABLE ────────────────────────────────────────────────────────────

// Tabel rincian harian: header cokelat → baris zebra striping → baris total.
class _LaporanTable extends StatelessWidget {
  final LaporanBulan laporan;
  const _LaporanTable({required this.laporan});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: _C.brown,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              Expanded(child: Text('Tanggal', style: _tableHeadStyle)),
              Expanded(child: Text('Transaksi', textAlign: TextAlign.center, style: _tableHeadStyle)),
              Expanded(child: Text('Pendapatan', textAlign: TextAlign.right, style: _tableHeadStyle)),
            ],
          ),
        ),

        // Rows
        ...laporan.details.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          return Container(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : const Color(0xFFFFF9F0),
              border: const Border(bottom: BorderSide(color: Color(0xFFF8F0E4))),
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

        // Total
        Container(
          decoration: const BoxDecoration(
            color: _C.brown,
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

  static const _tableHeadStyle = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white,
  );
  static const _tableRowStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, color: _C.textDark,
  );
  static const _tableTotalStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white,
  );
}