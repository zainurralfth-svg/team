import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Core/Colour.dart'; 
import '../Backend/API_Service.dart'; 
import '../Widget/custom_user_navbar.dart';
import '../Widget/custom_text.dart';

class HalamanProfil extends StatefulWidget {
  const HalamanProfil({super.key});

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil> {
  // -------------------------------------------------------------
  // STATE VARIABLES (Variabel buat nyimpen status halaman)
  // -------------------------------------------------------------
  bool _isLoading = true;             // Buat status loading (muter-muter) pas awal buka halaman
  Map<String, dynamic> _userData = {}; // Wadah buat nampung data profil dari database PHP
  String currentUserId = "";          // Buat nyimpen ID User yang lagi login

  @override
  void initState() {
    super.initState();
    // Begitu halaman profil dibuka, langsung cek ID User di memori HP
    _loadUserId();
  }

  // 1. FUNGSI AMBIL ID USER DARI MEMORI HP (SHAREDPREFERENCES)
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('id_user');

    // Kalo ID-nya ketemu (artinya user udah login)
    if (savedId != null && savedId.isNotEmpty) {
      setState(() {
        currentUserId = savedId; // Simpan ID-nya ke variabel global halaman ini
      });
      _ambilDataProfil(); // Langsung ambil API buat ambil data lengkapnya
    } else {
      // Kalo null (belum login),paksa user balik ke Halaman Login kembali
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // 2. FUNGSI AMBIL API PHP BUAT AMBIL DATA PROFIL
  Future<void> _ambilDataProfil() async {
    try {
      // Manggil fungsi getProfil di ApiService sambil ngirim ID User-nya
      final response = await ApiService.getProfil(currentUserId);
      
      if (response['status'] == 'sukses') {
        if (mounted) {
          setState(() {
            _userData = response['data']; // Masukin data (nama, username, hp) ke variabel _userData
            _isLoading = false;          // Matikan loading muter-muternya biar datanya tampil
          });
        }
      } else {
        // Kalo API responnya gagal, tetep matikan loading biar ga muter terus
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      // Kalo ada error jaringan atau kodingan, amankan biar ga crash dan matikan loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. FUNGSI LOGOUT (HAPUS SESI LOGIN)
  void _prosesLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText('Konfirmasi Keluar Akun', fontWeight: FontWeight.bold),
        content: const CustomText('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          // Tombol Batal 
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup pop-up dialog aja
            child: const CustomText('Batal', color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          // Tombol Konfirmasi Logout
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup pop-up dialog dulu sebelum proses logout
              
              // Buka SharedPreferences (Buku catatan HP)
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // MEMBERSIHKAN / HAPUS semua isi catatan (termasuk id_user)
              
              // pindahkan user ke halaman login dan hapus semua riwayat page sebelumnya biar ga bisa di-back lagi
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const CustomText('Keluar', color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  //  BUILD WIDGET UTAMA HALAMAN PROFIL USER
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Warna krem dasar aplikasi Puddingku
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ngilangin tombol back otomatis dari Flutter
        backgroundColor: AppColors.primary, // Warna oranye estetik Puddingku
        elevation: 0,
        centerTitle: true, 
        title: const CustomText('Profil Kamu', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      
      // LOGIKA TAMPILAN: Kalo lagi loading tampilkan lingkaran muter, kalo udah beres menampilkan layout utama halaman profil
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Latar lingkaran foto profil (Icon Person Oranye)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2), 
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: const Icon(Icons.person, size: 80, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  
                  // CARD UTAMA TEMPAT MENAMPILKAN DATA DARI DATABASE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard, // Warna krem terang khusus card
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris data Nama (Menggunakan operator ?? untuk handle jika data null)
                        _buildInfoRow(Icons.badge, 'Nama Lengkap', _userData['nama'] ?? 'Belum disetting', AppColors.textBrown, AppColors.primary),
                        const Divider(height: 30, color: Colors.grey),
                        
                        // Baris data Username
                        _buildInfoRow(Icons.alternate_email, 'Nama Pengguna', _userData['username'] ?? '-', AppColors.textBrown, AppColors.primary),
                        const Divider(height: 30, color: Colors.grey),
                        
                        // Baris data Nomor Handphone
                        _buildInfoRow(Icons.phone_android, 'Nomor Telepon', _userData['phone'] ?? '-', AppColors.textBrown, AppColors.primary),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // TOMBOL MERAH UNTUK LOGOUT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _prosesLogout, // Panggil fungsi dialog logout di atas tadi
                      icon: const Icon(Icons.logout, color: AppColors.textWhite),
                      label: const CustomText('KELUAR', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error, // Warna merah tegas khusus error/action bahaya
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
      // ==============================================================
      // CUSTOM USER NAVBAR DI BAGIAN BAWAH LAYAR 
      // ==============================================================
      bottomNavigationBar: CustomUserNavbar(
        currentIndex: 2, 
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/cek_pesanan'); // Pindah ke halaman riwayat order
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/menu'); // Pindah ke halaman katalog Pudding
          } else if (index == 2) {
            // Biarin kosong, karena user posisinya emang lagi di halaman profil
          }
        },
      ),
    );
  }

  // 4. KODINGAN REUSABLE (KOMPONEN BARIS INFO): Biar ga capek nulis Row berkali-kali
  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor, Color iconColor) {
    return Row(
      children: [
        // Kotak kecil pembungkus Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        // Tulisan Label (Atas) dan Isinya (Bawah)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(label, fontSize: 12, color: textColor.withOpacity(0.6)), // Label buram sedikit
              const SizedBox(height: 4),
              CustomText(value, fontSize: 16, fontWeight: FontWeight.bold, color: textColor), // Nilai tebal senada
            ],
          ),
        ),
      ],
    );
  }
}