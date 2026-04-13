import 'package:flutter/material.dart';

class HalamanProduk extends StatelessWidget {
  const HalamanProduk({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: const Color(0xFFD27F30),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Daftar Produk'),
      ),
    );
  }
}