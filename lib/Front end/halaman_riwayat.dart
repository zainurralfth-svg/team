import 'package:flutter/material.dart';

class HalamanRiwayat extends StatelessWidget {
  const HalamanRiwayat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: const Color(0xFFD27F30),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Riwayat Pesanan'),
      ),
    );
  }
}