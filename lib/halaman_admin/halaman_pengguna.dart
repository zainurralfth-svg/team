import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Core/Colour.dart';
import '../Backend/API_Service.dart'; 
import 'halaman_laporan.dart';
import 'admin.dart';
import 'halaman_produk.dart';
import 'halaman_profil_admin.dart';
import 'riwayat_pesanan.dart';
import '../Widget/custom_admin_navbar.dart';
import '../Widget/custom_text.dart'; // <-- IMPORT CUSTOM TEXT

class HalamanPengguna extends StatefulWidget {
  const HalamanPengguna({super.key});

  @override
  State<HalamanPengguna> createState() => _HalamanPenggunaState();
}

class _HalamanPenggunaState extends State<HalamanPengguna> {
  List<dynamic> _dataPengguna = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDataPengguna();
  }

  Future<void> _fetchDataPengguna() async {
    try {
      final data = await ApiService.getPengguna();
      final hanyaUser = data.where((item) {
        String roleDB = item['role']?.toString().toLowerCase() ?? 'user';
        return roleDB == 'user';
      }).toList();

      setState(() {
        _dataPengguna = hanyaUser;
        _filteredData = hanyaUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredData = _dataPengguna.where((user) {
        final name = user['nama']?.toString().toLowerCase() ?? '';
        final phone = user['phone']?.toString().toLowerCase() ?? '';
        final username = user['username']?.toString().toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
            phone.contains(query.toLowerCase()) ||
            username.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _konfirmasiHapus(String idUser, String namaUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText('Hapus Pengguna', fontWeight: FontWeight.bold),
        content: CustomText('Yakin hapus "$namaUser"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const CustomText('Batal', color: Colors.grey)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await ApiService.hapusPengguna(idUser);
              if (response['status'] == 'sukses') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: CustomText('Berhasil!'), backgroundColor: AppColors.success));
                setState(() => _isLoading = true);
                _fetchDataPengguna();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: CustomText('Gagal: ${response['pesan']}'), backgroundColor: AppColors.error));
              }
            },
            child: const CustomText('Hapus', color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
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
                      width: 45, height: 45,
                      decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/profil admin.png'), fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              child: CustomText('Daftar Pengguna', fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                decoration: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _filteredData.isEmpty
                  ? const Center(child: CustomText("Tidak ada pengguna.", color: AppColors.textHint))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) => _buildUserCard(_filteredData[index]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProduk()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()));
        },
      ),
    );
  }

  // WIDGET KARTU USER YANG SUDAH DI-RESIZE LEBIH KECIL
  Widget _buildUserCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12), // Padding dikurangi
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(15), // Border lebih melengkung halus
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 45, height: 45, // Ukuran avatar dikurangi
            decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(10)),
            child: Center(child: CustomText(item['nama']?[0].toUpperCase() ?? '?', color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(item['nama'] ?? '-', fontSize: 15, fontWeight: FontWeight.bold),
                CustomText(item['phone'] ?? '-', fontSize: 12, color: AppColors.textHint),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
            onPressed: () => _konfirmasiHapus(item['id'].toString(), item['nama']),
          ),
        ],
      ),
    );
  }
}