import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
<<<<<<< HEAD
  // Controller untuk mengambil teks yang diinputkan user (opsional, bisa ditambahkan nanti)
=======
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
<<<<<<< HEAD
  // Variabel state untuk buka-tutup (hide/show) password
=======
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
  bool _passwordVisible = false;

  @override
  void dispose() {
<<<<<<< HEAD
    // Membersihkan controller dari memori saat halaman ditutup untuk mencegah kebocoran memori (memory leak)
=======
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
    _namaController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background layar utama (Krem/Beige muda)
      backgroundColor: const Color(0xFFEFE2C8), 
      
      // Menggunakan SingleChildScrollView agar layar bisa di-scroll 
      // ketika keyboard hp muncul, sehingga tidak error "Bottom Overflowed"
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. BAGIAN HEADER (GAMBAR KUE MIRING & GARIS HITAM)
            // ==========================================
            Stack(
              children: [
                // ClipPath bertugas memotong gambar sesuai bentuk yang kita buat di class HeaderClipper
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 320, // Tinggi gambar header
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/brow.jpeg'), // Memanggil gambar iya.jpeg
                        fit: BoxFit.cover, // Memastikan gambar memenuhi kotak
                      ),
                    ),
                  ),
                ),
                
                // CustomPaint ini bertugas MENGGAMBAR GARIS HITAM tebal
                // Tepat di tepi potongan gambar agar terlihat seperti desain aslinya
                CustomPaint(
                  size: const Size(double.infinity, 320),
                  painter: GarisMiringPainter(),
                ),
                
                // Tombol Kembali (Panah Putih di pojok kiri atas)
                Positioned(
                  left: 20,
                  top: 50, // Jarak dari atas layar (aman dari status bar HP)
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context), // Fungsi kembali ke layar sebelumnya
                  ),
=======
  void _prosesRegister() {
    final nama = _namaController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (nama.isEmpty || username.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150, 
            left: 20,
            right: 20,
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD9534F), 
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Semua data register harus diisi!',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2D7A6), // Sama dengan Login
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? 650 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              // --- BACKGROUND DEKORATIF ---
              Positioned(
                right: -30, top: 360,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset('assets/images/tiga.png', width: 150, errorBuilder: (c, e, s) => const SizedBox()),
                ),
              ),

              // --- KONTEN UTAMA ---
              SingleChildScrollView(
                child: Column(
                  children: [
                    // 1. HEADER (FULL WIDTH DI DESKTOP)
                    Stack(
                      children: [
                        ClipPath(
                          clipper: HeaderClipper(),
                          child: Container(
                            width: double.infinity,
                            height: isDesktop ? 400 : 280,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/brow.jpeg'),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: Size(double.infinity, isDesktop ? 400 : 280),
                          painter: GarisMiringPainter(),
                        ),
                        Positioned(
                          left: 10, top: 30,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 2. TEKS JUDUL
                    Center(
                      child: Container(
                        width: contentWidth,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Text(
                              'REGISTER',
                              style: TextStyle(
                                color: Color(0xFF270C0C),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const Text(
                              'Register Untuk Membuat Akun',
                              style: TextStyle(color: Color(0xFF270C0C), fontSize: 18),
                            ),
                            const SizedBox(height: 30),

                            // 3. KOTAK FORM (LEBIH LEBAR DI DESKTOP)
                            Container(
                              width: isDesktop ? 700 : double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD27F30),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputField('Nama Lengkap', 'Ketik Disini', Icons.badge_outlined, _namaController),
                                  _buildInputField('Username', 'Arif12309', Icons.person_outline, _usernameController),
                                  _buildInputField('Phone', '0812345678', Icons.phone_outlined, _phoneController),
                                  _buildInputField('Password', '*********', Icons.lock_outline, _passwordController, isPassword: true),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 4. TOMBOL REGISTER
                            SizedBox(
                              width: isDesktop ? 350 : double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD27F30), // Tetap Cokelat agar menonjol
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                ),
                                onPressed: _prosesRegister,
                                child: const Text('REGISTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
                ),
              ],
            ),

            // ==========================================
            // 2. BAGIAN TEKS JUDUL (REGISTER)
            // ==========================================
            // Padding untuk memberi jarak antara gambar atas dan teks judul
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Column(
                children: [
                  const Text(
                    'REGISTER',
                    style: TextStyle(
                      color: Color(0xFF270C0C), // Cokelat sangat gelap / Hitam
                      fontSize: 36, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2, // Jarak antar huruf
                    ),
                  ),
                  const SizedBox(height: 5), // Jarak antara judul dan sub-judul
                  const Text(
                    'Register Untuk Membuat Akun',
                    style: TextStyle(
                      color: Color(0xFF270C0C),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
<<<<<<< HEAD
            ),

            // ==========================================
            // 3. BAGIAN KOTAK FORM (Warna Cokelat/Oranye)
            // ==========================================
            Container(
              width: MediaQuery.of(context).size.width * 0.88, // Lebar kotak 88% dari layar
              padding: const EdgeInsets.all(25), // Jarak ke dalam (ruang bernafas di dalam kotak)
              decoration: BoxDecoration(
                color: const Color(0xFFC9792B), // Warna background kotak form
                borderRadius: BorderRadius.circular(35), // Melengkungkan sudut kotak
                boxShadow: [
                  // Efek bayangan (shadow) di bawah kotak form
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Memanggil Fungsi pembantu _buildInputField yang kita buat di bawah
                  _buildInputField('Nama Lengkap', 'Arif Dwi Firmansyah', Icons.badge_outlined, _namaController),
                  _buildInputField('Username', 'Arif12309', Icons.person_outline, _usernameController),
                  _buildInputField('Phone', '08123456789', Icons.phone_outlined, _phoneController),
                  // Khusus password, kita aktifkan mode 'isPassword: true' agar titik-titik dan ada ikon mata
                  _buildInputField('Password', '*********', Icons.lock_outline, _passwordController, isPassword: true),
                  
                  const SizedBox(height: 20), // Jarak sebelum tombol
                  
                  // Tombol Konfirmasi Register
                  SizedBox(
                    width: double.infinity, // Tombol melebar penuh mengikuti kotak
                    height: 55, // Tinggi tombol
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A1F0F), // Warna tombol cokelat tua
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Melengkungkan tombol
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        // Navigasi ke halaman Menu setelah di-klik
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MenuPage()),
                        );
                      },
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Jarak kosong di bagian paling bawah agar bisa di scroll lega
            const SizedBox(height: 40), 
          ],
        ),
=======

              // --- 5. FOOTER (FULL WIDTH) ---
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD27F30),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.cake, color: Color(0xFFD27F30), size: 28),
                      ),
                      const SizedBox(width: 10),
                      const Text('Puddingku', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
      ),
    );
  }

<<<<<<< HEAD
  // ==========================================
  // WIDGET PEMBANTU: UNTUK MEMBUAT KOLOM INPUT
  // ==========================================
  // Dibuat terpisah agar kodenya tidak panjang dan berulang-ulang
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15), // Jarak antar input field
=======
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
        children: [
<<<<<<< HEAD
          // Teks Label (Contoh: "Nama Lengkap")
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5), // Jarak antara label dan kotak input
          
          // Kotak tempat mengetik
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7E6C4), // Warna dasar kotak input (krem muda)
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              // Jika isPassword true, periksa _passwordVisible. Jika false, teks biasa.
=======
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF7E6C4), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: controller,
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
              obscureText: isPassword ? !_passwordVisible : false,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
<<<<<<< HEAD
                // Ikon di kiri teks
                prefixIcon: Icon(icon, color: const Color(0xFFC9792B), size: 20),
                
                // Ikon mata di kanan teks (hanya muncul kalau mode password)
                suffixIcon: isPassword 
                  ? GestureDetector(
                      onTap: () {
                        // Mengubah status buka/tutup password saat diklik
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      child: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off, 
                        color: Colors.grey, 
                        size: 20,
                      ),
                    )
                  : null,
                  
                // Teks bayangan (placeholder)
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                border: InputBorder.none, // Menghilangkan garis bawaan TextField
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Padding dalam
=======
                prefixIcon: Icon(icon, color: const Color(0xFFFF9800), size: 24),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(() => _passwordVisible = !_passwordVisible),
                        child: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 24),
                      )
                    : null,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
              ),
            ),
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
// ==========================================
// KELAS PEMBANTU: ALAT POTONG GAMBAR (CLIPPER)
// ==========================================
=======
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
<<<<<<< HEAD
    // Proses membuat potongan:
    path.lineTo(0, size.height); // Tarik garis lurus dari atas ke kiri bawah
    path.lineTo(size.width, size.height - 70); // Tarik garis MIRING ke ujung kanan (lebih tinggi 70 pixel)
    path.lineTo(size.width, 0); // Tarik garis lurus ke atas kanan
    path.close(); // Tutup jalur kembali ke titik awal (kiri atas)
=======
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
    return path;
  }
  @override
<<<<<<< HEAD
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ==========================================
// KELAS PEMBANTU: PENGGAMBAR GARIS HITAM
// ==========================================
class GarisMiringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111) // Warna hitam garis
      ..strokeWidth = 6.0 // Ketebalan garis
      ..style = PaintingStyle.stroke; // Mode menggambar outline/garis tepi

    final path = Path();
    // Koordinat titik awal dan akhirnya SAMA PERSIS dengan Clipper di atas
    // Agar garisnya nempel sempurna di ujung potongan gambar
    path.moveTo(0, size.height); 
    path.lineTo(size.width, size.height - 70); 

    // Perintahkan canvas untuk menggambar garisnya
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
=======
  bool shouldReclip(oldClipper) => false;
}

class GarisMiringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF111111)..strokeWidth = 7.0..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height - 60);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(oldDelegate) => false;
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
}