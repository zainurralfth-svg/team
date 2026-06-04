import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Core/Colour.dart'; 
import '../Backend/API_Service.dart'; 
import '../Widget/custom_text.dart'; 

class HalamanProfilAdmin extends StatefulWidget {
  const HalamanProfilAdmin({super.key});

  @override
  State<HalamanProfilAdmin> createState() => _HalamanProfilAdminState();
}

class _HalamanProfilAdminState extends State<HalamanProfilAdmin> {
  // -------------------------------------------------------------
  // VARIABEL STATUS & PENYIMPAN DATA PROFIL ADMIN
  // -------------------------------------------------------------
  bool _isLoading = true;              // Status loading awal biar muncul indikator loading dulu
  Map<String, dynamic> _adminData = {}; // Wadah penampung data profil admin dari database yang di ambil
  String currentAdminId = "";           // Menyimpan ID Admin yang lagi login setelah nya

  @override
  void initState() {
    super.initState();
    // Begitu halaman admin dibuka, langsung cek apakah dia beneran udah login
    _loadAdminId();
  }

  // 1. FUNGSI CEK ID ADMIN DI MEMORI HP
  Future<void> _loadAdminId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Ambil data dari 'id_user' yang tersimpan pas login 
    String? savedId = prefs.getString('id_user');

    if (savedId != null && savedId.isNotEmpty) {
      setState(() {
        currentAdminId = savedId; // Simpan ID Admin yang lagi login ke variabel currentAdminId
      });
      _ambilDataProfil(); // Lanjut ambil data lengkapnya ke server PHP
    } else {
      // Kalo ga ada data login, pindah kan langsung balik ke halaman login
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // 2. FUNGSI TEMBAK API PHP UNTUK AMBIL DATA PROFIL ADMIN
  Future<void> _ambilDataProfil() async {
    try {
      // Manggil fungsi getProfil di ApiService khusus pakai ID Admin saat ini
      final response = await ApiService.getProfil(currentAdminId);
      if (response['status'] == 'sukses') {
        setState(() {
          _adminData = response['data']; // Masukin data profil admin yang diambil dari server ke variabel _adminData
          _isLoading = false;           // Matikan status loading karena data sudah siap ditampilkan
        });
      } else {
        setState(() => _isLoading = false); // Gagal ambil data, matikan loading
      }
    } catch (e) {
      setState(() => _isLoading = false); // Handle error jaringan, matikan loading
    }
  }

  // 3. FUNGSI POP-UP DIALOG UNTUK LOGOUT
  void _prosesLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText('Konfirmasi Logout', fontWeight: FontWeight.bold),
        content: const CustomText('Apakah Bos Admin yakin ingin keluar?'),
        actions: [
          // Tombol Batal
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup pop-up dialog
            child: const CustomText('Batal', color: Colors.grey),
          ),
          // Tombol Setuju Keluar
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog dulu
              
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // HAPUS ingatan sesi login di HP biar bersih
              
              // Balikin ke halaman login dan kunci biar ga bisa di-klik back
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const CustomText('Logout', color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 4. FUNGSI WIDGET HALAMAN PROFIL ADMIN UNTUK CETAKAN BARIS DATA PROFIL (Nama, Username, No HP)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Background warna krem estetik
      appBar: AppBar(
        backgroundColor: AppColors.primary, // Warna oranye tua khas admin
        elevation: 0,
        centerTitle: true, 
        title: const CustomText('Profil Admin', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      
      // KONDISI LOADING: Muter-muter dulu atau langsung nampilin data profil
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // AREA AVATAR LOGO ADMIN
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 4), 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    // Memakai icon admin panel biar beda dari profil user biasa
                    child: const Icon(Icons.admin_panel_settings, size: 70, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  
                  // LABEL BADGE "SUPER ADMIN"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Text('SUPER ADMIN', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 30),
                  
                  // KOTAK UTAMA TEMPAT DATA ADMIN (Nama, Username, No HP)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris data Nama Admin (Pakai ?? '-' buat jaga-jaga kalau datanya null)
                        _buildInfoRow(Icons.badge, 'Nama Admin', _adminData['nama'] ?? '-', AppColors.textDark, AppColors.primary),
                        const Divider(height: 30, color: Colors.grey),
                        
                        // Baris data Username Admin
                        _buildInfoRow(Icons.alternate_email, 'Username', _adminData['username'] ?? '-', AppColors.textDark, AppColors.primary),
                        const Divider(height: 30, color: Colors.grey),
                        
                        // Baris data Nomor Handphone Admin
                        _buildInfoRow(Icons.phone_android, 'No. Handphone', _adminData['phone'] ?? '-', AppColors.textDark, AppColors.primary),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // TOMBOL MERAH GEDE UNTUK LOGOUT ADMIN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _prosesLogout, // Panggil dialog konfirmasi logout saat di-klik
                      icon: const Icon(Icons.power_settings_new, color: AppColors.textWhite),
                      label: const CustomText('LOGOUT ADMIN', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite, letterSpacing: 1.5),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error, // Merah tegas penanda action keluar
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // FUNGSI WIDGET UNTUK MEMBANGUN BARIS INFORMASI PROFIL (Icon, Label, Nilai)
  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor, Color iconColor) {
    return Row(
      children: [
        // Wadah kotak untuk Icon kiri
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgUtama,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(width: 16),
        // Susunan teks Label (atas) dan Isinya (bawah)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(label, fontSize: 13, color: textColor.withOpacity(0.6), fontWeight: FontWeight.w500), // Judul field
              const SizedBox(height: 4),
              CustomText(value, fontSize: 18, fontWeight: FontWeight.bold, color: textColor), // Isi field (tebal)
            ],
          ),
        ),
      ],
    );
  }
}