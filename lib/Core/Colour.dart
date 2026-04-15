import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // --- WARNA BACKGROUND & GRADASI ---
  // ==========================================
  // Warna Latar Belakang Utama (Cream)
  static const Color bgCream = Color(0xFFF2D7A6);
  // Warna Atas untuk Gradasi Background
  static const Color gradasiAtas = Color(0xFFF7CC98);
  // Warna Bawah untuk Gradasi Background (Oranye Gelap)
  static const Color gradasiBawah = Color(0xFFCE7F31);

  // ==========================================
  // --- WARNA UTAMA APLIKASI ---
  // ==========================================
  // Warna Utama (Oranye Kecoklatan untuk Form, Tombol, Footer)
  static const Color primaryOrange = Color(0xFFD27F30);
  // Warna Ikon Form (Oranye Terang)
  static const Color iconOrange = Color(0xFFFF9800);
  
  // ==========================================
  // --- WARNA KOLOM INPUT (FORM) ---
  // ==========================================
  // Warna Latar Kolom Input Text Aktif
  static const Color inputBg = Color(0xFFEBE0C8);
  // Warna Latar Kolom Input Terkunci/Disabled (Abu-abu) -> Tambahan Lupa Password
  static const Color inputDisabledBg = Color(0xFFE0E0E0); 

  // ==========================================
  // --- WARNA TEKS & GARIS ---
  // ==========================================
  // Warna Teks Gelap (Hitam Kecoklatan)
  static const Color textDark = Color(0xFF1A0A0A);
  // Warna Teks Putih Bersih (Untuk Judul & Ikon) -> Tambahan Lupa Password
  static const Color textWhite = Color(0xFFFFFFFF); 
  // Warna Teks Bayangan/Hint Form (Abu-abu) -> Tambahan Lupa Password
  static const Color textHint = Color(0xFF9E9E9E); 
  // Warna Garis Dekorasi Header (Coklat Sangat Gelap)
  static const Color strokeDark = Color(0xFF270C0C);
  
  // ==========================================
  // --- WARNA STATUS / NOTIFIKASI ---
  // ==========================================
  // Warna Notifikasi Error (Merah)
  static const Color errorRed = Color(0xFFD9534F);
  // Warna Notifikasi Sukses (Hijau)
  static const Color successGreen = Color(0xFF4CAF50);

  // ==========================================
  // --- WARNA KHUSUS ---
  // ==========================================
  // Warna Tombol "Get Started" (Cokelat Sangat Gelap/Pekat)
  static const Color tombolGetStarted = Color.fromARGB(190, 255, 153, 0);
}