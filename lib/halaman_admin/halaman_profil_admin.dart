import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Core/Colour.dart';
import '../Backend/API_Service.dart'; 
import '../Widget/custom_text.dart'; // <-- IMPORT COMPONENT CUSTOM TEXT KITA

class HalamanProfilAdmin extends StatefulWidget {
  const HalamanProfilAdmin({super.key});

  @override
  State<HalamanProfilAdmin> createState() => _HalamanProfilAdminState();
}

class _HalamanProfilAdminState extends State<HalamanProfilAdmin> {
  bool _isLoading = true;
  Map<String, dynamic> _adminData = {};
  String currentAdminId = ""; 

  @override
  void initState() {
    super.initState();
    _loadAdminId();
  }

  // MENGAMBIL ID ADMIN YANG SEDANG LOGIN DARI SESI
  Future<void> _loadAdminId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('id_user');

    if (savedId != null && savedId.isNotEmpty) {
      setState(() {
        currentAdminId = savedId;
      });
      _ambilDataProfil(); 
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // MENGAMBIL DATA PROFIL DARI DATABASE
  Future<void> _ambilDataProfil() async {
    try {
      final response = await ApiService.getProfil(currentAdminId);
      if (response['status'] == 'sukses') {
        setState(() {
          _adminData = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // POP-UP KONFIRMASI LOGOUT
  void _prosesLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText('Konfirmasi Logout', fontWeight: FontWeight.bold),
        content: const CustomText('Apakah Bos Admin yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText('Batal', color: Colors.grey),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Hapus ingatan sesi login
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const CustomText('Logout', color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Background krem utama
      appBar: AppBar(
        backgroundColor: AppColors.primary, // AppBar oranye kecoklatan
        elevation: 0,
        centerTitle: true, 
        title: const CustomText('Profil Admin', color: AppColors.textWhite, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // AVATAR ADMIN
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 4), 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.admin_panel_settings, size: 70, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  
                  // LABEL ROLE ADMIN
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Text('SUPER ADMIN', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 30),
                  
                  // KOTAK DATA ADMIN
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
                        _buildInfoRow(Icons.badge, 'Nama Admin', _adminData['nama'] ?? '-', AppColors.textDark, AppColors.primary),
                        const Divider(height: 30, color: Colors.grey),
                        _buildInfoRow(Icons.alternate_email, 'Username', _adminData['username'] ?? '-', AppColors.textDark, AppColors.primary),
                        const Divider(height: 30, color: Colors.grey),
                        _buildInfoRow(Icons.phone_android, 'No. Handphone', _adminData['phone'] ?? '-', AppColors.textDark, AppColors.primary),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // TOMBOL LOGOUT UTAMA
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _prosesLogout,
                      icon: const Icon(Icons.power_settings_new, color: AppColors.textWhite),
                      label: const CustomText('LOGOUT ADMIN', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite, letterSpacing: 1.5),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
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

  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgUtama,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(label, fontSize: 13, color: textColor.withOpacity(0.6), fontWeight: FontWeight.w500),
              const SizedBox(height: 4),
              CustomText(value, fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ],
          ),
        ),
      ],
    );
  }
}