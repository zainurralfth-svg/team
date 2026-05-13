import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- TAMBAHAN WAJIB
import 'Halaman_Awal/tampilanawal.dart';
import 'Halaman_Awal/login.dart'; // <-- Halaman Login kamu
import 'Halaman_Awal/register.dart'; // <-- Halaman Register kamu
import 'Halaman_Awal/lupa_password.dart';

import 'halaman_user/menu.dart';
import 'halaman_user/keranjang.dart';
import 'halaman_user/konfirmasipesanan.dart';
import 'halaman_user/bukti_pesanan.dart';
import 'halaman_user/cek_pesanan.dart'; 

import 'halaman_admin/admin.dart';

void main() async {
  // Pastikan Flutter sudah siap sebelum memuat bahasa
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Memuat kamus bahasa Indonesia untuk tanggalan
  await initializeDateFormatting('id_ID', null); 

  runApp(const PuddingkuApp()); // Sesuaikan dengan nama class App abang
}

class PuddingkuApp extends StatelessWidget {
  const PuddingkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Puddingku Smart System',
      initialRoute: '/',
      
      // ==========================================
      // PETA JALAN (ROUTING) APLIKASI
      // ==========================================
      routes: {
        '/': (context) => const TampilanAwal(), 
        
        // CATATAN: Kalau di sini 'MasukPage()' ada garis merah, 
        // ganti namanya jadi 'LoginPage()' menyesuaikan nama class di file login.dart kamu.
        '/login': (context) => const LoginPage(), 
        
        // CATATAN: Kalau di sini 'LoginPage()' ada garis merah, 
        // ganti namanya jadi 'RegisterPage()' menyesuaikan nama class di file register.dart kamu.
        '/register': (context) => const RegisterPage(), 

        '/lupa-password': (context) => const LupaPasswordPage(), 
        '/menu': (context) => const MenuPage(), 
        '/keranjang': (context) => const KeranjangPage(), 
        '/cek_pesanan': (context) => const CekPesananPage(), 
        '/konfirmasipesanan': (context) => const KonfirmasiPage(),
        '/bukti_pemesanan': (context) => const BuktiPemesanan(),
        '/admin_home': (context) => const HomeAdmin(),
      },
    );
  }
}