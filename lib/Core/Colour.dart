import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // --- 1. WARNA BRAND (TEMA PUDDINGKU) ---
  // ==========================================
  static const Color primary = Color(0xFFD27F30);      // Oranye Coklat Utama (Tombol utama, header, tombol tambah, ikon penting)
  static const Color primaryDark = Color(0xFFA66428);  // Oranye Gelap (Efek klik, border tegas, aksen admin)
  static const Color accent = Color(0xFFF1C574);       // Kuning Keemasan (Tombol checkout keranjang, tombol mulai)

  // ==========================================
  // --- 2. WARNA LATAR BELAKANG (BACKGROUND) ---
  // ==========================================
  static const Color bgUtama = Color(0xFFF9E4C5);      // Krem Standar (Latar seluruh layar utama: Beranda, Profil, Detail, dll)
  static const Color bgCard = Color(0xFFFFF3DE);       // Krem Sangat Terang (Warna kotak/card produk, kotak profil, struk)
  static const Color bgInput = Color(0xFFE8E4D9);      // Abu-abu Krem (Background kolom ketik, background tombol kecil edit/hapus)

  // ==========================================
  // --- 3. WARNA TEKS (TYPOGRAPHY) ---
  // ==========================================
  static const Color textDark = Color(0xFF1A0A0A);     // Hitam Pekat (Judul besar, harga)
  static const Color textBrown = Color(0xFF3A1F0F);    // Coklat Tua (Teks paragraf, nama produk, isi profil)
  static const Color textHint = Color(0xFF9E9E9E);     // Abu-abu (Teks bayangan di form / garis batas tipis)
  static const Color textWhite = Color(0xFFFFFFFF);    // Putih (Teks di dalam tombol utama)

  // ==========================================
  // --- 4. WARNA STATUS & EFEK ---
  // ==========================================
  static const Color success = Color(0xFF4CAF50);      // Hijau (Notifikasi sukses, centang bukti bayar)
  static const Color error = Color(0xFFF44336);        // Merah (Notifikasi error, tombol hapus)
  static const Color info = Colors.blue;               // Biru (Status pesanan sedang diproses)
  static Color shadow = Colors.black.withOpacity(0.15); // Efek bayangan (Shadow 3D untuk card)
}