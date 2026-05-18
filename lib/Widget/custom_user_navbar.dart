import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // <-- Pastikan path AppColors lo bener

class CustomUserNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomUserNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildBottomNavItem(
            icon: Icons.receipt_long,
            label: 'Pesanan',
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildBottomNavItem(
            icon: Icons.cake,
            label: 'Produk',
            index: 1,
            isSelected: currentIndex == 1,
          ),
          _buildBottomNavItem(
            icon: Icons.person,
            label: 'Profil',
            index: 2,
            isSelected: currentIndex == 2,
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER BAWAAN (Udah gue bungkus jadi satu di sini)
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        color: Colors.transparent, // Biar area kliknya luas dan enak dipencet
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
                color: isSelected ? AppColors.primary : Colors.white, // Ikon oranye kalau aktif, putih kalau nggak
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}