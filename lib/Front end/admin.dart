import 'package:flutter/material.dart';
import '../Core/Colour.dart'; 
import '../Backend/Api_service.dart'; // <-- JANGAN LUPA IMPORT API SERVICE-NYA
import 'tambah_produk.dart'; 
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

  // FUNGSI MENYEDOT DATA PESANAN DARI DATABASE
  Future<void> _fetchDataPesanan() async {
    try {
      final data = await ApiService.getPesanan();
      setState(() {
        _listPesanan = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching pesanan: $e");
    }
  }// FUNGSI UNTUK MENGUBAH STATUS PESANAN
  Future<void> _ubahStatusPesanan(String idPesanan, String statusBaru) async {
    setState(() => _isLoading = true);

    try {
      // Memanggil fungsi dari ApiService (Pastikan kamu sudah buat fungsinya di ApiService.dart)
      final response = await ApiService.updateStatusPesanan(idPesanan, statusBaru);
      
      if (response['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status berhasil diubah menjadi $statusBaru'), backgroundColor: Colors.green),
        );
        await _fetchDataPesanan(); // Refresh data setelah status berubah
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${response['pesan']}')),
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
      backgroundColor: AppColors.adminBg, 
      body: Stack(
        children: [
          Container(
            height: 330,
            decoration: const BoxDecoration(
              color: AppColors.adminPrimary,
            ),
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
                    ? const Center(child: CircularProgressIndicator(color: AppColors.textWhite)) 
                    : _listPesanan.isEmpty 
                      ? const Center(child: Text("Belum ada pesanan masuk", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)))
                      : RefreshIndicator(
                          color: AppColors.adminPrimary,
                          onRefresh: _fetchDataPesanan,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                    style: TextStyle(color: AppColors.textWhite, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Dashboard Admin',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfilAdmin()));
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.textWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.adminPrimary, size: 30),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard('12\nProduk', Icons.pie_chart, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HalamanProduk()));
          }),
          _statCard('Riwayat\nPesanan', Icons.shopping_bag, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()));
          }),
          _statCard('Laporan', Icons.assignment, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
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
          color: AppColors.adminStatCard, 
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
              style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

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
            style: TextStyle(color: AppColors.adminPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Rp -', // Nanti bisa didinamiskan kalau API pendapatannya udah ada
            style: TextStyle(color: AppColors.adminPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.adminPrimary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Daftar Pesanan',
        style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // =====================================
  // KARTU PESANAN YANG SUDAH DINAMIS
  // =====================================
  Widget _buildOrderItem(Map<String, dynamic> item) {
    // Ambil ID Pesanan (pastikan sesuai nama kolom di database kamu)
    String idPesanan = item['id_pesanan']?.toString() ?? '';
    
    String namaPemesan = item['nama_pemesan'] ?? 'Tanpa Nama';
    String hurufAwal = namaPemesan.isNotEmpty ? namaPemesan[0].toUpperCase() : '?';
    String ringkasan = item['ringkasan_pesanan'] ?? 'Detail Kosong';
    String harga = 'Rp ${item['total_harga'] ?? 0}';
    String status = item['status_pesanan'] ?? 'MENUNGGU'; // Default status
    
    String waktuLengkap = item['tanggal_pesan'] ?? '';
    String waktuSingkat = waktuLengkap.length > 16 ? waktuLengkap.substring(0, 16) : waktuLengkap;

    // Warna dinamis sesuai status
    Color statusColor;
    if (status == 'SELESAI') statusColor = Colors.green;
    else if (status == 'DIBATALKAN') statusColor = Colors.red;
    else if (status == 'PROSES') statusColor = Colors.orange;
    else statusColor = Colors.blue; // MENUNGGU

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.adminCardLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(hurufAwal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.adminPrimary)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaPemesan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(ringkasan, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(harga, style: const TextStyle(color: AppColors.adminPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
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
                  // Cek agar tidak update jika statusnya sama
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
                    color: AppColors.adminBg, 
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: statusColor, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 4),
                      Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                  Text(waktuSingkat, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 70,
      color: AppColors.adminPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomNavItem(Icons.home, 'BERANDA', true, () {}),
          _bottomNavItem(Icons.person, 'PENGGUNA', false, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanPengguna()));
          }),
          _bottomNavItem(Icons.add_box, 'PRODUK BARU', false, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahProdukPage())); 
          }),
          _bottomNavItem(Icons.add_circle_outline, 'PESANAN', false, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanPesanan()));
          }),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
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
              child: Icon(icon, color: isSelected ? AppColors.adminPrimary : AppColors.textWhite, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}