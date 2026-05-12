import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // Palet 14 Warna Baru
import '../Backend/API_Service.dart'; 

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 20, right: 20),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error, // Menggunakan merah error baru
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.textWhite, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Semua data register harus diisi!', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // 2. Eksekusi Pengiriman ke API dengan Try-Catch
    try {
      var hasil = await ApiService.registerUser(nama, username, phone, password); 

      // 3. Menangani Respon dari Server
      if (hasil['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil['pesan'], style: const TextStyle(fontFamily: 'Signika Negative')), 
            backgroundColor: AppColors.success, // Menggunakan hijau sukses baru
            behavior: SnackBarBehavior.floating,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil['pesan'], style: const TextStyle(fontFamily: 'Signika Negative')), 
            backgroundColor: AppColors.error, // Menggunakan merah error baru
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Penanganan error jika server mati atau IP salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal terhubung ke server! Cek koneksi / XAMPP.', style: TextStyle(fontFamily: 'Signika Negative')), 
          backgroundColor: AppColors.error, // Menggunakan merah error baru
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==============================================================
  // --- BUILDER UTAMA UI ---
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tetap true biar form nggak ketutup keyboard
      resizeToAvoidBottomInset: true, 
      backgroundColor: AppColors.bgUtama, 
      
      // SafeArea KITA HAPUS di sini, biar gambar kue full sampai atas jam HP
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              SingleChildScrollView(
                // GANTI INI AJA: Biar pas di-scroll mentok nggak ketarik/mantul
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(isDesktop),             // <-- Aman, nggak dirubah
                    const SizedBox(height: 20),
                    _buildForm(contentWidth, isDesktop), // <-- Aman, nggak dirubah
                    const SizedBox(height: 80),          
                    _buildFooter(),                      // <-- Aman, nggak dirubah
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
  // KOMPONEN 1: Header Gambar Lurus
  Widget _buildHeader(bool isDesktop) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            width: double.infinity, height: isDesktop ? 230 : 280,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/Dessert Box Banafe.png'), fit: BoxFit.cover, alignment: Alignment.center),
            ),
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

  // KOMPONEN 2: Struktur Form dan Judul
  Widget _buildForm(double contentWidth, bool isDesktop) {
    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // =====================================
            // INI PERUBAHAN FONT OLEO SCRIPT NYA
            // =====================================
            const Text(
              'Register', 
              style: TextStyle(
                fontFamily: 'Oleo Script', // Pakai font Oleo Script 
                color: AppColors.textDark, 
                fontSize: 38, 
                fontWeight: FontWeight.w900, 
              )
            ),
            const Text('Register Untuk Membuat Akun', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textDark, fontSize: 18)),
            const SizedBox(height: 30),

            // Container Background Form
            Container(
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.primary, // Menggunakan oranye utama
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Nama Lengkap', 'Ketik Disini', Icons.badge_outlined, _namaController),
                  _buildInputField('Username', 'Arif12309', Icons.person_outline, _usernameController),
                  _buildInputField('Phone', '0812345678', Icons.phone_outlined, _phoneController),
                  _buildInputField('Password', 'Minimal 6 Karakter', Icons.lock_outline, _passwordController, isPassword: true),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Eksekusi
            SizedBox(
              width: isDesktop ? 350 : double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                onPressed: _prosesRegister,
                child: const Text('REGISTER', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KOMPONEN 3: Footer Statis
  Widget _buildFooter() {
    return Container( 
      height: 65, width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary, // Menggunakan oranye utama
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
          const Text('Puddingku', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // WIDGET REUSABLE: Input Field 
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(12)), // Background kolom input
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 16, color: AppColors.textDark), // Teks warna gelap biar terbaca
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primaryDark, size: 24), // Ikon oranye gelap
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(() => _passwordVisible = !_passwordVisible),
                        child: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: AppColors.textHint, size: 24),
                      )
                    : null,
                hintText: hint,
                hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 16),
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

// ==============================================================
// --- CLASS DEKORASI BENTUK ---
// ==============================================================

class HeaderClipper extends CustomClipper<Path> {
  @override Path getClip(Size size) { Path path = Path(); path.lineTo(0, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, 0); path.close(); return path; }
  @override bool shouldReclip(oldClipper) => false;
}

class HeaderPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final paint = Paint()..color = AppColors.textBrown..strokeWidth = 7.0..style = PaintingStyle.stroke; final path = Path(); path.moveTo(0, size.height); path.lineTo(size.width, size.height); canvas.drawPath(path, paint); }
  @override bool shouldRepaint(oldDelegate) => false;
}