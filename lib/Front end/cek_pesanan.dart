import 'package:flutter/material.dart';

class CekPesananPage extends StatefulWidget {
  const CekPesananPage({super.key});

  @override
  State<CekPesananPage> createState() => _CekPesananPageState();
}

class _CekPesananPageState extends State<CekPesananPage> {
  // Controller untuk mengambil teks yang diketik user
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color colorBg = Color(0xFFFFE5B9);
    const Color colorPrimary = Color(0xFFD27F30);

    return Scaffold(
      backgroundColor: colorBg,
      
      // =========================================================
      // APP BAR (BAGIAN ATAS)
      // =========================================================
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Kembali', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        leadingWidth: 100,
        title: const Text(
          'Cek Pesanan Anda',
          style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Oleo Script', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // =========================================================
      // BODY (ISI HALAMAN)
      // =========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Judul Form
            const Text(
              'Cek dengan kode',
              style: TextStyle(color: colorPrimary, fontSize: 28, fontFamily: 'Oleo Script', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Form Input (Kode & Nama)
            Row(
              children: [
                // Input Kode
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _kodeController,
                      decoration: const InputDecoration(
                        hintText: 'Kode',
                        hintStyle: TextStyle(color: colorPrimary, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Input Nama
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        hintText: 'Nama',
                        hintStyle: TextStyle(color: colorPrimary, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Kolom Hasil Pencarian (Kartu Putih)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hasil Input Sementara (Sesuai Desain Figma)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('#e1234', style: TextStyle(color: colorPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Joko', style: TextStyle(color: colorPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 1, height: 30),
                  
                  // Daftar Produk
                  _buildOrderItem('Brownie Burnt Cheescake', '2x', '36.000', colorPrimary),
                  const SizedBox(height: 15),
                  _buildOrderItem('Death By Chocolate', '1x', '18.000', colorPrimary),
                  
                  const SizedBox(height: 25),
                  
                  // Status Pesanan
                  const Text('Status Pesanan', style: TextStyle(color: colorPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: colorBg, borderRadius: BorderRadius.circular(5)),
                        child: const Text('PROSES', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ==============================================================
      // BOTTOM NAVIGATION BAR 
      // ==============================================================
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(color: colorPrimary),
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // TOMBOL 1: Pesanan (Sedang Aktif)
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Sudah di halaman pesanan, tidak usah pindah
                  },
                  child: _buildBottomNavItem(Icons.receipt_long, 'Pesanan', isActive: true),
                ),
              ),
              
              // TOMBOL 2: Produk (Kembali ke Menu)
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Pindah ke halaman menu produk
                    Navigator.pushNamed(context, '/menu');
                  },
                  child: _buildBottomNavItem(Icons.cake, 'Produk', isActive: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Bantuan untuk List Item Pesanan
  Widget _buildOrderItem(String nama, String qty, String harga, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(nama, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: 1,
          child: Center(child: Text(qty, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600))),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(harga, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // Widget Bantuan untuk Bottom Nav
  Widget _buildBottomNavItem(IconData icon, String label, {required bool isActive}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, 
      children: [
        Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 28), 
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 13, fontWeight: FontWeight.bold))
      ]
    );
  }
}