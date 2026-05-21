import 'package:flutter/material.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart';
import 'halaman_pengguna.dart';
import 'admin.dart';
import 'halaman_profil_admin.dart';
import 'halaman_produk.dart';
import 'halaman_laporan.dart';
import '../Widget/custom_admin_navbar.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchDataPesanan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDataPesanan() async {
    try {
      final data = await ApiService.getPesanan();
      setState(() {
        _listPesanan = data.where((item) {
          String status = (item['status_pesanan'] ?? '').toString().toUpperCase();
          return status == 'SELESAI' || status == 'DIBATALKAN';
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching pesanan: $e");
    }
  }

  List<dynamic> get _filteredList {
    if (_searchQuery.isEmpty) return _listPesanan;
    return _listPesanan.where((item) {
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
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText('PuddingKu', color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      SizedBox(height: 2),
                      CustomText('Panel Admin UMKM', color: AppColors.textBrown, fontSize: 12, fontWeight: FontWeight.w600),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfilAdmin())),
                    child: Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(color: AppColors.textWhite, shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/profil admin.png'), fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),

            // SEARCH BAR (Ikon di Kiri)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.primary), // Ikon dipindah ke Kiri
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                        decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none),
                        style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.primary, fontSize: 16),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() { _searchController.clear(); _searchQuery = ''; });
                        },
                        child: const Icon(Icons.close, color: AppColors.primary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // LABEL RIWAYAT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const CustomText('Riwayat Pesanan', color: AppColors.primaryDark, fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // LIST
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _filteredList.isEmpty
                      ? Center(child: CustomText(_searchQuery.isNotEmpty ? 'Tidak ada hasil' : 'Belum ada riwayat', color: AppColors.textHint, fontWeight: FontWeight.bold))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) => _buildOrderCard(_filteredList[index]),
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

  Widget _buildOrderCard(Map<String, dynamic> item) {
    String status = (item['status_pesanan'] ?? 'PROSES').toString().toUpperCase();
    Color statusColor = status == 'SELESAI' ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 5, offset: const Offset(0, 3))]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(item['nama_pemesan'] ?? 'Tanpa Nama', fontSize: 16, fontWeight: FontWeight.bold),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [Icon(Icons.circle, color: statusColor, size: 10), const SizedBox(width: 4), CustomText(status == 'SELESAI' ? 'Selesai' : 'Dibatalkan', fontSize: 10, fontWeight: FontWeight.bold)]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomText(item['ringkasan_pesanan'] ?? '-', fontSize: 12, color: AppColors.textBrown, fontWeight: FontWeight.w600),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText('Rp ${item['total_harga'] ?? 0}', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    CustomText(item['tanggal_pesan']?.toString().substring(11, 16) ?? '', fontSize: 11, color: AppColors.textHint),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}