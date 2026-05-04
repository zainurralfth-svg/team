import 'package:flutter/material.dart';
import 'Halaman_Awal/tampilanawal.dart';
import 'Halaman_Awal/login.dart';
import 'Halaman_Awal/register.dart';
import 'halaman_user/menu.dart';
import 'halaman_user/keranjang.dart';
import 'halaman_user/konfirmasipesanan.dart';
import 'Halaman_Awal/lupa_password.dart';
import 'halaman_admin/admin.dart';
import 'halaman_user/bukti_pesanan.dart';
import 'halaman_user/product_detail.dart';
import 'halaman_user/cek_pesanan.dart'; // Import file Cek Pesanan

void main() {
  runApp(const PuddingkuApp());
}

class PuddingkuApp extends StatelessWidget {
  const PuddingkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" merah
      title: 'Puddingku Smart System',
      initialRoute: '/',
      routes: {
        '/': (context) => TampilanAwal(),
        '/masuk': (context) => const MasukPage(), 
        '/login': (context) => const LoginPage(), 
        '/lupa-password': (context) => const LupaPasswordPage(), 
        '/menu': (context) => const MenuPage(), 
        '/keranjang': (context) => const KeranjangPage(), 
        '/cek_pesanan': (context) => const CekPesananPage(), 
        '/konfirmasi': (context) => const KonfirmasiPage(),
        '/bukti_pemesanan': (context) => const BuktiPemesanan(),
        '/admin_home': (context) => const HomeAdmin(),
      },
    );
  }
}