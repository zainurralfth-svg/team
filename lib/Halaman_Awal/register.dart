import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- WAJIB IMPORT INI UNTUK FILTER INPUT ANGKA!
import '../Core/Colour.dart'; // Palet 14 Warna Baru
import '../Backend/API_Service.dart';
import '../Widget/custom_text.dart'; // <-- IMPORT COMPONENT CUSTOM TEXT KITA BRO!
import '../Widget/notification_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk membaca data yang diketik oleh user
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State untuk visibilitas password
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Membersihkan memori saat halaman ditutup
    _namaController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FUNGSI UTAMA: Proses pengiriman data pendaftaran ke server
  Future<void> _prosesRegister() async {
    final nama = _namaController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi Input Kosong
    if (nama.isEmpty || username.isEmpty || phone.isEmpty || password.isEmpty) {
      NotificationHelper.show(
        context,
        message: 'Semua data register harus diisi!',
        type: NotificationType.error,
      );
      return;
    }

    // 1b. Validasi Minimal Karakter Password
    if (password.length < 6) {
      NotificationHelper.show(
        context,
        message: 'Password minimal harus 6 karakter!',
        type: NotificationType.error,
      );
      return;
    }

    // 2. Eksekusi Pengiriman ke API dengan Try-Catch
    try {
      var hasil = await ApiService.registerUser(
        nama,
        username,
        phone,
        password,
      );

      // 3. Menangani Respon dari Server
      if (hasil['status'] == 'sukses') {
        NotificationHelper.show(
          context,
          message: 'Registrasi Berhasil! Silakan Login.',
          type: NotificationType.success,
        );

        // Bersihkan form
        _namaController.clear();
        _usernameController.clear();
        _phoneController.clear();
        _passwordController.clear();

        // Kembali ke halaman Login setelah jeda 1.5 detik
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        // Tampilkan error dari server (misal: Username sudah dipakai)
        NotificationHelper.show(
          context,
          message: 'Registrasi Gagal! Username atau nomor telepon mungkin sudah digunakan.',
          type: NotificationType.error,
        );
      }
    } catch (e) {
      // Penanganan error jika server mati atau IP salah
      NotificationHelper.show(
        context,
        message: 'Gagal terhubung ke server! Cek koneksi Anda.',
        type: NotificationType.error,
      );
    }
  }

  // ==============================================================
  // --- BUILDER UTAMA UI ---
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgUtama,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop
              ? constraints.maxWidth * 0.8
              : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(isDesktop),
                    const SizedBox(height: 20),
                    _buildForm(contentWidth, isDesktop),
                    const SizedBox(height: 80),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==============================================================
  // --- KUMPULAN WIDGET KOMPONEN ---
  // ==============================================================
  Widget _buildHeader(bool isDesktop) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            width: double.infinity,
            height: isDesktop ? 230 : 280,
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
          size: Size(double.infinity, isDesktop ? 230 : 280),
          painter: HeaderPainter(),
        ),
        Positioned(
          left: 10,
          top: 30,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textWhite,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(double contentWidth, bool isDesktop) {
    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const CustomText(
              'Register',
              isOleo: true,
              color: AppColors.textDark,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
            const CustomText(
              'Register Untuk Membuat Akun',
              color: AppColors.textDark,
              fontSize: 18,
            ),
            const SizedBox(height: 30),
            Container(
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    'Nama Lengkap',
                    'Ketik Disini',
                    Icons.badge_outlined,
                    _namaController,
                  ),
                  _buildInputField(
                    'Username',
                    'Arif12309',
                    Icons.person_outline,
                    _usernameController,
                  ),
                  _buildInputField(
                    'Phone',
                    '0812345678',
                    Icons.phone_outlined,
                    _phoneController,
                    isPhone: true,
                  ),
                  _buildInputField(
                    'Password',
                    'Minimal 6 Karakter',
                    Icons.lock_outline,
                    _passwordController,
                    isPassword: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: isDesktop ? 350 : double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: _prosesRegister,
                child: const CustomText(
                  'REGISTER',
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 65,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.textWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cake, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 10),
          const CustomText(
            'Puddingku',
            color: AppColors.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label,
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              keyboardType: isPhone ? TextInputType.number : TextInputType.text,
              inputFormatters: isPhone
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ]
                  : null,
              style: const TextStyle(
                fontFamily: 'Signika Negative',
                fontSize: 16,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        child: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.textHint,
                          size: 24,
                        ),
                      )
                    : null,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Signika Negative',
                  color: AppColors.textHint,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                counterText: '',
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
    path.lineTo(size.width, size.height);
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
    final paint = Paint()
      ..color = AppColors.textBrown
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(oldDelegate) => false;
}