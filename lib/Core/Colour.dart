import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // --- WARNA BACKGROUND & GRADASI ---
  // ==========================================
  static const Color bgCream = Color(0xFFF2D7A6);
  static const Color gradasiAtas = Color(0xFFF7CC98);
  static const Color gradasiBawah = Color(0xFFCE7F31);

  // ==========================================
  // --- WARNA UTAMA APLIKASI ---
  // ==========================================
  static const Color primaryOrange = Color(0xFFD27F30);
  static const Color iconOrange = Color(0xFFFF9800);
  
  // ==========================================
  // --- WARNA KOLOM INPUT (FORM) ---
  // ==========================================
  static const Color inputBg = Color(0xFFEBE0C8);
  static const Color inputDisabledBg = Color(0xFFE0E0E0); 

  // ==========================================
  // --- WARNA TEKS & GARIS ---
  // ==========================================
  static const Color textDark = Color(0xFF1A0A0A);
  static const Color textWhite = Color(0xFFFFFFFF); 
  static const Color textHint = Color(0xFF9E9E9E); 
  static const Color strokeDark = Color(0xFF270C0C);
  
  // ==========================================
  // --- WARNA STATUS / NOTIFIKASI ---
  // ==========================================
  static const Color errorRed = Color(0xFFD9534F);
  static const Color successGreen = Color(0xFF4CAF50);

  // ==========================================
  // --- WARNA KHUSUS ADMIN (TEMA COKLAT TUA) ---
  // ==========================================
  static const Color adminBg = Color(0xFFFFE5B9);      
  static const Color adminPrimary = Color(0xFFD27F30); 
  static const Color adminCardLight = Color(0xFFFFF3DE); 
  static const Color adminStatCard = Color.fromRGBO(255, 255, 255, 0.24); 
  static const Color adminProfileText = Color(0xFF3A1F0F); 
  static const Color adminDivider = Color(0xFFBDBDBD);    
  static const Color adminIconBg = Color(0xFFFFE5B9);     

  // ==========================================
  // --- WARNA KHUSUS PROFIL USER ---
  // ==========================================
  static const Color profileBg = Color(0xFFF2D7A6);      
  static const Color profilePrimary = Color(0xFFC9792B); 
  static const Color profileCard = Color(0xFFF7E6C4);    
  static const Color profileText = Color(0xFF3A1F0F);    

  // ==========================================
  // --- WARNA KHUSUS CEK PESANAN ---
  // ==========================================
  static const Color cekPesananInputSecondary = Color(0xFFE0E0E0); 
  static const Color statusProsesBlue = Colors.blue;               
  static const Color statusText = Color(0xFF000000);              

  // ==========================================
  // --- WARNA KHUSUS KERANJANG ---
  // ==========================================
  static const Color cartBg = Color(0xFFD27F30);          // Krem background keranjang
  static const Color cartPrimary = Color(0xFFD27F30);     // Oranye header & teks harga
  static const Color cartBtnQty = Color(0xFFD27F30);      // Background tombol + dan -
  static const Color cartConfirmBtn = Color(0xFFF1C574);  // Kuning tombol Konfirmasi
  static const Color cartConfirmStroke = Color(0xFF270C0C); // Garis pinggir tombol konfirmasi

  // ==========================================
  // --- WARNA KHUSUS & BAYANGAN ---
  // ==========================================
  static const Color tombolGetStarted = Color.fromARGB(190, 255, 153, 0);
  static Color shadowCustom = Colors.black.withOpacity(0.15);
}