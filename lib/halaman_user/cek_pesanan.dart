import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // Palet 14 Warna Baru
import 'profil_pengguna.dart'; 

class CekPesananPage extends StatefulWidget {
  const CekPesananPage({super.key});

  @override
  State<CekPesananPage> createState() => _CekPesananPageState();
}

class _CekPesananPageState extends State<CekPesananPage> {
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Menggunakan background krem utama
      
      appBar: AppBar(
        backgroundColor: AppColors.primary, // Menggunakan oranye coklat
        elevation: 0,
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        title: const Text(
          'Cek Pesanan Anda',
          style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontFamily: 'Oleo Script', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Cek dengan kode',
              style: TextStyle(color: AppColors.primary, fontSize: 28, fontFamily: 'Oleo Script', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _kodeController,
                      style: const TextStyle(color: AppColors.textDark), // Teks input
                      decoration: const InputDecoration(
                        hintText: 'Kode',
                        hintStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(10)), // Pakai warna bgInput
                    child: TextField(
                      controller: _namaController,
                      style: const TextStyle(color: AppColors.textDark), // Teks input
                      decoration: const InputDecoration(
                        hintText: 'Nama',
                        hintStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.textWhite, // Background kotak putih
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#e1234', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Joko', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 1, height: 30),
                  
                  _buildOrderItem('Brownie Burnt Cheescake', '2x', '36.000', AppColors.primary),
                  const SizedBox(height: 15),
                  _buildOrderItem('Death By Chocolate', '1x', '18.000', AppColors.primary),
                  
                  const SizedBox(height: 25),
                  
                  const Text('Status Pesanan', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(color: AppColors.info, shape: BoxShape.circle), // Pakai warna info (biru)
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(5)),
                        child: const Text('PROSES', style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.bold)), // Teks gelap
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
      // FOOTER BAWAAN MENU (PASTI KEMBAR IDENTIK)
      // ==============================================================
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.primary, // Warna oranye utama
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                // Biarkan kosong, karena ini sedang di halaman Pesanan
              },
              // TRUE -> Ada bunderan putihnya di tombol Pesanan
              child: _buildBottomNavItem(Icons.receipt_long, 'Pesanan', true, AppColors.primary),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); 
              },
              child: _buildBottomNavItem(Icons.cake, 'Produk', false, AppColors.primary),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfil()));
              },
              child: _buildBottomNavItem(Icons.person, 'Profil', false, AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

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

  // ==============================================================
  // HELPER BOTTOM ITEM DENGAN BUNDERAN PUTIH (100% SAMA KAYA MENU)
  // ==============================================================
  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected, Color activeColor) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent, // Bunderan putih kalau aktif
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              color: isSelected ? activeColor : Colors.white, // Ikon jadi orange kalau aktif
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label, 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 12,
              fontWeight: FontWeight.bold // Biar tulisannya tegas
            )
          )
        ]
      ),
    );
  }
}
