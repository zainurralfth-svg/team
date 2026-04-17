import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // --- WARNA BACKGROUND & GRADASI ---
  // ==========================================
  // Warna Latar Belakang Utama (Cream) 
  // [Dipakai di: Masuk, Register, Lupa Password]
  static const Color bgCream = Color(0xFFF2D7A6);
  
  // Warna Atas untuk Gradasi Background 
  // [Dipakai di: Tampilan Awal / Get Started]
  static const Color gradasiAtas = Color(0xFFF7CC98);
  
  // Warna Bawah untuk Gradasi Background (Oranye Gelap) 
  // [Dipakai di: Tampilan Awal / Get Started]
  static const Color gradasiBawah = Color(0xFFCE7F31);

  // ==========================================
  // --- WARNA UTAMA APLIKASI ---
  // ==========================================
  // Warna Utama (Oranye Kecoklatan untuk Kotak Form, Tombol, dan Footer Bawah) 
  // [Dipakai di: Masuk, Register, Lupa Password]
  static const Color primaryOrange = Color(0xFFD27F30);
  
  // Warna Ikon Form (Oranye Terang untuk ikon di dalam kolom ngetik) 
  // [Dipakai di: Masuk, Register, Lupa Password]
  static const Color iconOrange = Color(0xFFFF9800);
  
  // ==========================================
  // --- WARNA KOLOM INPUT (FORM) ---
  // ==========================================
  // Warna Latar Kolom Input Text Aktif (Tempat ngetik)
  // [Dipakai di: Masuk, Register, Lupa Password]
  static const Color inputBg = Color(0xFFEBE0C8);
  
  // Warna Latar Kolom Input Terkunci/Disabled (Abu-abu) 
  // [Dipakai khusus di: Lupa Password - saat nomor HP sudah terverifikasi]
  static const Color inputDisabledBg = Color(0xFFE0E0E0); 

  // ==========================================
  // --- WARNA TEKS & GARIS ---
  // ==========================================
  // Warna Teks Gelap (Hitam Kecoklatan untuk teks "Selamat Datang") 
  // [Dipakai di: Tampilan Awal, Masuk, Register]
  static const Color textDark = Color(0xFF1A0A0A);
  
  // Warna Teks Putih Bersih (Untuk Judul Form, Label, Ikon Back, Teks Tombol) 
  // [Dipakai di: Masuk, Register, Lupa Password]
  static const Color textWhite = Color(0xFFFFFFFF); 
  
  // Warna Teks Bayangan/Hint Form (Abu-abu untuk teks "Ketik Disini" & Ikon Mata) 
  // [Dipakai di: Masuk, Register, Lupa Password]
  static const Color textHint = Color(0xFF9E9E9E); 
  
  // Warna Garis Dekorasi Header (Coklat Sangat Gelap untuk garis miring/lurus di gambar) 
  // [Dipakai di: Masuk, Register, Lupa Password]
  static const Color strokeDark = Color(0xFF270C0C);
  
  // ==========================================
  // --- WARNA STATUS / NOTIFIKASI ---
  // ==========================================
  // Warna Notifikasi Error (Merah untuk pesan Username/Password salah atau kosong) 
  // [Dipakai di: Masuk, Register, Lupa Password]
  static const Color errorRed = Color(0xFFD9534F);
  
  // Warna Notifikasi Sukses (Hijau untuk pesan berhasil login/ubah password) 
  // [Dipakai di: Masuk, Lupa Password]
  static const Color successGreen = Color(0xFF4CAF50);

  // ==========================================
  // --- WARNA KHUSUS & BAYANGAN ---
  // ==========================================
  // Warna Tombol "Get Started" (Cokelat Sangat Gelap/Pekat) 
  // [Dipakai khusus di: Tampilan Awal]
  static const Color tombolGetStarted = Color.fromARGB(190, 255, 153, 0);
  
  // Warna Bayangan Hitam Transparan untuk Kotak Form Utama 
  // [Dipakai di: Masuk, Register, Lupa Password]
  static Color shadowCustom = Colors.black.withOpacity(0.15);
}