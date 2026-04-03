import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. TAMBAHKAN IMPORT FIREBASE
import 'firebase_options.dart';                    // 2. TAMBAHKAN IMPORT OPTIONS FIREBASE

import 'tampilanawal.dart';
import 'masuk.dart';
import 'login.dart';
import 'menu.dart';
import 'keranjang.dart';
import 'konfirmasipesanan.dart';
import 'lupa_password.dart'; 

// 3. UBAH MAIN JADI ASYNC DAN TAMBAHKAN KODE INIT FIREBASE
void main() async {
  // Pastikan Flutter sudah siap membaca widget sebelum menyalakan Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menyalakan mesin Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        '/lupa-password': (context) => LupaPasswordPage(), 
        '/menu': (context) => MenuPage(),
        '/keranjang': (context) => KeranjangPage(),
        '/konfirmasi': (context) => KonfirmasiPage(),
      },
    );
  }
}