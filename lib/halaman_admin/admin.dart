import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // <-- Palet warna 14 warna
import '../Backend/Api_service.dart'; 
import 'halaman_produk.dart';
import 'halaman_riwayat.dart';
import 'halaman_laporan.dart';
import 'halaman_pengguna.dart';
import 'halaman_pesanan.dart';
import 'halaman_profil_admin.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  List<dynamic> _listPesanan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataPesanan();
  }

  // ============================================================
  // FUNGSI MENYEDOT DATA PESANAN DARI DATABASE
  // ============================================================
  Future<void> _fetchDataPesanan() async {
    try {
      final data = await ApiService.getPesanan();
      setState(() {
        // Hanya tampilkan yang statusnya BELUM selesai/dibatalkan
       _listPesanan = data.where((item) {
          String status = item['status_pesanan'] ?? '';
          return status != 'SELESAI' && status != 'DIBATALKAN';
        }).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching pesanan: $e");
    }
  }

  // ============================================================
  // FUNGSI UPDATE STATUS PESANAN
  // ============================================================
  Future<void> _ubahStatusPesanan(String idPesanan, String statusBaru) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.updateStatusPesanan(
        idPesanan,
        statusBaru,
      );

      if (response['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status berhasil diubah menjadi $statusBaru'),
            backgroundColor: AppColors.success, // Pakai warna sukses baru
          ),
        );
        await _fetchDataPesanan(); // Refresh data setelah status berubah
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${response['pesan']}'),
            backgroundColor: AppColors.error, // Pakai warna error baru
          )
        );
      }
    } catch (e) {
      print("Error update status: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Warna krem utama
      body: Stack(
        children: [
          // Background Header (Lengkungan Oranye)
          Container(
            height: 330,
            decoration: const BoxDecoration(color: AppColors.primary),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                _buildStatCards(context),
                const SizedBox(height: 25),
                _buildIncomeCard(),
                const SizedBox(height: 15),
                _buildSectionTitle(),
                const SizedBox(height: 10),

                // =====================================
                // BAGIAN LIST PESANAN YANG SUDAH DINAMIS
                // =====================================
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary, // Loading indikator oranye
                          ),
                        )
                      : _listPesanan.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada pesanan masuk",
                            style: TextStyle(
                              color: Colors.black54, // Ubah jadi abu-abu agar terlihat di background krem
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _fetchDataPesanan,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            itemCount: _listPesanan.length,
                            itemBuilder: (context, index) {
                              return _buildOrderItem(_listPesanan[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // =====================================
  // WIDGET HEADER (Sapaan Admin & Profil)
  // =====================================
  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Dashboard Admin',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 26,
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
                    color: AppColors.textWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary, // Ikon profil warna utama
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================
  // WIDGET KARTU STATISTIK (3 Kotak Berjejer)
  // =====================================
  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard('12\nProduk', Icons.inventory_2_outlined, () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const HalamanProduk())
            );
          }),
          _statCard('Riwayat\nPesanan', Icons.shopping_bag, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanRiwayat()),
            );
          }),
          _statCard('Laporan', Icons.assignment, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanLaporan()),
            );
          }),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        height: 105,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.24), // Efek transparan pada background oranye
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textWhite, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // WIDGET KARTU PENDAPATAN
  // =====================================
  Widget _buildIncomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pendapatan',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Rp -', 
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // WIDGET JUDUL DAFTAR PESANAN
  // =====================================
  Widget _buildSectionTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Daftar Pesanan',
        style: TextStyle(
          color: AppColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =====================================
  // KARTU PESANAN YANG SUDAH DINAMIS
  // =====================================
  Widget _buildOrderItem(Map<String, dynamic> item) {
    String idPesanan = item['id_pesanan']?.toString() ?? '';
    String namaPemesan = item['nama_pemesan'] ?? 'Tanpa Nama';
    String hurufAwal = namaPemesan.isNotEmpty ? namaPemesan[0].toUpperCase() : '?';
    String ringkasan = item['ringkasan_pesanan'] ?? 'Detail Kosong';
    String harga = 'Rp ${item['total_harga'] ?? 0}';
    String status = item['status_pesanan'] ?? 'MENUNGGU'; 

    String waktuLengkap = item['tanggal_pesan'] ?? '';
    String waktuSingkat = waktuLengkap.length > 16 ? waktuLengkap.substring(0, 16) : waktuLengkap;

    // Warna dinamis sesuai status (Mengikuti palet baru)
    Color statusColor;
    if (status == 'SELESAI') {
      statusColor = AppColors.success;
    } else if (status == 'DIBATALKAN') {
      statusColor = AppColors.error;
    } else if (status == 'PROSES') {
      statusColor = Colors.orange; // Bisa pakai primary, tapi orange untuk proses cocok
    } else {
      statusColor = AppColors.info; // MENUNGGU (Biru)
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kotak inisial pemesan
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgCard, // Pakai bgCard biar lembut
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                hurufAwal,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaPemesan,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  ringkasan,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  harga,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // =====================================
              // TOMBOL GANTI STATUS (POPUP MENU)
              // =====================================
              PopupMenuButton<String>(
                initialValue: status,
                onSelected: (String newValue) {
                  if (newValue != status && idPesanan.isNotEmpty) {
                    _ubahStatusPesanan(idPesanan, newValue);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'MENUNGGU', child: Text('MENUNGGU')),
                  const PopupMenuItem<String>(value: 'PROSES', child: Text('PROSES')),
                  const PopupMenuItem<String>(value: 'SELESAI', child: Text('SELESAI')),
                  const PopupMenuItem<String>(value: 'DIBATALKAN', child: Text('DIBATALKAN')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgUtama, // Background krem pada tombol status
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: statusColor, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 14, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Icon(Icons.alarm, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    waktuSingkat,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================
  // BOTTOM NAVIGATION BAR
  // =====================================
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 70,
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomNavItem(Icons.home, 'BERANDA', true, () {}),
          _bottomNavItem(Icons.person, 'PENGGUNA', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanPengguna()),
            );
          }),
          _bottomNavItem(Icons.add_circle_outline, 'PESANAN', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanPesanan()),
            );
          }),
        ],
      ),
    );
  }

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
                color: isSelected ? AppColors.textWhite : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textWhite,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textWhite,
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