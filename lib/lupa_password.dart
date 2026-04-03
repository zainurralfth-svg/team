import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // MANTRA FIREBASE UNTUK RESET

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final TextEditingController _emailController = TextEditingController(); // Diganti jadi Email
  bool _isLoading = false; // Efek loading

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // FUNGSI UNTUK MENGIRIM LINK RESET KE EMAIL
  Future<void> _prosesReset() async {
    final email = _emailController.text.trim();

    // 1. Cek apakah email kosong
    if (email.isEmpty) {
      _showError('Masukkan email Anda terlebih dahulu!');
      return;
    }

    // 2. Mulai Loading
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. MINTA FIREBASE KIRIM EMAIL RESET
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // 4. Matikan Loading
      setState(() {
        _isLoading = false;
      });

      // 5. Kasih tahu user kalau email sudah dikirim (Warna Hijau)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link reset password telah dikirim! Silakan cek kotak masuk Email Anda.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

      // 6. Kembalikan user ke halaman Login
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String pesanError = 'Terjadi kesalahan!';
      if (e.code == 'user-not-found') {
        pesanError = 'Email ini belum terdaftar di aplikasi!';
      } else if (e.code == 'invalid-email') {
        pesanError = 'Format email tidak valid!';
      }
      
      _showError(pesanError);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Gagal mengirim email: $e');
    }
  }

  void _showError(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20, right: 20,
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFD9534F),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(pesan, style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2D7A6),
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
                    // 1. HEADER (Sesuai Desain Login/Register)
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
                              'LUPA PASSWORD',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF270C0C), fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Masukkan email yang terdaftar. Kami akan mengirimkan link untuk mereset password Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF270C0C), fontSize: 16),
                            ),
                            const SizedBox(height: 30),

                            // 3. KOTAK FORM
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
                                  // INPUT EMAIL
                                  _buildInputField(
                                    'Email', 
                                    'contoh@gmail.com', 
                                    Icons.email_outlined, 
                                    _emailController,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 4. TOMBOL KIRIM RESET
                            SizedBox(
                              width: isDesktop ? 350 : double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5A3114),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                ),
                                onPressed: _isLoading ? null : _prosesReset,
                                child: _isLoading 
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'KIRIM LINK RESET', 
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                                      ),
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 5. FOOTER ---
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD27F30),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  ),
                  child: const Center(
                    child: Text('Puddingku Security', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7E6C4), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress, // Keyboard berubah sesuai format email
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFFF9800), size: 24),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}

// Clipper & Painter
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
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
}