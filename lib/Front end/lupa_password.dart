import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../Core/Colour.dart'; // Manggil Gudang Warna
import '../Backend/API_Service.dart'; // Manggil Jembatan ke Database

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  // Buku catatan penangkap ketikan user
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  // Saklar-saklar pengatur tampilan
  bool _isPhoneVerified = false; // Saklar ngecek nomor udah bener atau belum
  bool _obscureText = true;      // Saklar sensor password (titik-titik)
  String? _errorMessage;         // Penyimpan teks pesan error merah

  @override
  void dispose() {
    // Tukang bersih-bersih memori kalau halaman ditutup
    _phoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // --- FUNGSI MUNCULIN PERINGATAN MERAH ---
  void _setAlert(String pesan) {
    setState(() {
      _errorMessage = pesan;
    });
    // Hilang otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  // --- FUNGSI MUNCULIN POP-UP SUKSES ---
  void _showSuccess() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Berhasil!',
      desc: 'Password kamu sudah diperbarui. Silakan login kembali!',
      btnOkText: "Siap, Login!",
      btnOkColor: AppColors.primaryOrange, // Pakai warna Oranye Utama
      btnOkOnPress: () => Navigator.pop(context), // Balik ke halaman login
    ).show();
  }

  // --- OTAK UTAMA: PROSES RESET PASSWORD ---
  Future<void> _prosesReset() async {
    final phone = _phoneController.text.trim();
    final newPass = _newPasswordController.text.trim();

    // TAHAP 1: JIKA NOMOR BELUM DIVERIFIKASI
    if (!_isPhoneVerified) {
      if (phone.isEmpty) {
        _setAlert('Nomor telepon tidak boleh kosong!');
        return;
      }

      // Tanya ke database apakah nomor ini terdaftar?
      var hasil = await ApiService.resetPassword(phone);

      if (hasil['status'] == 'sukses') {
        setState(() {
          _errorMessage = null; 
          _isPhoneVerified = true; // Buka form password baru
        });
      } else {
        _setAlert(hasil['pesan']); // Munculin error dari database
      }
      return;
    }

    // TAHAP 2: JIKA NOMOR UDAH BENER, SIMPAN PASSWORD BARU
    if (newPass.isEmpty) {
      _setAlert('Password baru tidak boleh kosong!');
      return;
    }
    if (newPass.length < 6) {
      _setAlert('Password baru minimal 6 karakter!');
      return;
    }

    // Suruh database ganti password lama jadi password baru
    var hasilUpdate = await ApiService.resetPassword(phone, newPassword: newPass);

    if (hasilUpdate['status'] == 'sukses') {
      _showSuccess(); 
    } else {
      _setAlert(hasilUpdate['pesan']);
    }
  }

  // --- TAMPILAN LAYAR (UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream, // Latar Cream
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? 650 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              // 1. Gambar Puding Hiasan di Belakang
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
                    // 2. HEADER GAMBAR KUE POTONG
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
                            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 3. SPANDUK PESAN ERROR (MUNCUL KALAU ADA ERROR AJA)
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.textWhite),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // 4. JUDUL DAN KOTAK FORM ORANYE
                    Center(
                      child: Container(
                        width: contentWidth,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              _isPhoneVerified ? 'BUAT PASSWORD BARU' : 'RESET PASSWORD',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.strokeDark, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isPhoneVerified 
                                ? 'Nomor terverifikasi! Masukkan password baru Anda.' 
                                : 'Masukkan nomor telepon yang terdaftar di akun Anda.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.strokeDark, fontSize: 16),
                            ),
                            const SizedBox(height: 30),

                            // Kotak Form
                            Container(
                              width: isDesktop ? 700 : double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Panggil cetakan form Nomor HP
                                  _buildInputField(
                                    'Nomor Telepon', 
                                    '08123456xxx', 
                                    Icons.phone_android, 
                                    _phoneController,
                                    enabled: !_isPhoneVerified // Kalau udah verifikasi, form ini dikunci
                                  ),
                                  
                                  // Munculin form password kalau nomor udah bener
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

                            // 5. TOMBOL EKSEKUSI
                            SizedBox(
                              width: isDesktop ? 350 : double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                ),
                                onPressed: _prosesReset, // Jalanin otak utama
                                child: Text(
                                  _isPhoneVerified ? 'SIMPAN PASSWORD' : 'CEK NOMOR TELEPON', 
                                  style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 18)
                                ),
                              ),
                            ),
                            const SizedBox(height: 120), // Jarak aman biar gak ketutup footer
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 6. FOOTER PUDDINGKU
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  ),
                  child: const Center(
                    child: Text('Puddingku Security', style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- PABRIK PENCETAK FORM (Biar gak ngetik ulang kodingan panjang) ---
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            // Kalau form dikunci (enabled = false), warnanya berubah jadi abu-abu
            color: enabled ? AppColors.inputBg : AppColors.inputDisabledBg, 
            borderRadius: BorderRadius.circular(12)
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: isPassword ? _obscureText : false, 
            keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.iconOrange, size: 24),
              suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.iconOrange,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16), // Teks bayangan
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}

// --- RUMUS PEMOTONG GAMBAR HEADER ---
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
    final paint = Paint()..color = AppColors.strokeDark..strokeWidth = 7.0..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height - 60);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(oldDelegate) => false;
}