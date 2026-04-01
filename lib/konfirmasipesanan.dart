import 'package:flutter/material.dart';

class KonfirmasiPage extends StatelessWidget {
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
                    
                    // Judul Konfirmasi Pesanan
                    Positioned(
                      left: 110,
                      top: 30,
                      child: Text(
                        'Konfirmasi Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Oleo Script',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    
                    // Ringkasan Pemesanan
                    Positioned(
                      left: 30,
                      top: 100,
                      child: Text(
                        'Ringkasan Pemesanan',
                        style: TextStyle(
                          color: const Color(0xFF270C0C),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Card Ringkasan
                    Positioned(
                      left: 30,
                      top: 130,
                      child: Container(
                        width: 380,
                        height: 180,
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
                    
                    // Item 1 dengan gambar burn.jpeg
                    Positioned(
                      left: 45,
                      top: 145,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage('assets/images/burn.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 110,
                      top: 145,
                      child: Text(
                        'Brownie Burnt Cheesecake',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 110,
                      top: 165,
                      child: Text(
                        'x2',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 320,
                      top: 155,
                      child: Text(
                        'Rp 36.000',
                        style: TextStyle(
                          color: const Color(0xFFD27F30),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Item 2 dengan gambar death.jpeg
                    Positioned(
                      left: 45,
                      top: 200,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage('assets/images/death.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 110,
                      top: 210,
                      child: Text(
                        'Death By Cokelat',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 110,
                      top: 230,
                      child: Text(
                        'x1',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 320,
                      top: 220,
                      child: Text(
                        'Rp 18.000',
                        style: TextStyle(
                          color: const Color(0xFFD27F30),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Garis pembatas
                    Positioned(
                      left: 30,
                      top: 270,
                      child: Container(
                        width: 380,
                        height: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    
                    // Total
                    Positioned(
                      left: 30,
                      top: 280,
                      child: Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 320,
                      top: 280,
                      child: Text(
                        'Rp 54.000',
                        style: TextStyle(
                          color: const Color(0xFFD27F30),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Data Diri
                    Positioned(
                      left: 30,
                      top: 330,
                      child: Text(
                        'Data Diri',
                        style: TextStyle(
                          color: const Color(0xFF270C0C),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Card Data Diri - NAMA LENGKAP
                    Positioned(
                      left: 30,
                      top: 360,
                      child: Container(
                        width: 380,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                    
                    // Label NAMA LENGKAP
                    Positioned(
                      left: 45,
                      top: 370,
                      child: Text(
                        'NAMA LENGKAP',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Isi Nama
                    Positioned(
                      left: 45,
                      top: 390,
                      child: Text(
                        'Nama Kamu',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Card Data Diri - NO. TELP
                    Positioned(
                      left: 30,
                      top: 430,
                      child: Container(
                        width: 380,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                    
                    // Label NO. TELP
                    Positioned(
                      left: 45,
                      top: 440,
                      child: Text(
                        'NO. TELP',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Isi No Telp
                    Positioned(
                      left: 45,
                      top: 460,
                      child: Text(
                        'No. Telp',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // TULISAN "KIRIM" (menggantikan logo WA & Telegram)
                    Positioned(
                      left: 170,
                      top: 520,
                      child: Container(
                        width: 100,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD27F30),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data akan dikirim ke admin'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Center(
                            child: Text(
                              'Kirim',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Catatan
                    Positioned(
                      left: 30,
                      top: 600,
                      child: Container(
                        width: 380,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE1AD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD27F30)),
                        ),
                        child: const Text(
                          'Nb: Lakukan pembayaran di outlet',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    // Tombol Checkout
                    Positioned(
                      left: 100,
                      top: 670,
                      child: GestureDetector(
                        onTap: () {
                          // Tampilkan dialog sukses
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sukses!'),
                              content: const Text('Pesanan Anda telah dikonfirmasi. Terima kasih!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup dialog
                                    Navigator.pushReplacementNamed(context, '/menu'); // Kembali ke menu
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
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
                              'Checkout Sekarang',
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
                          Navigator.pop(context);
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
                          Navigator.pushReplacementNamed(context, '/menu');
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