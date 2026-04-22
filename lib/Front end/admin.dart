import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // Sesuaikan folder lo
import 'tambah_produk.dart'; 
import 'halaman_produk.dart';
import 'halaman_riwayat.dart';
import 'halaman_laporan.dart';
import 'halaman_pengguna.dart';
import 'halaman_pesanan.dart';
import 'halaman_profil_admin.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBg, 
      body: Stack(
        children: [
          Container(
            height: 330,
            decoration: const BoxDecoration(
              color: AppColors.adminPrimary,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                _buildStatCards(context), 
                const SizedBox(height: 25),
                _buildIncomeCard(),
                const SizedBox(height: 15),
                _buildSectionTitle(),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildOrderList(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Dashboard Admin',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfilAdmin()));
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.textWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.adminPrimary, size: 30),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard('12\nProduk', Icons.pie_chart, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProduk()));
          }),
          _statCard('Riwayat\nPesanan', Icons.shopping_bag, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()));
          }),
          _statCard('Laporan', Icons.assignment, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
          }),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        height: 105,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.adminStatCard, 
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textWhite, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pendapatan',
            style: TextStyle(color: AppColors.adminPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '570.000',
            style: TextStyle(color: AppColors.adminPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.adminPrimary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Daftar Pesanan',
        style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      itemCount: 4, 
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.adminCardLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.adminPrimary)),
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mr.A', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Taro pudding 1x, Browkies 1x', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Rp 25.000', style: TextStyle(color: AppColors.adminPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.adminBg, borderRadius: BorderRadius.circular(5)),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('PROSES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    children: [
                      Icon(Icons.alarm, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('15 menit lalu', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 70,
      color: AppColors.adminPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomNavItem(Icons.home, 'BERANDA', true, () {}),
          _bottomNavItem(Icons.person, 'PENGGUNA', false, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanPengguna()));
          }),
          _bottomNavItem(Icons.add_box, 'PRODUK BARU', false, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahProdukPage())); 
          }),
          _bottomNavItem(Icons.add_circle_outline, 'PESANAN', false, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanPesanan()));
          }),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.textWhite : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? AppColors.adminPrimary : AppColors.textWhite, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}