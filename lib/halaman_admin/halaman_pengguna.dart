import 'package:flutter/material.dart';
import '../Backend/API_Service.dart';
import '../Core/Colour.dart'; 
import 'admin.dart';
import 'halaman_laporan.dart';
import 'riwayat_pesanan.dart';
import 'halaman_produk.dart';
import 'halaman_profil_admin.dart';
import '../Widget/custom_admin_navbar.dart';

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
      print("Gagal fetch data pengguna: $e");
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
        title: const Text(
          'Hapus Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda Yakin ingin Menghapus Akun "$namaUser"?\n\nBatalkan Jika Tidak Ingin Menghapus Akun.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Menghapus $namaUser...'))
              );
              final response = await ApiService.hapusPengguna(idUser);
              if (response['status'] == 'sukses') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil dihapus! ✅'),
                    backgroundColor: AppColors.success, // <-- Hijau success
                  ),
                );
                setState(() => _isLoading = true);
                _fetchDataPengguna();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gagal menghapus: ${response['pesan'] ?? 'Error'}',
                    ),
                    backgroundColor: AppColors.error, // <-- Merah error
                  ),
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold), // <-- Merah error
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // <-- Latar belakang utama krem
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER: PuddingKu & Profile ===
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PuddingKu', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('Panel Admin UMKM', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textBrown, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  // FOTO PROFIL (Sudah diseragamkan 50x50)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HalamanProfilAdmin(),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textWhite,
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

            // === TITLE: Daftar Pengguna ===
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text(
                'Daftar Pengguna',
                style: TextStyle(
                  color: AppColors.textBrown, // <-- Teks coklat tua
                  fontSize: 34,
                  fontFamily: 'Signika Negative',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // === SEARCH BAR ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textWhite, // <-- Pakai putih biar bersih
                  borderRadius: BorderRadius.circular(35),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSearch,
                  style: const TextStyle(
                    fontFamily: 'Signika Negative',
                    color: AppColors.textDark,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search..',
                    hintStyle: const TextStyle(
                      color: AppColors.textHint, // <-- Teks abu-abu
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Signika Negative',
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary, // <-- Ikon oranye utama
                      size: 35,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // === USER LIST ===
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary), // <-- Loading oranye
                    )
                  : _filteredData.isEmpty
                  ? const Center(
                      child: Text(
                        "Tidak ada pengguna ditemukan.",
                        style: TextStyle(
                          color: AppColors.textHint, // <-- Teks abu-abu
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) {
                        final user = _filteredData[index];
                        return _buildUserCard(user);
                      },
                    ),
            ),
          ],
        ),
      ),

      // === BOTTOM NAVIGATION BAR ===
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HalamanLaporan()),
            );
          }
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HalamanProduk()),
            );
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdmin()),
            );
          }
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HalamanRiwayat()), // Pastikan nama kelas Halaman Riwayat benar
            );
          }
          if (index == 4) {
            // Already here
          }
        },
      ),
    );
  }

  Widget _buildUserCard(dynamic item) {
    String idUser = item['id']?.toString() ?? '';
    String namaLengkap = item['nama'] ?? 'Tanpa Nama';
    String hurufDepan = namaLengkap.isNotEmpty
        ? namaLengkap[0].toUpperCase()
        : '?';
    String telepon = item['phone'] ?? 'Tidak ada no HP';
    String username = item['username'] ?? 'Tidak ada username';
    // String roleDB = item['role'] ?? 'user';

    String status = "User";
    Color warnaStatus = AppColors.success; // <-- Hijau sukses

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textWhite, // <-- Latar kartu putih
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow, // <-- Pakai shadow dari AppColors
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Stylized Initial
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.bgUtama, // <-- Background krem
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), // <-- Border oranye
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    hurufDepan,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary, // <-- Teks inisial oranye
                      fontFamily: 'Signika Negative',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Name
                    Text(
                      namaLengkap,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark, // <-- Teks hitam pekat
                        fontFamily: 'Sora',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Phone Number
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_callback_rounded,
                          color: AppColors.success, // <-- Ikon hijau
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgInput, // <-- Background kotak abu-abu
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            telepon,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHint, // <-- Teks abu-abu
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Email / Username
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.error, // <-- Ikon merah
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgInput, // <-- Background kotak abu-abu
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            username,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHint, // <-- Teks abu-abu
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Status Badge (Top Right-ish)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgUtama, // <-- Krem
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: warnaStatus, size: 8),
                  const SizedBox(width: 5),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark, // <-- Teks hitam pekat
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Delete Icon (Bottom Right)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (idUser.isNotEmpty) {
                  _konfirmasiHapus(idUser, namaLengkap);
                }
              },
              child: Image.asset(
                'assets/icons/trash.png',
                width: 35,
                height: 35,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error, // <-- Pakai merah AppColors
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}