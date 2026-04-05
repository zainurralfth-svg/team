import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../Core/Colour.dart'; // Panggil Gudang Cat kita

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  bool _isPhoneVerified = false;
  bool _obscureText = true; 
  
  // --- VARIABEL UNTUK NOTIF MERAH ---
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Fungsi buat munculin banner error merah
  void _setAlert(String pesan) {
    setState(() {
      _errorMessage = pesan;
    });
    // Hilangkan otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  // Notifikasi Berhasil (Pop-up AwesomeDialog)
  void _showSuccess() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide, // Gunakan bottomSlide agar aman di semua versi
      title: 'Berhasil!',
      desc: 'Password kamu sudah diperbarui. Silakan login kembali!',
      btnOkText: "Siap, Login!",
      btnOkColor: AppColors.primaryOrange,// Pakai warna dari Colour.dart
      btnOkOnPress: () => Navigator.pop(context),
    ).show();
  }

  void _prosesReset() {
    final phone = _phoneController.text.trim();
    final newPass = _newPasswordController.text.trim();

    // Tahap 1: Cek Nomor Telepon
    if (!_isPhoneVerified) {
      if (phone.isEmpty) {
        _setAlert('Nomor telepon tidak boleh kosong!');
        return;
      }
      if (phone.length < 10) {
        _setAlert('Masukkan nomor telepon yang benar!');
        return;
      }
      setState(() {
        _errorMessage = null; 
        _isPhoneVerified = true;
      });
      return;
    }

    // Tahap 2: Cek Password Baru
    if (newPass.isEmpty) {
      _setAlert('Password baru tidak boleh kosong!');
      return;
    }
    if (newPass.length < 6) {
      _setAlert('Password baru minimal 6 karakter!');
      return;
    }

    // Jika semua OK, panggil notif sukses
    _showSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream, // Pakai warna dari Colour.dart
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? 650 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              // Background Dekoratif (Gambar Puding Kecil)
              Positioned(
                right: -30, top: 360,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset('assets/images/tiga.png', width: 150, errorBuilder: (c, e, s) => const SizedBox()),
                ),
              ),

              SingleChildScrollView(
                child: Column(
                  children: [
                    // --- 1. HEADER IMAGE ---
                    Stack(
                      children: [
                        ClipPath(
                          clipper: HeaderClipper(),
                          child: Container(
                            width: double.infinity,
                            height: isDesktop ? 400 : 280,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/Dessert Box Banafe.png'),
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

                    const SizedBox(height: 10),

                    // --- 2. BANNER ERROR MERAH ---
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed, // Pakai warna dari Colour.dart
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // --- 3. JUDUL DAN FORM ---
                    Center(
                      child: Container(
                        width: contentWidth,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              _isPhoneVerified ? 'BUAT PASSWORD BARU' : 'RESET PASSWORD',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.strokeDark, fontSize: 28, fontWeight: FontWeight.bold), // Pakai warna dari Colour.dart
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isPhoneVerified 
                                ? 'Nomor terverifikasi! Masukkan password baru Anda.' 
                                : 'Masukkan nomor telepon yang terdaftar di akun Anda.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.strokeDark, fontSize: 16), // Pakai warna dari Colour.dart
                            ),
                            const SizedBox(height: 30),

                            // KOTAK COKELAT FORM
                            Container(
                              width: isDesktop ? 700 : double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange, // Pakai warna dari Colour.dart
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildInputField(
                                    'Nomor Telepon', 
                                    '08123456xxx', 
                                    Icons.phone_android, 
                                    _phoneController,
                                    enabled: !_isPhoneVerified
                                  ),
                                  
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

                            // TOMBOL ACTION
                            SizedBox(
                              width: isDesktop ? 350 : double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange, // Disamakan dengan warna gelap tema
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

              // --- 4. FOOTER ---
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange, // Pakai warna dari Colour.dart
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

  // Reusable Widget untuk Input Field
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppColors.inputBg : Colors.grey[300], // Pakai warna dari Colour.dart
            borderRadius: BorderRadius.circular(12)
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: isPassword ? _obscureText : false, 
            keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.iconOrange, size: 24), // Pakai warna dari Colour.dart
              suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.iconOrange, // Pakai warna dari Colour.dart
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 16), // Disederhanakan pakai Colors.grey
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}

// Dekorasi Header
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
    final paint = Paint()..color = AppColors.strokeDark..strokeWidth = 7.0..style = PaintingStyle.stroke; // Pakai warna dari Colour.dart
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height - 60);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(oldDelegate) => false;
}