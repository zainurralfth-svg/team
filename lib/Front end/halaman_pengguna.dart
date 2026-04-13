import 'package:flutter/material.dart';

class HalamanPengguna extends StatelessWidget {
  const HalamanPengguna({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        backgroundColor: const Color(0xFFD27F30),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Kelola Pengguna'),
      ),
    );
  }
}