import 'package:flutter/material.dart';
import 'front end/tampilanawal.dart';
import 'front end/masuk.dart';
import 'front end/login.dart';
import 'front end/menu.dart';
import 'front end/keranjang.dart';
import 'front end/konfirmasipesanan.dart';
import 'front end/lupa_password.dart'; // 1. TAMBAHKAN IMPORT INI

void main() {
  runApp(PuddingkuApp());
}

class PuddingkuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Puddingku Smart System',
      initialRoute: '/',
      routes: {
        '/': (context) => TampilanAwal(),
        '/masuk': (context) => MasukPage(), 
        '/login': (context) => LoginPage(), 
        '/lupa-password': (context) => LupaPasswordPage(), // 2. DAFTARKAN RUTE DI SINI
        '/menu': (context) => MenuPage(),
        '/keranjang': (context) => KeranjangPage(),
        '/konfirmasi': (context) => KonfirmasiPage(),
      },
    );
  }
}