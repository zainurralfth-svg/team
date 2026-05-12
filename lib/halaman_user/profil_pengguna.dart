import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Core/Colour.dart'; // Palet 14 Warna Baru
import '../Backend/API_Service.dart'; 

class HalamanProfil extends StatefulWidget {
  const HalamanProfil({Key? key}) : super(key: key);

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil> {
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  String currentUserId = ""; 

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('id_user');

    if (savedId != null && savedId.isNotEmpty) {
      setState(() {
        currentUserId = savedId;
      });
      _ambilDataProfil(); 
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/masuk', (route) => false);
    }
  }

  Future<void> _ambilDataProfil() async {
    try {
      final response = await ApiService.getProfil(currentUserId);
      if (response['status'] == 'sukses') {
        setState(() {
          _userData = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _prosesLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushNamedAndRemoveUntil(context, '/masuk', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)), // Pakai merah error baru
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Pakai krem utama
      appBar: AppBar(
        backgroundColor: AppColors.primary, // Pakai oranye utama
        elevation: 0,
        centerTitle: true, 
        title: const Text('Profil Anda', style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2), // Latar lingkaran oranye transparan
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: const Icon(Icons.person, size: 80, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard, // Pakai warna krem terang untuk card
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Teks menggunakan textBrown biar senada
                        _buildInfoRow(Icons.badge, 'Nama Lengkap', _userData['nama'] ?? 'Belum disetting', AppColors.textBrown, AppColors.primary),
                        const Divider(height: 30, color: Colors.grey),
                        _buildInfoRow(Icons.alternate_email, 'Username', _userData['username'] ?? '-', AppColors.textBrown, AppColors.primary),
                        const Divider(height: 30, color: Colors.grey),
                        _buildInfoRow(Icons.phone_android, 'No. Handphone', _userData['phone'] ?? '-', AppColors.textBrown, AppColors.primary),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _prosesLogout,
                      icon: const Icon(Icons.logout, color: AppColors.textWhite),
                      label: const Text('LOGOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite, letterSpacing: 1.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error, // Warna tombol merah error
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
      // ==============================================================
      // FOOTER BAWAAN MENU (KEMBAR IDENTIK DENGAN BUNDERAN AKTIF)
      // ==============================================================
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.primary, // Warna navbar bawah
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/cek_pesanan');
              },
              child: _buildBottomNavItem(Icons.receipt_long, 'Pesanan', false, AppColors.primary),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/menu');
              },
              child: _buildBottomNavItem(Icons.cake, 'Produk', false, AppColors.primary),
            ),
            GestureDetector(
              onTap: () {
                // Udah di halaman Profil, gak usah ngapa-ngapain
              },
              // TRUE -> Bunderan putihnya nyala di tombol Profil
              child: _buildBottomNavItem(Icons.person, 'Profil', true, AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6))),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // HELPER BOTTOM ITEM (DENGAN LOGIKA BUNDERAN PUTIH AKTIF)
  // ==============================================================
  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected, Color activeColor) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent, // Bunderan putih kalau aktif
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              color: isSelected ? activeColor : Colors.white, // Ikon menyesuaikan warna
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label, 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 12,
              fontWeight: FontWeight.bold // Teks tegas
            )
          )
        ]
      ),
    );
  }
}