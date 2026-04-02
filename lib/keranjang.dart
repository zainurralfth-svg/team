import 'package:flutter/material.dart';

class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE5B9), Color(0xFFD27F30)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 440,
                height: 956,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFFE5B9),
                  shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    // Background decorative elements
                    Positioned(
                      left: 426.08,
                      top: 646,
                      child: Opacity(
                        opacity: 0.30,
                        child: Container(
                          transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.13),
                          width: 414.02,
                          height: 414.02,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/414x414"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Header
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 440,
                        height: 80,
                        decoration: BoxDecoration(color: const Color(0xFFD27F30)),
                      ),
                    ),
                    
                    // Tombol Kembali
                    Positioned(
                      left: 20,
                      top: 25,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              '←',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Judul Keranjang
                    Positioned(
                      left: 150,
                      top: 30,
                      child: Text(
                        'Keranjang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Oleo Script',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    
                    // Judul Keranjangku
                    Positioned(
                      left: 30,
                      top: 100,
                      child: Text(
                        'Keranjangku',
                        style: TextStyle(
                          color: const Color(0xFF270C0C),
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Item 1 - Brownie Burnt Cheesecake
                    Positioned(
                      left: 30,
                      top: 140,
                      child: Container(
                        width: 380,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Gambar Item 1
                    Positioned(
                      left: 45,
                      top: 150,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage('assets/images/burn.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    
                    // Nama Item 1
                    Positioned(
                      left: 130,
                      top: 155,
                      child: Text(
                        'Brownie Burnt Cheesecake',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Harga Item 1
                    Positioned(
                      left: 130,
                      top: 175,
                      child: Text(
                        'Rp 18.000',
                        style: TextStyle(
                          color: const Color(0xFFD27F30),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Tombol - Item 1
                    Positioned(
                      left: 130,
                      top: 200,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jumlah produk dikurangi'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5B9),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              '-',
                              style: TextStyle(
                                color: Color(0xFF270C0C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Jumlah Item 1
                    Positioned(
                      left: 160,
                      top: 200,
                      child: Container(
                        width: 30,
                        height: 25,
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Tombol + Item 1
                    Positioned(
                      left: 195,
                      top: 200,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jumlah produk ditambah'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5B9),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: Color(0xFF270C0C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Tombol hapus Item 1
                    Positioned(
                      left: 360,
                      top: 170,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Item'),
                              content: const Text('Yakin ingin menghapus item ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Item dihapus dari keranjang'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFF270C0C),
                          size: 20,
                        ),
                      ),
                    ),

                    // Item 2 - Death By Cokelat
                    Positioned(
                      left: 30,
                      top: 260,
                      child: Container(
                        width: 380,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Gambar Item 2
                    Positioned(
                      left: 45,
                      top: 270,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage('assets/images/death.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    
                    // Nama Item 2
                    Positioned(
                      left: 130,
                      top: 275,
                      child: Text(
                        'Death By Cokelat',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Harga Item 2
                    Positioned(
                      left: 130,
                      top: 295,
                      child: Text(
                        'Rp 18.000',
                        style: TextStyle(
                          color: const Color(0xFFD27F30),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Tombol - Item 2
                    Positioned(
                      left: 130,
                      top: 320,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jumlah produk dikurangi'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5B9),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              '-',
                              style: TextStyle(
                                color: Color(0xFF270C0C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Jumlah Item 2
                    Positioned(
                      left: 160,
                      top: 320,
                      child: Container(
                        width: 30,
                        height: 25,
                        child: const Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Tombol + Item 2
                    Positioned(
                      left: 195,
                      top: 320,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jumlah produk ditambah'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5B9),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: Color(0xFF270C0C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Tombol hapus Item 2
                    Positioned(
                      left: 360,
                      top: 290,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Item'),
                              content: const Text('Yakin ingin menghapus item ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Item dihapus dari keranjang'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFF270C0C),
                          size: 20,
                        ),
                      ),
                    ),

                    // Catatan Pesanan
                    Positioned(
                      left: 30,
                      top: 380,
                      child: Text(
                        'Catatan Pesanan',
                        style: TextStyle(
                          color: const Color(0xFF270C0C),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Field Catatan
                    Positioned(
                      left: 30,
                      top: 410,
                      child: Container(
                        width: 380,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD27F30)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(Icons.edit_note, color: Color(0xFFD27F30), size: 20),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Tambah Catatan'),
                                    content: const TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Contoh: Tidak pakai gula',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Catatan ditambahkan'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        child: const Text('Simpan'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                'Tambahkan Catatan (opsional)',
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Ringkasan Belanja
                    Positioned(
                      left: 30,
                      top: 480,
                      child: Container(
                        width: 380,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 3 Item
                    Positioned(
                      left: 45,
                      top: 500,
                      child: Text(
                        '3 Item',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    // Subtotal
                    Positioned(
                      left: 300,
                      top: 500,
                      child: Text(
                        'Subtotal',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    // Total Harga
                    Positioned(
                      left: 45,
                      top: 530,
                      child: Text(
                        'Rp 54.000',
                        style: TextStyle(
                          color: const Color(0xFFD27F30),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Tombol Konfirmasi Pesanan
                    Positioned(
                      left: 100,
                      top: 620,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/konfirmasi');
                        },
                        child: Container(
                          width: 240,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1C574),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFF270C0C)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Konfirmasi Pesanan',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Navigation
                    Positioned(
                      left: 0,
                      top: 860,
                      child: Container(
                        width: 440,
                        height: 80,
                        decoration: BoxDecoration(color: const Color(0xFFD27F30)),
                      ),
                    ),
                    
                    // Tombol Pesanan
                    Positioned(
                      left: 120,
                      top: 880,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Anda sudah di halaman keranjang'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_bag, color: Colors.white, size: 28),
                            const SizedBox(height: 5),
                            Text(
                              'Pesanan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Tombol Produk
                    Positioned(
                      left: 270,
                      top: 880,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            const Icon(Icons.menu, color: Colors.white, size: 28),
                            const SizedBox(height: 5),
                            Text(
                              'Produk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}