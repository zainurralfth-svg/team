import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; // Library untuk memunculkan pop-up 
import '../Core/Colour.dart'; // Mengambil palet warna aplikasi Puddingku
import '../Backend/API_Service.dart'; // Menghubungkan ke fungsi reset password di PHP
import '../Widget/custom_text.dart'; // Komponen teks kustom buatan kita

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  // Box/Remot kontrol untuk mencatat apa yang diketik user di kolom HP & Password Baru
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  // untuk kondisi UI aplikasi
  bool _isPhoneVerified = false; // false = baru ketik nomor HP, true = nomor valid & siap buat password baru
  bool _obscureText = true;      // true = password disensor bintik-bintik, false = kelihatan teksnya
  String? _errorMessage;         // Tempat menyimpan pesan error kalau ada yang salah input

  @override
  void dispose() {
    // Hapus semua kontroler dari memori pas halaman ditutup biar HP gak berat
    _phoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // FUNGSI: Buat nampilin banner/notifikasi error merah di atas form (hilang otomatis setelah 3 detik)
  void _setAlert(String pesan) {
    setState(() => _errorMessage = pesan);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  // FUNGSI: Memunculkan pop-up dialog sukses pakai AwesomeDialog
  void _showSuccess() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success, // Ikon centang hijau sukses
      animType: AnimType.bottomSlide, // Animasi muncul meluncur dari bawah
      title: 'Berhasil!',
      desc: 'Password kamu sudah diperbarui. Silakan Masuk kembali!',
      titleTextStyle: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 20),
      descTextStyle: const TextStyle(fontFamily: 'Signika Negative', fontSize: 16),
      btnOkText: "Siap, Masuk!",
      buttonsTextStyle: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: Colors.white),
      btnOkColor: AppColors.primary, // Tombol warna oranye utama
      btnOkOnPress: () => Navigator.pop(context), // Pas diklik OK, otomatis balik ke halaman Login
    ).show();
  }

  // ==============================================================
  // TAHAP UTAMA: LOGIKA PROSES RESET PASSWORD (Langkah Kontrol)
  // ==============================================================
  Future<void> _prosesReset() async {
    final phone = _phoneController.text.trim();
    final newPass = _newPasswordController.text.trim();

    try {
      // --- LANGKAH 1: Cek dulu apakah nomor HP-nya ada di database ---
      if (!_isPhoneVerified) {
        if (phone.isEmpty) return _setAlert('Nomor telepon tidak boleh kosong!');
        
        // Kirim nomor HP ke API PHP untuk dicek kelayakannya
        var hasil = await ApiService.resetPassword(phone);
        if (hasil['status'] == 'sukses') {
          // Jika nomor terdaftar, ubah status jadi true (buka form password baru)
          setState(() { _errorMessage = null; _isPhoneVerified = true; });
        } else {
          _setAlert(hasil['pesan']); // Nomor gak ketemu atau salah
        }
        return; // Stop di sini dulu, nunggu user input password baru
      }

      // --- LANGKAH 2: Validasi dan simpan password baru ke database ---
      if (newPass.isEmpty) return _setAlert('Kata sandi baru tidak boleh kosong!');
      if (newPass.length < 6) return _setAlert('Kata sandi baru minimal 6 karakter!');

      // Kirim data lengkap (Nomor HP + Kata Sandi Baru) ke API PHP untuk disimpan
      var hasilUpdate = await ApiService.resetPassword(phone, newPassword: newPass);
      if (hasilUpdate['status'] == 'sukses') {
        _showSuccess(); //Munculkan dialog sukses ganti password
      } else {
        _setAlert(hasilUpdate['pesan']); // Jika ada error gagal update dari database
      }
    } catch (e) {
      // Penanganan darurat kalau XAMPP mati atau IP laptop berubah mendadak
      _setAlert('Gagal terhubung ke server! Cek koneksi / XAMPP.');
    }
  }

  // ==============================================================
  // DESAIN TAMPILAN LAYAR (UI BUILDER)
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Biar form otomatis naik pas keyboard HP lu muncul
      backgroundColor: AppColors.bgUtama, 
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(), // Scroll anti-mantul lebay pas mentok atas/bawah
                child: Column(
                  children: [
                   _buildHeader(isDesktop),             // Gambar dessert banner atas + tombol back
                    const SizedBox(height: 20),
                    _buildErrorBanner(),                 // Banner merah pemberitahuan error (jika ada)
                    _buildForm(contentWidth, isDesktop), // Kotak form oranye utama
                    const SizedBox(height: 80),
                    _buildFooter(),                     // di bawah halaman berlogo 'Puddingku'
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
  // WIDGET BAGIAN 1: GAMBAR HEADER ATAS
  // ==============================================================
  Widget _buildHeader(bool isDesktop) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderClipper(), // Potong gambar biar rapi
          child: Container(
            width: double.infinity, height: isDesktop ? 230 : 280,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/Dessert Box Banafe.png'), fit: BoxFit.cover)),
          ),
        ),
        CustomPaint(size: Size(double.infinity, isDesktop ? 230 : 280), painter: HeaderPainter()), // Garis dekorasi coklat di bawah gambar
        Positioned(
          left: 10, top: 30,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 30), 
            onPressed: () => Navigator.pop(context) // Klik untuk kembali ke halaman login
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // WIDGET BAGIAN 2: BANNER NOTIFIKASI ERROR (MELAYANG SEMENTARA)
  // ==============================================================
  Widget _buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox(height: 10); // Kalau gak ada error, kasih jarak kecil aja
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error, // Merah galak penanda error
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 5)], 
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.textWhite),
            const SizedBox(width: 12),
            Expanded(child: CustomText(_errorMessage!, color: AppColors.textWhite, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // WIDGET BAGIAN 3: KOTAK FORM DINAMIS (BISA BERUBAH ISI)
  // ==============================================================
  Widget _buildForm(double contentWidth, bool isDesktop) {
    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Judul halaman otomatis berubah teksnya sesuai status saklar _isPhoneVerified
            CustomText(
              _isPhoneVerified ? 'Buat Kata Sandi Baru' : 'Ganti Kata Sandi', 
              isOleo: true, // Pakai font Oleo Script estetik
              textAlign: TextAlign.center, 
              color: AppColors.textDark, 
              fontSize: 38, 
              fontWeight: FontWeight.w900, 
            ),
            const SizedBox(height: 10),
            CustomText(
              _isPhoneVerified ? 'Nomor terverifikasi! Masukkan Kata Sandi Baru Anda.' : 'Masukkan Nomor Telepon Yang Terdaftar Di Akun Anda.', 
              textAlign: TextAlign.center, 
              color: AppColors.textDark, 
              fontSize: 16,
            ),
            const SizedBox(height: 30),

            // Kotak besar oranye pembungkus inputan
            Container(
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.primary, 
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 5))], 
              ),
              child: Column(
                children: [
                  // Kolom Nomor HP: Otomatis terkunci/mati (enabled: false) kalau nomornya sudah terverifikasi sukses
                  _buildInputField('Nomor Telepon', '08123456xxx', Icons.phone_android, _phoneController, enabled: !_isPhoneVerified),
                  
                  // LOGIKA IF SLEEPING: Kolom Password Baru di bawah ini HANYA AKAN MUNCUL kalau nomor HP sukses dicek
                  if (_isPhoneVerified) ...[
                    const SizedBox(height: 20),
                    _buildInputField('Kata Sandi Baru', 'Minimal 6 karakter', Icons.lock_outline, _newPasswordController, isPassword: true),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Utama Eksekutor
            SizedBox(
              width: isDesktop ? 350 : double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                onPressed: _prosesReset, // Menjalankan logika pemicu reset
                // Teks di dalam tombol ikut berubah dinamis mengikuti progress user
                child: CustomText(_isPhoneVerified ? 'SIMPAN KATA SANDI' : 'CEK NOMOR TELEPON', color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // WIDGET BAGIAN 4: FOOTER BAWAH (NAMA APLIKASI)
  // ==============================================================
  Widget _buildFooter() {
    return Container( 
      height: 65, width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary, 
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: AppColors.textWhite, shape: BoxShape.circle),
            child: const Icon(Icons.cake, color: AppColors.primary, size: 28), 
          ),
          const SizedBox(width: 10),
          const CustomText('Puddingku', color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  // ==============================================================
  // WIDGET REUSABLE: CETAKAN KOLOM INPUT FIELD
  // ==============================================================
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label, color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
        const SizedBox(height: 10),
        Container(
          //Warna bg otomatis berubah jadi abu-abu gelap (shade400) kalau kolomnya dikunci (enabled: false) di kondisi nomor HP sudah terverifikasi
          decoration: BoxDecoration(color: enabled ? AppColors.bgInput : Colors.grey.shade400, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller, 
            enabled: enabled, // Mengatur aktif atau matinya kolom ketik
            obscureText: isPassword ? _obscureText : false, // Sembunyikan tulisan kalau ini tipe password
            keyboardType: isPassword ? TextInputType.text : TextInputType.phone, // HP otomatis buka panel angka jika input telepon
            style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 16, color: AppColors.textDark),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryDark, size: 24),
              // Pasang tombol mata intip khusus untuk inputan bertipe password saja
              suffixIcon: isPassword 
                ? IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.primaryDark), onPressed: () => setState(() => _obscureText = !_obscureText))
                : null,
              hintText: hint, 
              hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 16), 
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
// KELAS PEMBANTU: UNTUK MENGGUNTING & MENGGAMBAR GARIS HEADER
// ==============================================================
class HeaderClipper extends CustomClipper<Path> {
  @override Path getClip(Size size) { Path path = Path(); path.lineTo(0, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, 0); path.close(); return path; }
  @override bool shouldReclip(oldClipper) => false;
}

class HeaderPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final paint = Paint()..color = AppColors.textBrown..strokeWidth = 7.0..style = PaintingStyle.stroke; final path = Path(); path.moveTo(0, size.height); path.lineTo(size.width, size.height); canvas.drawPath(path, paint); }
  @override bool shouldRepaint(oldDelegate) => false;
}