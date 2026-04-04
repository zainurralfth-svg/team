import 'package:flutter/material.dart';

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  // Variabel untuk mengontrol apakah kolom password baru muncul
  bool _isPhoneVerified = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _prosesReset() {
    final phone = _phoneController.text.trim();
    final newPass = _newPasswordController.text.trim();

    // Tahap 1: Verifikasi Nomor Telepon
    if (!_isPhoneVerified) {
      if (phone.length < 10) {
        _showError('Masukkan nomor telepon yang benar!');
        return;
      }
      
      // Simulasi pengecekan akun (di sini kita anggap nomor selalu terdaftar)
      setState(() {
        _isPhoneVerified = true;
      });
      return;
    }

    // Tahap 2: Update Password
    if (newPass.isEmpty || newPass.length < 6) {
      _showError('Password baru minimal 6 karakter!');
      return;
    }

    // Simulasi Berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password berhasil diperbarui! Silakan login kembali.')),
    );
    Navigator.pop(context);
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
                            Text(
                              _isPhoneVerified ? 'BUAT PASSWORD BARU' : 'RESET PASSWORD',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF270C0C), fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isPhoneVerified 
                                ? 'Nomor terverifikasi! Masukkan password baru Anda.' 
                                : 'Masukkan nomor telepon yang terdaftar di akun Anda.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF270C0C), fontSize: 16),
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
                                  // INPUT NOMOR TELEPON
                                  _buildInputField(
                                    'Nomor Telepon', 
                                    '08123456xxx', 
                                    Icons.phone_android, 
                                    _phoneController,
                                    enabled: !_isPhoneVerified // Matikan edit jika sudah verified
                                  ),
                                  
                                  // INPUT PASSWORD BARU (Hanya muncul jika nomor sudah OK)
                                  if (_isPhoneVerified) ...[
                                    const SizedBox(height: 20),
                                    _buildInputField(
                                      'Password Baru', 
                                      'Minimal 6 karakter', 
                                      Icons.lock_outline, 
                                      _newPasswordController,
                                      isPassword: true
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 4. TOMBOL RESET
                            SizedBox(
                              width: isDesktop ? 350 : double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5A3114),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                ),
                                onPressed: _prosesReset,
                                child: Text(
                                  _isPhoneVerified ? 'SIMPAN PASSWORD' : 'CEK NOMOR TELEPON', 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
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

  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF7E6C4) : Colors.grey[300], 
            borderRadius: BorderRadius.circular(12)
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: isPassword,
            keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
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

// Clipper & Painter agar serasi
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