import 'package:flutter/material.dart';

class HalamanLaporan extends StatelessWidget {
  const HalamanLaporan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: const Color(0xFFD27F30),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Laporan Penjualan'),
      ),
    );
  }
}