import 'package:flutter/material.dart';
import 'Front end/tampilanawal.dart';
import 'Front end/masuk.dart';
import 'Front end/login.dart';
import 'Front end/menu.dart';
import 'Front end/keranjang.dart';
import 'Front end/konfirmasipesanan.dart';
import 'Front end/lupa_password.dart';
import 'Front end/admin.dart';
import 'Front end/bukti_pesanan.dart';
import 'Front end/product_detail.dart';
import 'Front end/cek_pesanan.dart'; // Import file Cek Pesanan

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