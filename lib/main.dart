import 'package:flutter/material.dart';
<<<<<<< Updated upstream

// --- IMPORT DARI FOLDER FRONT END ---
import 'Front end/tampilanawal.dart';
import 'Front end/masuk.dart';
import 'Front end/login.dart';
import 'Front end/menu.dart';
import 'Front end/keranjang.dart';
import 'Front end/konfirmasipesanan.dart';
import 'Front end/lupa_password.dart';
=======
import 'tampilanawal.dart';
import 'masuk.dart';
import 'login.dart';
import 'menu.dart';
import 'keranjang.dart';
import 'konfirmasipesanan.dart';
import 'lupa_password.dart'; // 1. TAMBAHKAN IMPORT INI';
>>>>>>> Stashed changes

void main() {
  runApp(const PuddingkuApp()); // Tambah const biar performanya lebih ringan
}

class PuddingkuApp extends StatelessWidget {
  const PuddingkuApp({super.key}); // Tambah key constructor standar Flutter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ngilangin pita "DEBUG" di pojok kanan atas
      title: 'Puddingku Smart System',
      initialRoute: '/',
      routes: {
        '/': (context) => TampilanAwal(),
        '/masuk': (context) => const MasukPage(), 
        '/login': (context) => const LoginPage(), 
        '/lupa-password': (context) => const LupaPasswordPage(), 
        '/menu': (context) => MenuPage(),
        '/keranjang': (context) => KeranjangPage(),
        '/konfirmasi': (context) => KonfirmasiPage(),
      },
    );
  }
}