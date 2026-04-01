import 'package:flutter/material.dart';

class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password tidak boleh kosong!')),
      );
      return;
    }

    // Melanjutkan navigasi ke halaman berikutnya
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2D7A6), // Background warna beige (seperti di screenshot)
      body: Stack(
        children: [
          // --- BACKGROUND DEKORATIF (GAMBAR ROTI/KUE) ---
          Positioned(
            right: -30,
            top: 360,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/cookie.png',
                width: 150,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: 80,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/tiramisu.png',
                width: 180,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // --- KONTEN UTAMA (BISA DI-SCROLL) ---
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0), // Memberi jarak agar tidak tertutup bar footer
              child: Column(
                children: [
                  // 1. HEADER GAMBAR MIRING (MENGGUNAKAN iya.jpeg)
                  Stack(
                    children: [
                      ClipPath(
                        clipper: HeaderClipper(),
                        child: Container(
                          width: double.infinity,
                          height: 300,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/iya.jpeg'), // Ganti dengan nama gambarmu
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // GARIS HITAM DI UJUNG POTONGAN
                      CustomPaint(
                        size: const Size(double.infinity, 300),
                        painter: HeaderPainter(),
                      ),
                      // TOMBOL KEMBALI
                      Positioned(
                        left: 10,
                        top: 40,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 2. TEKS SELAMAT DATANG
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      color: Color(0xFF1A0A0A),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Login untuk mulai memesan',
                    style: TextStyle(
                      color: Color(0xFF1A0A0A),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 3. KOTAK FORM ORANYE KECOKLATAN
                  Center(
                    child: Container(
                      width: screenWidth * 0.85,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD27F30), // Sesuai warna di screenshot
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField('Username/No Telp', 'Ketik Disini', Icons.person, _usernameController),
                          _buildInputField('Password', '*********', Icons.lock, _passwordController, isPassword: true),
                          const SizedBox(height: 5),
                          const Text(
                            'Lupa password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 4. TOMBOL LOGIN & REGISTER
                  SizedBox(
                    width: screenWidth * 0.6,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD27F30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      onPressed: _handleLogin, // Aksi Login
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: screenWidth * 0.6,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD27F30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      onPressed: () {}, // Aksi Register
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 5. FOOTER BOTTOM BAR ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFD27F30), // Warna sesuai screenshot
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cake, color: Color(0xFFD27F30), size: 24), // Logo kue
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Puddingku',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK TEXTFIELD ---
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEBE0C8), // Background Textfield krem
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFFFF9800), size: 20),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () {
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
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ALAT PEMOTONG GAMBAR MIRING ---
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height); // Tarik garis ke kiri bawah
    path.lineTo(size.width, size.height - 50); // Miring ke kanan atas
    path.lineTo(size.width, 0); // Tarik ke kanan atas
    path.close(); // Tutup path kembali ke kiri atas
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- PENGGAMBAR GARIS HITAM DI PINGGIRAN POTONGAN ---
class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF270C0C) // Warna hitam/cokelat gelap
      ..strokeWidth = 6.0 // Ketebalan garis hitam
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Koordinat harus sama dengan potongan di atas
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height - 50);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}