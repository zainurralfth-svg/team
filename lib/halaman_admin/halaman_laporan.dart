import 'package:flutter/material.dart';
import '../Backend/Api_service.dart';

class HalamanLaporan extends StatefulWidget {
  const HalamanLaporan({super.key});

  @override
  State<HalamanLaporan> createState() => _HalamanLaporanState();
}

class _HalamanLaporanState extends State<HalamanLaporan> {
  bool _isLoading = true;
  String? _errorMsg;

  List<Map<String, dynamic>> _dataLaporan = [];
  int _totalKeseluruhan = 0;

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  /// Ambil semua pesanan dari API lalu kelompokkan per bulan & per hari secara otomatis
  Future<void> _loadLaporan() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // Ambil semua pesanan dari server (admin = tanpa filter id_user)
      final List<dynamic> pesanan = await ApiService.getPesanan();

      if (pesanan.isEmpty) {
        setState(() {
          _dataLaporan = [];
          _totalKeseluruhan = 0;
          _isLoading = false;
        });
        return;
      }

      // Kelompokkan per bulan, key: "YYYY-MM"
      final Map<String, Map<String, dynamic>> grupBulan = {};

      for (var item in pesanan) {
        // ✅ Hanya masukkan pesanan yang sudah selesai
        final String status = item['status_pesanan']?.toString().toLowerCase() ?? '';
        if (status != 'selesai') continue;

        // Sesuaikan nama field dengan response API kamu:
        // created_at atau tanggal_pesanan → format "YYYY-MM-DD HH:mm:ss"
        final String rawTanggal =
            item['created_at'] ?? item['tanggal_pesan'] ?? item['tanggal_pesanan'] ?? '';
        if (rawTanggal.isEmpty) continue;

        final DateTime? tgl = _parseDate(rawTanggal);
        if (tgl == null) continue;

        final String keyBulan =
            '${tgl.year}-${tgl.month.toString().padLeft(2, '0')}';
        final int harga =
            int.tryParse(item['total_harga']?.toString() ?? '0') ?? 0;
        final int tglHari = tgl.day;

        // Inisialisasi grup bulan
        grupBulan.putIfAbsent(keyBulan, () => {
              'bulan': _namaBulan(tgl.month),
              'tahun': tgl.year,
              'total': 0,
              'transaksi': 0,
              'harian': <String, Map<String, dynamic>>{},
            });

        grupBulan[keyBulan]!['total'] += harga;
        grupBulan[keyBulan]!['transaksi'] += 1;

        // Kelompokkan harian
        final harianMap = grupBulan[keyBulan]!['harian']
            as Map<String, Map<String, dynamic>>;
        harianMap.putIfAbsent(
            tglHari.toString(),
            () => {
                  'tanggal': tglHari,
                  'pendapatan': 0,
                  'transaksi': 0,
                });
        harianMap[tglHari.toString()]!['pendapatan'] += harga;
        harianMap[tglHari.toString()]!['transaksi'] += 1;
      }

      // Konversi ke List, urutkan terbaru di atas
      final now = DateTime.now();
      final String keyBulanIni =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      int totalBulanIni = 0;
      final sortedKeys = grupBulan.keys.toList()..sort();
      final List<Map<String, dynamic>> hasil = [];

      for (final key in sortedKeys.reversed) {
        final bulan = grupBulan[key]!;
        final harianList =
            (bulan['harian'] as Map<String, Map<String, dynamic>>)
                .values
                .toList()
              ..sort((a, b) =>
                  (a['tanggal'] as int).compareTo(b['tanggal'] as int));
        hasil.add({
          'bulan': bulan['bulan'],
          'tahun': bulan['tahun'],
          'total': bulan['total'],
          'transaksi': bulan['transaksi'],
          'harian': harianList,
        });
        if (key == keyBulanIni) totalBulanIni = bulan['total'] as int;
      }

      setState(() {
        _dataLaporan = hasil;
        _totalKeseluruhan = totalBulanIni;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal memuat laporan: $e';
        _isLoading = false;
      });
    }
  }

  DateTime? _parseDate(String raw) {
    try {
      return DateTime.parse(raw.trim());
    } catch (_) {
      return null;
    }
  }

  String _namaBulan(int bulan) {
    const nama = [
      '',
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return nama[bulan];
  }

  String _formatRupiah(int angka) {
    final str = angka.toString();
    String hasil = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) hasil = '.$hasil';
      hasil = str[i] + hasil;
      count++;
    }
    return 'Rp $hasil';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: const Color(0xFFD27F30),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadLaporan,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5ECD7),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD27F30)))
            : _errorMsg != null
                ? _buildError()
                : _dataLaporan.isEmpty
                    ? _buildKosong()
                    : _buildIsiLaporan(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD27F30)),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
              onPressed: _loadLaporan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text('Belum ada data pesanan',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildIsiLaporan() {
    return Column(
      children: [
        _buildHeaderPendapatan(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color(0xFFD27F30), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LAPORAN',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD27F30),
                    fontSize: 13),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _dataLaporan.length,
            itemBuilder: (context, index) =>
                _buildKartuLaporan(_dataLaporan[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderPendapatan() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Pendapatan Bulan Ini',
              style: TextStyle(fontSize: 14, color: Colors.black87)),
          Text(
            _formatRupiah(_totalKeseluruhan),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD27F30)),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuLaporan(Map<String, dynamic> laporan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5ECD7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined,
                color: Color(0xFFD27F30)),
          ),
          title: Text(
            'Laporan ${laporan['bulan']} ${laporan['tahun']}',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            '${laporan['transaksi']} transaksi • ${_formatRupiah(laporan['total'])}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.print_outlined,
                    color: Color(0xFFD27F30), size: 22),
                onPressed: () => _onCetakLaporan(
                    '${laporan['bulan']} ${laporan['tahun']}'),
                tooltip: 'Cetak Laporan',
              ),
            ],
          ),
          children: [_buildDetailBulanan(laporan)],
        ),
      ),
    );
  }

  Widget _buildDetailBulanan(Map<String, dynamic> laporan) {
    final List<dynamic> harian = laporan['harian'];
    final int total = laporan['total'] as int;
    final double rataHarian =
        harian.isNotEmpty ? total / harian.length : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFEEDDC0)),
          _buildRingkasanBulanan(laporan, rataHarian),
          const SizedBox(height: 12),
          // Header tabel harian
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD27F30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Tanggal',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                Expanded(
                    flex: 2,
                    child: Text('Transaksi',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                Expanded(
                    flex: 3,
                    child: Text('Pendapatan',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
              ],
            ),
          ),
          // Baris data harian
          ...harian.asMap().entries.map((entry) {
            final idx = entry.key;
            final hari = entry.value;
            final isGanjil = idx % 2 == 0;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color:
                    isGanjil ? Colors.white : const Color(0xFFFBF5EA),
                borderRadius: idx == harian.length - 1
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${laporan['bulan'].toString().substring(0, 3)} ${hari['tanggal']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${hari['transaksi']}x',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      _formatRupiah(hari['pendapatan'] as int),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // Baris total
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEDD9B0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text('TOTAL',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${laporan['transaksi']}x',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _formatRupiah(total),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanBulanan(
      Map<String, dynamic> laporan, double rataHarian) {
    return Row(
      children: [
        _buildStatBox(
            icon: Icons.attach_money,
            label: 'Total',
            value: _formatRupiah(laporan['total'])),
        const SizedBox(width: 8),
        _buildStatBox(
            icon: Icons.trending_up,
            label: 'Rata/Hari',
            value: _formatRupiah(rataHarian.toInt())),
        const SizedBox(width: 8),
        _buildStatBox(
            icon: Icons.receipt_long,
            label: 'Transaksi',
            value: '${laporan['transaksi']}x'),
      ],
    );
  }

  Widget _buildStatBox(
      {required IconData icon,
      required String label,
      required String value}) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5ECD7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEDD9B0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFD27F30), size: 18),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _onCetakLaporan(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mencetak Laporan $label...'),
        backgroundColor: const Color(0xFFD27F30),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}