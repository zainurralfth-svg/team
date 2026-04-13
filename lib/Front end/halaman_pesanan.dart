import 'package:flutter/material.dart';

class HalamanPesanan extends StatelessWidget {
  const HalamanPesanan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        backgroundColor: const Color(0xFFD27F30),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Pesanan Masuk'),
      ),
    );
  }
}