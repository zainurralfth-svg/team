import 'package:flutter/material.dart';
<<<<<<< HEAD

// --- IMPORT DARI FOLDER FRONT END ---
import 'Front end/tampilanawal.dart';
import 'Front end/masuk.dart';
import 'Front end/login.dart';
import 'Front end/menu.dart';
import 'Front end/keranjang.dart';
import 'Front end/konfirmasipesanan.dart';
import 'Front end/lupa_password.dart';
=======
import 'front end/tampilanawal.dart';
import 'front end/masuk.dart';
import 'front end/login.dart';
import 'front end/menu.dart';
import 'front end/keranjang.dart';
import 'front end/konfirmasipesanan.dart';
import 'front end/lupa_password.dart'; // 1. TAMBAHKAN IMPORT INI
>>>>>>> 6a0a525ba8181b38ecdeecf7e47ae64f957827db

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