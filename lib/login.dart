import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _passwordVisible = false;
  bool _isLoading = false; 

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prosesRegister() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (nama.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _tampilkanPesanError('Semua data register harus diisi!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'nama': nama,
        'email': email,
        'phone': phone,
        'dibuat_pada': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran Berhasil! Silakan Masuk.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String pesanError = 'Terjadi kesalahan!';
      if (e.code == 'weak-password') {
        pesanError = 'Password terlalu lemah (Minimal 6 karakter).';
      } else if (e.code == 'email-already-in-use') {
        pesanError = 'Email ini sudah terdaftar!';
      } else if (e.code == 'invalid-email') {
        pesanError = 'Format email tidak valid!';
      }
      _tampilkanPesanError(pesanError);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _tampilkanPesanError('Gagal mendaftar: $e');
    }
  }

  void _tampilkanPesanError(String pesan) {
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
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pesan,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 280,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/brow.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  size: const Size(double.infinity, 280),
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
            const Text(
              'REGISTER',
              style: TextStyle(color: Color(0xFF270C0C), fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const Text('Register Untuk Membuat Akun'),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFFC9792B),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _buildInputField('Nama Lengkap', 'Ketik Disini', Icons.badge_outlined, _namaController),
                  _buildInputField('Email', 'contoh@gmail.com', Icons.email_outlined, _emailController),
                  _buildInputField('Phone', '0812345678', Icons.phone_outlined, _phoneController),
                  _buildInputField('Password', 'Minimal 6 karakter', Icons.lock_outline, _passwordController, isPassword: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A1F0F)),
                      onPressed: _isLoading ? null : _prosesRegister,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('REGISTER', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF7E6C4), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFFC9792B)),
                suffixIcon: isPassword 
                  ? GestureDetector(
                      onTap: () => setState(() => _passwordVisible = !_passwordVisible),
                      child: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                    )
                  : null,
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(15),
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
    path.lineTo(size.width, size.height - 70);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GarisMiringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF111111)..strokeWidth = 6.0..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height - 70);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}