import 'package:flutter/material.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart';
import 'halaman_pengguna.dart';
import 'admin.dart';
import 'halaman_profil_admin.dart';
import 'halaman_produk.dart';
import 'halaman_laporan.dart';
import '../Widget/custom_admin_navbar.dart';
import 'cetak_laporan.dart' show getBulanDownloaded;

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

  // ✅ FIX: Pakai Set untuk tracking index yang di-expand, bukan item['_isExpanded']
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
            String tanggalA = a['tanggal_pesan'] ?? '';
            String tanggalB = b['tanggal_pesan'] ?? '';
            return tanggalB.compareTo(tanggalA);
          });
        _isLoading = false;
        _expandedIndexes.clear(); // Reset expand saat refresh
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
      // Hanya sembunyikan pesanan yang selesai SEBELUM waktu download
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 1. HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PuddingKu', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('Panel Admin UMKM', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textBrown, fontSize: 12, fontWeight: FontWeight.w600)),
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

            // 2. SEARCH BAR
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
                          hintStyle: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: AppColors.primary, fontSize: 16),
                      ),
                    ),
                    _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _expandedIndexes.clear();
                              });
                            },
                            child: const Icon(Icons.close, color: AppColors.primary),
                          )
                        : const Icon(Icons.search, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 3. LABEL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text('Riwayat Pesanan',
                  style: TextStyle(color: AppColors.primaryDark, fontSize: 20, fontWeight: FontWeight.bold)),
            ),

            // 4. DAFTAR
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _filteredList.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada hasil untuk "$_searchQuery"'
                                : 'Belum ada riwayat pesanan',
                            style: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold),
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

  // ==========================================
  // FUNGSI BUILD ORDER CARD
  // ==========================================
  Widget _buildOrderCard(Map<String, dynamic> item, int index) {
    String namaPemesan = item['nama_pemesan'] ?? 'Tanpa Nama';
    String ringkasanLengkap = item['ringkasan_pesanan'] ?? 'Detail Kosong';
    String harga = 'Rp ${item['total_harga'] ?? 0}';
    String status = item['status_pesanan'] ?? 'PROSES';

    List<String> daftarItem = ringkasanLengkap.split(', ').where((e) => e.isNotEmpty).toList();

    // ✅ FIX: Pakai _expandedIndexes, bukan item['_isExpanded']
    bool isExpanded = _expandedIndexes.contains(index);
    List<String> tampilItem = isExpanded ? daftarItem : daftarItem.take(2).toList();

    String waktuLengkap = item['tanggal_pesan'] ?? '';
    String tanggal = '';
    String jam = '';

    if (waktuLengkap.length >= 10) {
      List<String> bagian = waktuLengkap.substring(0, 10).split('-');
      if (bagian.length == 3) {
        List<String> namaBulan = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
        int bulanIndex = int.tryParse(bagian[1]) ?? 0;
        tanggal = '${bagian[2]} ${namaBulan[bulanIndex]} ${bagian[0]}';
      }
    }
    if (waktuLengkap.length > 11) jam = waktuLengkap.substring(11, 16);

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

                // Tanggal
                Text(tanggal, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                const SizedBox(height: 4),

                // Nama & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(namaPemesan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.circle, color: statusColor, size: 10),
                        const SizedBox(width: 4),
                        Text(status == 'SELESAI' ? 'Selesai' : 'Dibatalkan',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Daftar barang
                ...tampilItem.map((barang) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.circle, size: 5, color: AppColors.textBrown)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(barang,
                        style: const TextStyle(fontSize: 12, color: AppColors.textBrown, fontWeight: FontWeight.w600))),
                  ]),
                )),

                // Tombol expand
                if (daftarItem.length > 2)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // ✅ FIX: Toggle index di Set, bukan ubah Map item
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
                        Text(
                          isExpanded ? 'Sembunyikan' : '+${daftarItem.length - 2} barang lainnya',
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 2),
                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 14, color: AppColors.primary),
                      ]),
                    ),
                  ),

                const SizedBox(height: 6),

                // Garis putus-putus
                _buildDashedLine(),
                const SizedBox(height: 10),

                // Jam & Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(jam, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                    ]),
                    Text(harga, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Method class, bukan di dalam Column
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