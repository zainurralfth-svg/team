import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFD27F30);

    return Container(
      height: 75,
      decoration: const BoxDecoration(color: primaryOrange),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.assignment_outlined, 'Laporan', currentIndex == 0, () => onTap(0)),
          _navItem(Icons.cake_outlined, 'Produk', currentIndex == 1, () => onTap(1)),
          _navItem(Icons.home_outlined, 'Beranda', currentIndex == 2, () => onTap(2)),
          _navItem(Icons.history, 'Riwayat', currentIndex == 3, () => onTap(3)),
          _navItem(Icons.person_outline, 'Pengguna', currentIndex == 4, () => onTap(4)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black.withOpacity(0.3) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Signika Negative',
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}