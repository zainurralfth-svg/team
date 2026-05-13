import 'package:flutter/material.dart';
import '../Backend/API_Service.dart';
import 'admin.dart';
import 'halaman_pesanan.dart';
import 'halaman_laporan.dart';
import 'halaman_riwayat.dart';
import 'halaman_produk.dart' ;
import 'halaman_profil_admin.dart' ;
import '../Widget/custom_navbar.dart';


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
    const Color bgCream = Color(0xFFFFE5B9);
    const Color primaryOrange = Color(0xFFD27F30);
    const Color textBrown = Color(0xFFC17F3E);
    const Color lightBrown = Color(0xFFA89070);

    return Scaffold(
      backgroundColor: bgCream,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'PuddingKu',
                        style: TextStyle(
                          color: textBrown,
                          fontSize: 28,
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Panel Admin UMKM',
                        style: TextStyle(
                          color: lightBrown,
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
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
                      width: 55,
                      height: 55,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text(
                'Daftar Pengguna',
                style: TextStyle(
                  color: textBrown,
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
                  color: const Color(0xFFFFD1A1).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSearch,
                  decoration: InputDecoration(
                    hintText: 'Search..',
                    hintStyle: TextStyle(
                      color: textBrown.withOpacity(0.6),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Signika Negative',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: textBrown.withOpacity(0.6),
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
                      child: CircularProgressIndicator(color: primaryOrange),
                    )
                  : _filteredData.isEmpty
                  ? const Center(
                      child: Text(
                        "Tidak ada pengguna ditemukan.",
                        style: TextStyle(
                          color: textBrown,
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
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanPesanan()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProduk()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()));
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
    String hurufDepan = namaLengkap.isNotEmpty ? namaLengkap[0].toUpperCase() : '?';
    String telepon = item['phone'] ?? 'Tidak ada no HP';
    String username = item['username'] ?? 'Tidak ada username';
    String roleDB = item['role'] ?? 'user';
    
    // Status logic: if role is 'user' maybe show 'AKTIF' or check other field if available
    String status = "AKTIF"; 
    Color warnaStatus = const Color(0xFF4CAF50); // Green dot

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: const Color(0xFFFFE5B9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFD27F30).withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Text(
                    hurufDepan,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD27F30),
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
                        color: Colors.black,
                        fontFamily: 'Sora',
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Phone Number
                    Row(
                      children: [
                        const Icon(Icons.phone_callback_rounded, color: Color(0xFF4CAF50), size: 18),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            telepon,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Email / Username
                    Row(
                      children: [
                        const Icon(Icons.mail_outline_rounded, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            username,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
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
                color: const Color(0xFFFFE5B9),
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
                      color: Colors.black,
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
                'assets/icons/trash.png', // Assuming user has this or similar icon
                width: 35,
                height: 35,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.grey,
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
