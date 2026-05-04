import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../Core/Colour.dart'; 
import '../Backend/API_Service.dart'; 

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  // Controller untuk membaca teks yang diinput oleh user
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  // Variabel State untuk mengelola kondisi UI
  bool _isPhoneVerified = false; // Status apakah nomor telepon valid
  bool _obscureText = true;      // Status visibilitas teks password (hidden/visible)
  String? _errorMessage;         // Menyimpan teks pesan error untuk ditampilkan

  @override
  void dispose() {
    // Membersihkan controller dari memori saat halaman dihancurkan
    _phoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // FUNGSI: Menampilkan pesan error pada UI
  void _setAlert(String pesan) {
    setState(() => _errorMessage = pesan);
    // Menghapus pesan error secara otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  // FUNGSI: Menampilkan dialog pop-up ketika proses berhasil
  void _showSuccess() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Berhasil!',
      desc: 'Password kamu sudah diperbarui. Silakan login kembali!',
      btnOkText: "Siap, Login!",
      btnOkColor: AppColors.primaryOrange, 
      btnOkOnPress: () => Navigator.pop(context), // Kembali ke halaman sebelumnya (Login)
    ).show();
  }

  // FUNGSI UTAMA: Logika untuk memproses reset password
  Future<void> _prosesReset() async {
    final phone = _phoneController.text.trim();
    final newPass = _newPasswordController.text.trim();

    try {
      // TAHAP 1: Validasi dan pengecekan nomor telepon ke API
      if (!_isPhoneVerified) {
        if (phone.isEmpty) return _setAlert('Nomor telepon tidak boleh kosong!');
        
        var hasil = await ApiService.resetPassword(phone);
        if (hasil['status'] == 'sukses') {
          // Jika nomor valid, ubah state untuk menampilkan form password baru
          setState(() { _errorMessage = null; _isPhoneVerified = true; });
        } else {
          _setAlert(hasil['pesan']); // Tampilkan pesan error dari API
        }
        return;
      }

      // TAHAP 2: Validasi dan penyimpanan password baru ke API
      if (newPass.isEmpty) return _setAlert('Password baru tidak boleh kosong!');
      if (newPass.length < 6) return _setAlert('Password baru minimal 6 karakter!');

      var hasilUpdate = await ApiService.resetPassword(phone, newPassword: newPass);
      if (hasilUpdate['status'] == 'sukses') {
        _showSuccess(); // Jika update berhasil, tampilkan dialog sukses
      } else {
        _setAlert(hasilUpdate['pesan']); // Tampilkan pesan error dari API
      }
    } catch (e) {
      // Penanganan error jika tidak dapat terhubung ke server/XAMPP
      _setAlert('Gagal terhubung ke server! Cek koneksi / XAMPP.');
    }
  }

  // ==============================================================
  // --- BUILDER UTAMA UI ---
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Mencegah layout terdorong ke atas saat keyboard aktif
      backgroundColor: AppColors.bgCream, 
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Konfigurasi ukuran responsif untuk layar Desktop vs Mobile
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? 650 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(isDesktop),             // Memanggil komponen Header
                    _buildErrorBanner(),                 // Memanggil komponen Banner Error
                    _buildForm(contentWidth, isDesktop), // Memanggil komponen Form Utama
                    const SizedBox(height: 120),         // Spacer agar konten tidak tertutup Footer
                    _buildFooter(),                      // 4. Footer SEKARANG IKUT KE-SCROLL DI SINI!
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

  // KOMPONEN 1: Menampilkan gambar header beserta tombol kembali
  Widget _buildHeader(bool isDesktop) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            width: double.infinity, height: isDesktop ? 230 : 280,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/Dessert Box Banafe.png'), fit: BoxFit.cover)),
          ),
        ),
        CustomPaint(size: Size(double.infinity, isDesktop ? 230 : 280), painter: HeaderPainter()),
        Positioned(
          left: 10, top: 30,
          child: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 30), onPressed: () => Navigator.pop(context)),
        ),
      ],
    );
  }

  // KOMPONEN 2: Menampilkan banner notifikasi error jika _errorMessage tidak null
  Widget _buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox(height: 10);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.shadowCustom, blurRadius: 5)], 
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.textWhite),
            const SizedBox(width: 12),
            Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  // KOMPONEN 3: Menampilkan struktur form (Teks, Input Field, dan Tombol)
  Widget _buildForm(double contentWidth, bool isDesktop) {
    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(_isPhoneVerified ? 'BUAT PASSWORD BARU' : 'RESET PASSWORD', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.strokeDark, fontSize: 28, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            Text(_isPhoneVerified ? 'Nomor terverifikasi! Masukkan Password Baru Anda.' : 'Masukkan Nomor Telepon Yang Terdaftar Di Akun Anda.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.strokeDark, fontSize: 16)),
            const SizedBox(height: 30),

            // Container Background Form (Warna Oranye)
            Container(
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.shadowCustom, blurRadius: 10, offset: const Offset(0, 5))], 
              ),
              child: Column(
                children: [
                  _buildInputField('Nomor Telepon', '08123456xxx', Icons.phone_android, _phoneController, enabled: !_isPhoneVerified),
                  if (_isPhoneVerified) ...[
                    const SizedBox(height: 20),
                    _buildInputField('Password Baru', 'Minimal 6 karakter', Icons.lock_outline, _newPasswordController, isPassword: true),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Eksekusi
            SizedBox(
              width: isDesktop ? 350 : double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                onPressed: _prosesReset, 
                child: Text(_isPhoneVerified ? 'SIMPAN PASSWORD' : 'CEK NOMOR TELEPON', style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KOMPONEN 4: Menampilkan Footer Statis di bagian bawah layar
  Widget _buildFooter() {
    return Container( // <--- Positioned dihapus, jadi langsung Container
      height: 65, width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryOrange, 
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: AppColors.textWhite, shape: BoxShape.circle),
            child: const Icon(Icons.cake, color: AppColors.primaryOrange, size: 28), 
          ),
          const SizedBox(width: 10),
          const Text('Puddingku', style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // WIDGET REUSABLE: Cetakan untuk membuat form input text agar kode tidak berulang
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          // Mengubah warna background menjadi abu-abu jika parameter enabled = false
          decoration: BoxDecoration(color: enabled ? AppColors.inputBg : AppColors.inputDisabledBg, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller, 
            enabled: enabled, 
            obscureText: isPassword ? _obscureText : false, // Menyembunyikan teks jika ini form password
            keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.iconOrange, size: 24),
              suffixIcon: isPassword 
                ? IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.iconOrange), onPressed: () => setState(() => _obscureText = !_obscureText))
                : null,
              hintText: hint, 
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16), 
              border: InputBorder.none, 
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}

// ==============================================================
// --- CLASS DEKORASI BENTUK GARIS LURUS HITAM ---
// ==============================================================

// Class untuk memotong kontainer gambar secara lurus
class HeaderClipper extends CustomClipper<Path> {
  @override Path getClip(Size size) { Path path = Path(); path.lineTo(0, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, 0); path.close(); return path; }
  @override bool shouldReclip(oldClipper) => false;
}

// Class untuk menggambar garis batas dekoratif pada potongan gambar
class HeaderPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final paint = Paint()..color = AppColors.strokeDark..strokeWidth = 7.0..style = PaintingStyle.stroke; final path = Path(); path.moveTo(0, size.height); path.lineTo(size.width, size.height); canvas.drawPath(path, paint); }
  @override bool shouldRepaint(oldDelegate) => false;
}