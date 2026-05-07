import 'package:flutter/material.dart';
import '../Backend/Api_service.dart';

// Halaman laporan penjualan, StatefulWidget karena datanya bisa berubah
class HalamanLaporan extends StatefulWidget {
  const HalamanLaporan({super.key});

  @override
  State<HalamanLaporan> createState() => _HalamanLaporanState();
}

class _HalamanLaporanState extends State<HalamanLaporan> {
  bool _isLoading = true; // status loading data dari API
  String? _errorMsg; // pesan error jika koneksi gagal
  List<Map<String, dynamic>> _dataLaporan = []; // data laporan per bulan
  int _totalKeseluruhan = 0; // total pendapatan bulan ini

  @override
  void initState() {
    super.initState();
    _loadLaporan(); // langsung load data saat halaman dibuka
  }

  // Ambil data pesanan dari API, filter yang selesai, kelompokkan per bulan
  Future<void> _loadLaporan() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final List<dynamic> pesanan = await ApiService.getPesanan(); // ambil semua pesanan

      if (pesanan.isEmpty) {
        setState(() {
          _dataLaporan = [];
          _totalKeseluruhan = 0;
          _isLoading = false;
        });
        return;
      }

      final Map<String, Map<String, dynamic>> grupBulan = {}; // wadah pengelompokan per bulan

      for (var item in pesanan) {
        final String status = item['status_pesanan']?.toString().toLowerCase() ?? '';
        if (status != 'selesai') continue; // skip pesanan yang belum selesai

        final String rawTanggal =
            item['created_at'] ?? item['tanggal_pesan'] ?? item['tanggal_pesanan'] ?? '';
        if (rawTanggal.isEmpty) continue; // skip jika tanggal kosong

        final DateTime? tgl = _parseDate(rawTanggal); // ubah string ke DateTime
        if (tgl == null) continue; // skip jika format tanggal tidak valid

        final String keyBulan = '${tgl.year}-${tgl.month.toString().padLeft(2, '0')}'; // contoh: "2026-05"
        final int harga = int.tryParse(item['total_harga']?.toString() ?? '0') ?? 0; // total harga pesanan
        final int tglHari = tgl.day; // angka hari, contoh: 6

        // buat grup bulan baru jika belum ada
        grupBulan.putIfAbsent(keyBulan, () => {
              'bulan': _namaBulan(tgl.month),
              'tahun': tgl.year,
              'total': 0,
              'transaksi': 0,
              'harian': <String, Map<String, dynamic>>{},
            });

        grupBulan[keyBulan]!['total'] += harga; // tambah total pendapatan bulan
        grupBulan[keyBulan]!['transaksi'] += 1; // tambah jumlah transaksi bulan

        final harianMap = grupBulan[keyBulan]!['harian'] as Map<String, Map<String, dynamic>>;

        // buat data hari baru jika belum ada
        harianMap.putIfAbsent(
            tglHari.toString(),
            () => {
                  'tanggal': tglHari,
                  'pendapatan': 0,
                  'transaksi': 0,
                });

        harianMap[tglHari.toString()]!['pendapatan'] += harga; // tambah pendapatan hari itu
        harianMap[tglHari.toString()]!['transaksi'] += 1; // tambah transaksi hari itu
      }

      final now = DateTime.now();
      final String keyBulanIni = '${now.year}-${now.month.toString().padLeft(2, '0')}'; // key bulan sekarang
      int totalBulanIni = 0;

      final sortedKeys = grupBulan.keys.toList()..sort(); // urutkan bulan
      final List<Map<String, dynamic>> hasil = [];

      for (final key in sortedKeys.reversed) { // terbaru di atas
        final bulan = grupBulan[key]!;
        final harianList =
            (bulan['harian'] as Map<String, Map<String, dynamic>>)
                .values
                .toList()
              ..sort((a, b) => (a['tanggal'] as int).compareTo(b['tanggal'] as int)); // urut tanggal

        hasil.add({
          'bulan': bulan['bulan'],
          'tahun': bulan['tahun'],
          'total': bulan['total'],
          'transaksi': bulan['transaksi'],
          'harian': harianList,
        });

        if (key == keyBulanIni) totalBulanIni = bulan['total'] as int; // simpan total bulan ini
      }

      setState(() {
        _dataLaporan = hasil;
        _totalKeseluruhan = totalBulanIni;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal memuat laporan: $e'; // tampilkan pesan error
        _isLoading = false;
      });
    }
  }

  // Ubah string tanggal "2026-05-06 12:00:00" menjadi DateTime
  DateTime? _parseDate(String raw) {
    try {
      return DateTime.parse(raw.trim());
    } catch (_) {
      return null;
    }
  }

  // Ubah angka bulan menjadi nama, contoh: 5 → "Mei"
  String _namaBulan(int bulan) {
    const nama = [
      '',
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return nama[bulan];
  }

  // Ubah angka menjadi format Rupiah, contoh: 70000 → "Rp 70.000"
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

  // Tampilan utama: pilih antara loading, error, kosong, atau ada data
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
            onPressed: _loadLaporan, // tombol refresh data
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5ECD7),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD27F30))) // loading spinner
            : _errorMsg != null
                ? _buildError() // tampilan error
                : _dataLaporan.isEmpty
                    ? _buildKosong() // tampilan kosong
                    : _buildIsiLaporan(), // tampilan laporan
      ),
    );
  }

  // Tampilan saat gagal konek API: ikon wifi off + tombol coba lagi
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD27F30)),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
              onPressed: _loadLaporan,
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan saat tidak ada data pesanan sama sekali
  Widget _buildKosong() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text('Belum ada data pesanan', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Tampilan utama: header pendapatan + label LAPORAN + list kartu bulan
  Widget _buildIsiLaporan() {
    return Column(
      children: [
        _buildHeaderPendapatan(), // kotak total pendapatan bulan ini
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD27F30), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LAPORAN',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD27F30), fontSize: 13),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _dataLaporan.length,
            itemBuilder: (context, index) => _buildKartuLaporan(_dataLaporan[index]), // kartu per bulan
          ),
        ),
      ],
    );
  }

  // Kotak putih di atas yang menampilkan total pendapatan bulan ini
  Widget _buildHeaderPendapatan() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Pendapatan Bulan Ini', style: TextStyle(fontSize: 14, color: Colors.black87)),
          Text(
            _formatRupiah(_totalKeseluruhan), // tampilkan dalam format Rupiah
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD27F30)),
          ),
        ],
      ),
    );
  }

  // Kartu per bulan yang bisa di-expand untuk lihat detail harian
  Widget _buildKartuLaporan(Map<String, dynamic> laporan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // hilangkan divider bawaan
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFF5ECD7), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.description_outlined, color: Color(0xFFD27F30)), // ikon dokumen
          ),
          title: Text(
            'Laporan ${laporan['bulan']} ${laporan['tahun']}', // contoh: "Laporan Mei 2026"
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            '${laporan['transaksi']} transaksi • ${_formatRupiah(laporan['total'])}', // ringkasan singkat
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.print_outlined, color: Color(0xFFD27F30), size: 22),
                onPressed: () => _onCetakLaporan('${laporan['bulan']} ${laporan['tahun']}'), // tombol cetak
                tooltip: 'Cetak Laporan',
              ),
            ],
          ),
          children: [_buildDetailBulanan(laporan)], // isi detail saat di-expand
        ),
      ),
    );
  }

  // Isi detail kartu: 3 box ringkasan + tabel harian + baris total
  Widget _buildDetailBulanan(Map<String, dynamic> laporan) {
    final List<dynamic> harian = laporan['harian'];
    final int total = laporan['total'] as int;
    final double rataHarian = harian.isNotEmpty ? total / harian.length : 0; // rata-rata per hari

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFEEDDC0)), // garis pemisah
          _buildRingkasanBulanan(laporan, rataHarian), // 3 box: Total, Rata/Hari, Transaksi
          const SizedBox(height: 12),
          // header tabel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFD27F30), borderRadius: BorderRadius.circular(6)),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text('Transaksi', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 3, child: Text('Pendapatan', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
          // baris data harian dengan warna selang-seling
          ...harian.asMap().entries.map((entry) {
            final idx = entry.key;
            final hari = entry.value;
            final isGanjil = idx % 2 == 0; // putih atau krem
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isGanjil ? Colors.white : const Color(0xFFFBF5EA),
                borderRadius: idx == harian.length - 1 // sudut melengkung hanya di baris terakhir
                    ? const BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('${laporan['bulan'].toString().substring(0, 3)} ${hari['tanggal']}', style: const TextStyle(fontSize: 12))), // contoh: "Mei 6"
                  Expanded(flex: 2, child: Text('${hari['transaksi']}x', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                  Expanded(flex: 3, child: Text(_formatRupiah(hari['pendapatan'] as int), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // baris total keseluruhan bulan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFFEDD9B0), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                const Expanded(flex: 2, child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text('${laporan['transaksi']}x', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 3, child: Text(_formatRupiah(total), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3 box ringkasan berjajar: Total → Rata/Hari → Transaksi
  Widget _buildRingkasanBulanan(Map<String, dynamic> laporan, double rataHarian) {
    return Row(
      children: [
        _buildStatBox(icon: Icons.attach_money, label: 'Total', value: _formatRupiah(laporan['total'])),
        const SizedBox(width: 8),
        _buildStatBox(icon: Icons.trending_up, label: 'Rata/Hari', value: _formatRupiah(rataHarian.toInt())),
        const SizedBox(width: 8),
        _buildStatBox(icon: Icons.receipt_long, label: 'Transaksi', value: '${laporan['transaksi']}x'),
      ],
    );
  }

  // Template 1 box ringkasan, dipakai ulang 3x
  Widget _buildStatBox({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5ECD7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEDD9B0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFD27F30), size: 18), // ikon
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), // label kecil
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center), // nilai
          ],
        ),
      ),
    );
  }

  // Dipanggil saat tombol print ditekan, saat ini hanya tampilkan notifikasi
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