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
                    'Username dan password tidak boleh kosong!',
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
    _usernameController.clear();
    _passwordController.clear();
    Navigator.pushReplacementNamed(context, '/menu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2D7A6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          
          // Agar Desktop penuh, kita buat lebar content mengikuti lebar layar tapi dengan padding yang pas
          // Jika Desktop, ambil 80% layar. Jika Mobile, ambil 90%.
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              // --- KONTEN UTAMA ---
              SingleChildScrollView(
                child: Column(
                  children: [
                    // 1. HEADER GAMBAR (Dibuat Full Width di Desktop)
                    Stack(
                      children: [
                        ClipPath(
                          clipper: HeaderClipper(),
                          child: Container(
                            width: double.infinity, // Paksa lebar penuh layar
                            height: isDesktop ? 400 : 280, // Desktop lebih tinggi
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/iya.jpeg'),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: Size(double.infinity, isDesktop ? 400 : 280),
                          painter: HeaderPainter(),
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

                    // 2. TEKS & FORM (Mengisi Rongga Desktop)
                    Center(
                      child: Container(
                        width: contentWidth, // Lebar yang sudah dihitung agar pas
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(
                                color: Color(0xFF1A0A0A),
                                fontSize: 36, // Ukuran teks judul diperbesar sedikit
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const Text(
                              'Login untuk mulai memesan',
                              style: TextStyle(color: Color(0xFF1A0A0A), fontSize: 18),
                            ),
                            const SizedBox(height: 30),

                            // 3. KOTAK FORM
                            Container(
                              width: isDesktop ? 700 : double.infinity, // Maksimal lebar form di desktop
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
                                  _buildInputField('Username/No Telp', 'Ketik Disini', Icons.person, _usernameController, isDesktop),
                                  _buildInputField('Password', '*********', Icons.lock, _passwordController, isDesktop, isPassword: true),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/lupa-password');
                                    },
                                    child: const Text(
                                      'Lupa password?', 
                                      style: TextStyle(
                                        color: Colors.white, 
                                        fontSize: 14,
                                        decoration: TextDecoration.underline, // Memberi garis bawah supaya terlihat bisa diklik
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 4. TOMBOL LOGIN & REGISTER
                            Wrap( // Menggunakan Wrap agar di Desktop bisa berdampingan jika ruang cukup
                              spacing: 20,
                              runSpacing: 15,
                              alignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: isDesktop ? 300 : double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD27F30),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 5,
                                    ),
                                    onPressed: _handleLogin,
                                    child: const Text('LOGIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),
                                ),
                                SizedBox(
                                  width: isDesktop ? 300 : double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD27F30),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 5,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: const Text('REGISTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 6. FOOTER (Full Width) ---
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
      ),
    );
  }

  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, bool isDesktop, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFEBE0C8), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 60); // Sudut miring lebih tajam
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(oldClipper) => false;
}

class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF270C0C)..strokeWidth = 7.0..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height - 60);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(oldDelegate) => false;
}