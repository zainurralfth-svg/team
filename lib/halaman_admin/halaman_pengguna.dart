import 'package:flutter/material.dart';
import '../Backend/API_Service.dart';
import 'admin.dart';
import 'halaman_pesanan.dart';
import 'halaman_laporan.dart';
import 'halaman_riwayat.dart';
import 'halaman_produk.dart' ;
import 'halaman_profil_admin.dart' ;


class HalamanPengguna extends StatefulWidget {
  const HalamanPengguna({super.key});

  @override
  State<HalamanPengguna> createState() => _HalamanPenggunaState();
}

class _HalamanPenggunaState extends State<HalamanPengguna> {
  List<dynamic> _dataPengguna = [];
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Gagal fetch data pengguna: $e");
    }
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Menghapus $namaUser...')));
              final response = await ApiService.hapusPengguna(idUser);
              if (response['status'] == 'sukses') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil dihapus! ✅'),
                    backgroundColor: Colors.green,
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
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD27F30),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dashboard Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFD27F30),
                      size: 30,
                    ),
                  ),
                 ),
               ],
              ),
            ),
           Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOMBOL PRODUK INTERAKTIF
                  _buildStatCard('12\nProduk', Icons.inventory_2_outlined, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HalamanProduk(),
                      ),
                    );
                  }),
                  
                  // TOMBOL RIWAYAT PESANAN INTERAKTIF
                  _buildStatCard('Riwayat\nPesanan', Icons.shopping_bag_outlined, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HalamanRiwayat(),
                      ),
                    );
                  }),
                  
                  // TOMBOL LAPORAN
                  _buildStatCard('Laporan', Icons.bar_chart, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HalamanLaporan(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pendapatan',
                    style: TextStyle(
                      color: Color(0xFFD27F30),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '570.000',
                    style: TextStyle(
                      color: Color(0xFFD27F30),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFFFDF0D5)),
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD27F30),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Daftar Pengguna',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFD27F30),
                              ),
                            )
                          : _dataPengguna.isEmpty
                          ? const Center(
                              child: Text(
                                "Belum ada pengguna terdaftar.",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              itemCount: _dataPengguna.length,
                              itemBuilder: (context, index) {
                                final user = _dataPengguna[index];
                                return _buildUserCard(user);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ==========================================
      // FOOTER BAWAAN ADMIN (KEMBAR IDENTIK)
      // ==========================================
      bottomNavigationBar: Container(
        height: 70,
        color: const Color(0xFFD27F30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _bottomNavItem(Icons.home, 'BERANDA', false, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeAdmin()),
              );
            }),
            _bottomNavItem(Icons.person, 'PENGGUNA', true, () {
              // Udah di halaman pengguna
            }),
            _bottomNavItem(Icons.add_circle_outline, 'PESANAN', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HalamanPesanan()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        height: 105,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.24),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
    String roleDB = item['role'] ?? 'user';
    String status = roleDB.toUpperCase();
    Color warnaStatus = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0D5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Center(
              child: Text(
                hurufDepan,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD27F30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        namaLengkap,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0D5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: warnaStatus, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        telepon,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: Color(0xFFD27F30),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            username,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (idUser.isNotEmpty) {
                          _konfirmasiHapus(idUser, namaLengkap);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Gagal: ID Pengguna tidak ditemukan',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HELPER BOTTOM ITEM (100% KEMBAR KAYA ADMIN.DART)
  // ==============================================================
  Widget _bottomNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFD27F30) : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
