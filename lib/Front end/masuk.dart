import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // Manggil Gudang Cat kita
import '../Backend/API_Service.dart';

class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  // Buku catatan penangkap ketikan user
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- OTAK UTAMA: PROSES LOGIN ---
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Cek Validasi Kosong
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent, // Transparan karena containernya udah diwarnain
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
              color: AppColors.errorRed, // Pakai dari Colour.dart
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.textWhite, size: 24), // Pakai dari Colour.dart
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Username dan Password tidak boleh kosong!',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600), // Pakai dari Colour.dart
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

    // JARING PENGAMAN: Biar aplikasi gak freeze kalau server mati
    try {
      // 2. Panggil Service Login dari Backend
      var hasil = await ApiService.loginUser(username, password);

      if (hasil['status'] == 'sukses') {
        // Munculkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil['pesan']), 
            backgroundColor: AppColors.successGreen, // Pakai hijau dari Colour.dart
            behavior: SnackBarBehavior.floating,
          ),
        );

        _usernameController.clear();
        _passwordController.clear();
        
        // --- LOGIKA MULTI-ROLE DISINI ---
        String roleUser = hasil['role'] ?? 'user'; 

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            if (roleUser == 'admin') {
              print("Login sebagai Admin");
              Navigator.pushReplacementNamed(context, '/admin_home');
            } else {
              print("Login sebagai User");
              Navigator.pushReplacementNamed(context, '/menu');
            }
          }
        });
      } else {
        // SnackBar Gagal Login (Password salah / User tidak ada)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil['pesan']), 
            backgroundColor: AppColors.errorRed, // Pakai dari Colour.dart
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // JIKA TERJADI ERROR GAIB (Server XAMPP mati / IP salah)
      print("Error Server: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal terhubung ke server! Cek koneksi / XAMPP.'), 
          backgroundColor: AppColors.errorRed, // Pakai dari Colour.dart
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  // --- TAMPILAN LAYAR (UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream, // Pakai dari Colour.dart
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // --- HEADER GAMBAR ---
                    Stack(
                      children: [
                        ClipPath(
                          clipper: HeaderClipper(),
                          child: Container(
                            width: double.infinity,
                            height: isDesktop ? 400 : 280,
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
                            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 30), // Pakai putih dari Colour.dart
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- JUDUL & KOTAK FORM ---
                    Center(
                      child: Container(
                        width: contentWidth,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(
                                color: AppColors.textDark, // Pakai dari Colour.dart
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const Text(
                              'Login untuk mulai memesan',
                              style: TextStyle(color: AppColors.textDark, fontSize: 18), // Pakai dari Colour.dart
                            ),
                            const SizedBox(height: 30),

                            Container(
                              width: isDesktop ? 700 : double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange, // Pakai dari Colour.dart
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputField('Username/No Telp', 'Ketik Disini', Icons.person, _usernameController, isDesktop),
                                  _buildInputField('Password', '******', Icons.lock, _passwordController, isDesktop, isPassword: true),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/lupa-password');
                                    },
                                    child: const Text(
                                      'Lupa password?', 
                                      style: TextStyle(
                                        color: AppColors.textWhite, // Pakai putih dari Colour.dart
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // --- TOMBOL LOGIN & REGISTER ---
                            Wrap(
                              spacing: 20,
                              runSpacing: 15,
                              alignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: isDesktop ? 300 : double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryOrange, // Pakai dari Colour.dart
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 5,
                                    ),
                                    onPressed: _handleLogin,
                                    child: const Text('LOGIN', style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20)), // Pakai putih dari Colour.dart
                                  ),
                                ),
                                SizedBox(
                                  width: isDesktop ? 300 : double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryOrange, // Pakai dari Colour.dart
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 5,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: const Text('REGISTER', style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20)), // Pakai putih dari Colour.dart
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

              // --- FOOTER BAWAH ---
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange, // Pakai dari Colour.dart
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: AppColors.textWhite, shape: BoxShape.circle), // Pakai putih dari Colour.dart
                        child: const Icon(Icons.cake, color: AppColors.primaryOrange, size: 28), // Pakai dari Colour.dart
                      ),
                      const SizedBox(width: 10),
                      const Text('Puddingku', style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)), // Pakai putih dari Colour.dart
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

  // --- TOMBOL MATA ---
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, bool isDesktop, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600)), // Pakai putih dari Colour.dart
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)), // Pakai dari Colour.dart
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.iconOrange, size: 24), // Pakai dari Colour.dart
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(() => _passwordVisible = !_passwordVisible),
                        child: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off, 
                          color: AppColors.textHint, // Pakai warna abu-abu hint dari Colour.dart
                          size: 24
                        ),
                      )
                    : null,
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16), // Pakai warna abu-abu hint dari Colour.dart
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

// --- PEMOTONG GAMBAR HEADER ---
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
//GARIS MIRING
class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.strokeDark..strokeWidth = 7.0..style = PaintingStyle.stroke; // Pakai dari Colour.dart
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height - 60);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(oldDelegate) => false;
}