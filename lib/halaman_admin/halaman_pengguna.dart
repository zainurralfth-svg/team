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
import '../Widget/custom_text.dart'; 
import '../Widget/notification_helper.dart';

// Halaman khusus admin untuk melihat, mencari, dan mengelola (menghapus) daftar akun pelanggan.
class HalamanPengguna extends StatefulWidget {
  const HalamanPengguna({super.key});

  @override
  State<HalamanPengguna> createState() => _HalamanPenggunaState();
}

class _HalamanPenggunaState extends State<HalamanPengguna> {
  // Tempat penampungan data sementara di dalam aplikasi.
  List<dynamic> _dataPengguna = []; // Menyimpan semua data pelanggan asli dari server.
  List<dynamic> _filteredData = []; // Menyimpan data pelanggan yang sudah disaring melalui kotak pencarian.
  
  bool _isLoading = true; // Status untuk menampilkan animasi loading sebelum data selesai dimuat.
  final TextEditingController _searchController = TextEditingController(); // Pengontrol teks untuk kotak pencarian (search bar).

  // Fungsi yang otomatis berjalan pertama kali saat admin membuka halaman ini.
  @override
  void initState() {
    super.initState();
    _fetchDataPengguna(); // Langsung memanggil fungsi untuk mengambil data pelanggan dari server.
  }

  // Fungsi untuk mengambil data daftar akun dari server (database).
  Future<void> _fetchDataPengguna() async {
    try {
      // Mengambil semua data pengguna melalui file ApiService.
      final data = await ApiService.getPengguna();
      
      // Menyaring data agar yang tampil di daftar hanya akun dengan peran 'user' (pelanggan), bukan akun sesama admin.
      final hanyaUser = data.where((item) {
        String roleDB = item['role']?.toString().toLowerCase() ?? 'user';
        return roleDB == 'user';
      }).toList();

      setState(() {
        // Memasukkan data yang sudah disaring ke dalam daftar utama dan daftar pencarian.
        _dataPengguna = hanyaUser;
        _filteredData = hanyaUser;
        _isLoading = false; // Matikan putaran loading karena data sudah siap ditampilkan.
      });
    } catch (e) {
      // Jika terjadi error (misal koneksi terputus), matikan loading agar aplikasi tidak terkunci.
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk memilah daftar pelanggan berdasarkan apa yang diketik admin di kotak pencarian.
  void _filterSearch(String query) {
    setState(() {
      // Mencari data yang cocok dengan ketikan admin (bisa dicari lewat nama, nomor HP, atau username).
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

  // Fungsi untuk memunculkan kotak peringatan pop-up sebelum admin menghapus akun pelanggan secara permanen.
  void _konfirmasiHapus(String idUser, String namaUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText('Hapus Pengguna', fontWeight: FontWeight.bold),
        content: CustomText('Yakin hapus "$namaUser"?'),
        actions: [
          // Tombol Batal: Menutup kotak peringatan tanpa melakukan apa-apa.
          TextButton(onPressed: () => Navigator.pop(context), child: const CustomText('Batal', color: Colors.grey)),
          
          // Tombol Hapus: Mengirim perintah ke server untuk menghapus akun.
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup kotak peringatan pop-up terlebih dahulu.
              
              // Eksekusi hapus data ke server.
              final response = await ApiService.hapusPengguna(idUser);
              
              if (response['status'] == 'sukses') {
                NotificationHelper.show(
                  context,
                  message: 'Berhasil menghapus pengguna.',
                  type: NotificationType.success,
                );
                
                // Segarkan ulang halaman (refresh) agar akun yang baru dihapus langsung hilang dari layar.
                setState(() => _isLoading = true);
                _fetchDataPengguna();
              } else {
                // Tampilkan pesan error jika server gagal menghapus data.
                NotificationHelper.show(
                  context,
                  message: 'Gagal menghapus pengguna.',
                  type: NotificationType.error,
                );
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
            // ============================================================
            // BAGIAN HEADER: JUDUL PANEL DAN FOTO PROFIL ADMIN
            // ============================================================
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
                  // Foto profil admin yang bisa ditekan untuk masuk ke halaman profil.
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

            // ============================================================
            // KOTAK PENCARIAN (SEARCH BAR)
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                decoration: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSearch, // Otomatis menjalankan fungsi pencarian setiap kali admin mengetik huruf baru.
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // ============================================================
            // DAFTAR KARTU PELANGGAN (BISA DI-SCROLL)
            // ============================================================
            Expanded(
              // Aturan main: 
              // 1. Jika masih loading, tampilkan indikator putaran muter.
              // 2. Jika data kosong (tidak ada pelanggan), tampilkan teks pemberitahuan.
              // 3. Jika data ada, cetak daftar pelanggan berbaris ke bawah menggunakan ListView.
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _filteredData.isEmpty
                  ? const Center(child: CustomText("Tidak ada pengguna.", color: AppColors.textHint))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      itemCount: _filteredData.length, // Sesuaikan jumlah baris dengan total data pengguna.
                      itemBuilder: (context, index) => _buildUserCard(_filteredData[index]), // Panggil cetakan kartu pelanggan.
                    ),
            ),
          ],
        ),
      ),
      // Navigasi Menu Bawah khusus panel admin.
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 4, // Menandakan bahwa admin sedang berada di menu ke-5 (Indeks 4).
        onTap: (index) {
          // Logika perpindahan halaman berdasarkan urutan tombol menu yang diklik.
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProduk()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()));
        },
      ),
    );
  }

  // =========================================================================
  // CETAKAN WIDGET BANTUAN
  // =========================================================================

  // Cetakan untuk membuat desain satu kotak informasi pelanggan (Nama, Nomor HP, Tombol Hapus).
  Widget _buildUserCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Jarak spasi antar kotak pelanggan.
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 5, offset: const Offset(0, 2))], // Efek bayangan kotak.
      ),
      child: Row(
        children: [
          // Lingkaran ikon profil. Huruf pertama nama pelanggan akan diambil otomatis untuk dijadikan ikon.
          Container(
            width: 45, height: 45, 
            decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(10)),
            child: Center(child: CustomText(item['nama']?[0].toUpperCase() ?? '?', color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          // Informasi teks Nama dan Nomor Handphone.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(item['nama'] ?? '-', fontSize: 15, fontWeight: FontWeight.bold),
                CustomText(item['phone'] ?? '-', fontSize: 12, color: AppColors.textHint),
              ],
            ),
          ),
          // Tombol logo tong sampah untuk menghapus akun. Jika diklik, akan memicu fungsi '_konfirmasiHapus' di atas.
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
            onPressed: () => _konfirmasiHapus(item['id'].toString(), item['nama']),
          ),
        ],
      ),
    );
  }
}