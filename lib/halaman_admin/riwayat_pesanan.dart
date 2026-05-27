import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart';
import 'halaman_pengguna.dart';
import 'admin.dart';
import 'halaman_profil_admin.dart';
import 'halaman_produk.dart';
import 'halaman_laporan.dart';
import '../Widget/custom_admin_navbar.dart';
import 'cetak_laporan.dart' show getBulanDownloaded;
import '../Widget/custom_text.dart'; 

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  List<dynamic> _listPesanan = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Set<int> _expandedIndexes = {};
  Map<String, DateTime> _downloadedBulan = {};

  @override
  void initState() {
    super.initState();
    _fetchDataPesanan();
    _loadDownloadedBulan();
  }

  Future<void> _loadDownloadedBulan() async {
    final map = await getBulanDownloaded();
    setState(() => _downloadedBulan = map);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDownloadedBulan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDataPesanan() async {
    await _loadDownloadedBulan();
    try {
      final data = await ApiService.getPesanan();
      setState(() {
        _listPesanan = data.where((item) {
          String status = item['status_pesanan'] ?? '';
          return status == 'SELESAI' || status == 'DIBATALKAN';
        }).toList()
          ..sort((a, b) {
            String waktuA = a['updated_at'] ?? a['tanggal_pesan'] ?? '';
            String waktuB = b['updated_at'] ?? b['tanggal_pesan'] ?? '';
            return waktuB.compareTo(waktuA);
          });
        _isLoading = false;
        _expandedIndexes.clear();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching pesanan: $e");
    }
  }

  bool _isBulanDownloaded(dynamic item) {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final String? rawTanggal = item['tanggal_pesan'] ?? item['tanggal_pesanan'] ?? item['created_at'];
    if (rawTanggal == null || rawTanggal.isEmpty) return false;
    try {
      final tglPesanan = DateTime.parse(rawTanggal.split(' ')[0]);
      final kunciBulan = '${namaBulan[tglPesanan.month]} ${tglPesanan.year}';
      final waktuDownload = _downloadedBulan[kunciBulan];
      if (waktuDownload == null) return false;
      return tglPesanan.isBefore(waktuDownload);
    } catch (_) {
      return false;
    }
  }

  List<dynamic> get _filteredList {
    final baseList = _listPesanan.where((item) => !_isBulanDownloaded(item)).toList();
    if (_searchQuery.isEmpty) return baseList;
    return baseList.where((item) {
      final nama = (item['nama_pemesan'] ?? '').toLowerCase();
      final ringkasan = (item['ringkasan_pesanan'] ?? '').toLowerCase();
      final status = (item['status_pesanan'] ?? '').toLowerCase();
      return nama.contains(_searchQuery) ||
          ringkasan.contains(_searchQuery) ||
          status.contains(_searchQuery);
    }).toList();
  }

  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // ==========================================
  // FORMAT TANGGAL: "12 Januari 2025"
  // ==========================================
  String _formatTanggal(Map<String, dynamic> item) {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];

    String status = (item['status_pesanan'] ?? '').toString().toUpperCase();
    String? rawTime;

    if (status == 'SELESAI' || status == 'DIBATALKAN') {
      rawTime = item['updated_at'] ?? item['tanggal_pesanan'] ?? item['tanggal_pesan'] ?? item['created_at'];
    } else {
      rawTime = item['tanggal_pesanan'] ?? item['tanggal_pesan'] ?? item['created_at'];
    }

    if (rawTime == null || rawTime.isEmpty) return '';

    try {
      final tgl = DateTime.parse(rawTime.split(' ')[0]);
      return '${tgl.day} ${namaBulan[tgl.month]} ${tgl.year}';
    } catch (_) {
      return '';
    }
  }

  // ==========================================
  // FORMAT JAM: "14:30"
  // ==========================================
  String _formatJam(Map<String, dynamic> item) {
    String status = (item['status_pesanan'] ?? '').toString().toUpperCase();
    String? rawTime;

    if (status == 'SELESAI' || status == 'DIBATALKAN') {
      rawTime = item['updated_at'] ?? item['tanggal_pesanan'] ?? item['tanggal_pesan'] ?? item['created_at'];
    } else {
      rawTime = item['tanggal_pesanan'] ?? item['tanggal_pesan'] ?? item['created_at'];
    }

    if (rawTime == null || rawTime.isEmpty) return '';

    try {
      final tgl = DateTime.parse(rawTime);
      return '${tgl.hour.toString().padLeft(2, '0')}:${tgl.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      // Coba ambil dari string langsung jika parse gagal
      if (rawTime.length > 16) return rawTime.substring(11, 16);
      return '';
    }
  }

  String _formatWaktu(Map<String, dynamic> item) {
    String status = (item['status_pesanan'] ?? '').toString().toUpperCase();
    String? rawTime;

    if (status == 'SELESAI' || status == 'DIBATALKAN') {
      rawTime = item['updated_at'] ?? item['tanggal_pesanan'] ?? item['tanggal_pesan'] ?? item['created_at'];
    } else {
      rawTime = item['tanggal_pesanan'] ?? item['tanggal_pesan'] ?? item['created_at'] ?? item['waktu'];
    }

    if (rawTime == null || rawTime.isEmpty) return 'Baru saja';

    try {
      DateTime orderTime = DateTime.parse(rawTime);
      Duration diff = DateTime.now().difference(orderTime);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (e) {
      return rawTime.length > 15 ? rawTime.substring(0, 15) : rawTime;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText('PuddingKu', color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5, isOleo: true),
                      SizedBox(height: 2),
                      CustomText('Panel Admin UMKM', color: AppColors.textBrown, fontSize: 12, fontWeight: FontWeight.w600),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfilAdmin())),
                    child: Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.textWhite,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profil admin.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                            _expandedIndexes.clear();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.primary, fontSize: 16),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _expandedIndexes.clear();
                            });
                          },
                          child: const Icon(Icons.close, color: AppColors.primary),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const CustomText('Riwayat Pesanan', color: AppColors.primaryDark, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _filteredList.isEmpty
                      ? Center(
                          child: CustomText(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada hasil untuk "$_searchQuery"'
                                : 'Belum ada riwayat pesanan',
                            color: AppColors.textHint, fontWeight: FontWeight.bold,
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _fetchDataPesanan,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(_filteredList[index], index);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProduk()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanPengguna()));
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> item, int index) {
    String idTampil = item['kode_resi']?.toString() ?? '-';

    String namaPemesan = item['nama_pemesan'] ?? 'Tanpa Nama';
    String ringkasanLengkap = item['ringkasan_pesanan'] ?? 'Detail Kosong';
    String harga = formatRupiah(item['total_harga']);
    String status = item['status_pesanan'] ?? 'PROSES';

    // Tanggal, bulan, tahun & jam
    String tanggal = _formatTanggal(item);
    String jam = _formatJam(item);

    List<String> daftarItem = ringkasanLengkap.split(', ').where((e) => e.isNotEmpty).toList();

    bool isExpanded = _expandedIndexes.contains(index);
    List<String> tampilItem = isExpanded ? daftarItem : daftarItem.take(2).toList();

    Color statusColor = status == 'SELESAI'
        ? AppColors.success
        : (status == 'DIBATALKAN' ? AppColors.error : AppColors.info);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ==========================================
                // BARIS 1: Kode resi + tanggal & jam
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Kiri: kode resi + tanggal & jam di bawahnya
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          idTampil,
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        if (tanggal.isNotEmpty || jam.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                if (tanggal.isNotEmpty)
                                  CustomText(
                                    tanggal,
                                    fontSize: 10,
                                    color: AppColors.textHint,
                                    fontWeight: FontWeight.w500,
                                  ),
                                if (tanggal.isNotEmpty && jam.isNotEmpty)
                                  const CustomText(
                                    '  •  ',
                                    fontSize: 10,
                                    color: AppColors.textHint,
                                  ),
                                if (jam.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 10,
                                        color: AppColors.textHint,
                                      ),
                                      const SizedBox(width: 2),
                                      CustomText(
                                        jam,
                                        fontSize: 10,
                                        color: AppColors.textHint,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ==========================================
                // BARIS 2: Nama pemesan + status
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(namaPemesan, fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.circle, color: statusColor, size: 10),
                        const SizedBox(width: 4),
                        CustomText(
                          status == 'SELESAI' ? 'Selesai' : 'Dibatalkan',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ==========================================
                // DAFTAR BARANG (EXPANDABLE)
                // ==========================================
                ...tampilItem.map((barang) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 5, color: AppColors.textBrown),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: CustomText(barang,
                        fontSize: 12, color: AppColors.textBrown, fontWeight: FontWeight.w600)),
                  ]),
                )),
                if (daftarItem.length > 2)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedIndexes.remove(index);
                        } else {
                          _expandedIndexes.add(index);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 4),
                      child: Row(children: [
                        CustomText(
                          isExpanded ? 'Sembunyikan' : '+${daftarItem.length - 2} barang lainnya',
                          fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(width: 2),
                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 14, color: AppColors.primary),
                      ]),
                    ),
                  ),
                const SizedBox(height: 6),
                _buildDashedLine(),
                const SizedBox(height: 10),

                // ==========================================
                // BARIS BAWAH: Total harga
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomText(harga, fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(100, (i) => Expanded(
        child: Container(
          height: 1,
          color: i % 2 == 0 ? AppColors.textHint.withOpacity(0.5) : Colors.transparent,
        ),
      )),
    );
  }
}