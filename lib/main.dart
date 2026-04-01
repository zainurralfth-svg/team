import 'package:flutter/material.dart';
import 'tampilanawal.dart';
import 'masuk.dart';
import 'login.dart';
import 'menu.dart';
import 'keranjang.dart';
import 'konfirmasipesanan.dart';

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
        // Hilangkan kata kunci 'const' di sini agar tidak error
        '/': (context) => TampilanAwal(),
        '/masuk': (context) => MasukPage(), 
        '/login': (context) => LoginPage(), 
        '/menu': (context) => MenuPage(),
        '/keranjang': (context) => KeranjangPage(),
        '/konfirmasi': (context) => KonfirmasiPage(),
      },
    );
  }
}