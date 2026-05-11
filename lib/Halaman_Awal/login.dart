import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // Palet 14 Warna Baru
import 'package:shared_preferences/shared_preferences.dart';

// ==============================================================
// IMPORT CLASS MODELS OOP
// ==============================================================
import '../Models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk membaca data yang diketik oleh user
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // State untuk visibilitas password
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Membersihkan memori saat halaman ditutup
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FUNGSI UTAMA: Logika Autentikasi Login (MURNI OOP)
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi Input Kosong
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent, 
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 20, right: 20),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error, // Menggunakan warna merah error baru
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.textWhite, size: 24), 
                SizedBox(width: 12),
                Expanded(
                  child: Text('Username dan Password tidak boleh kosong!', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 2. Eksekusi API melalui Class Model OOP
    try {
      var hasil = await User.autentikasiOOP(username, password);

      // 3. Evaluasi Respon dari Model OOP
      if (hasil['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil['pesan'], style: const TextStyle(fontFamily: 'Signika Negative')), 
            backgroundColor: AppColors.success, // Menggunakan warna hijau sukses baru
            behavior: SnackBarBehavior.floating,
          ),
        );

        // ==============================================================
        // SIMPAN DATA KE MEMORI HP (Untuk Autofill di Checkout)
        // ==============================================================
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        String idUserLoginStr = hasil['id']?.toString() ?? "0";
        String namaUser = hasil['nama']?.toString() ?? ""; 
        String phoneUser = hasil['phone']?.toString() ?? ""; 
        
        if (idUserLoginStr.isNotEmpty && idUserLoginStr != "0") {
          await prefs.setString('id_user', idUserLoginStr);
          await prefs.setString('nama_user', namaUser);   
          await prefs.setString('phone_user', phoneUser); 
          print("Mantap! Data ID, Nama, dan Telp berhasil disimpan ke memori!");
        }

        // ==============================================================
        // --- LOGIKA ROUTING BERDASARKAN HASIL OOP ---
        // ==============================================================
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

        _usernameController.clear();
        _passwordController.clear();
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil['pesan'] ?? 'Login Gagal', style: const TextStyle(fontFamily: 'Signika Negative')), 
            backgroundColor: AppColors.error, 
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error Server: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal terhubung ke server! Cek koneksi / XAMPP.', style: TextStyle(fontFamily: 'Signika Negative')), 
          backgroundColor: AppColors.error, 
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
      resizeToAvoidBottomInset: false, 
      backgroundColor: AppColors.bgUtama, // Menggunakan krem utama
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              SingleChildScrollView(
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
            width: double.infinity, height: isDesktop ? 230 : 280,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/iya.jpeg'), fit: BoxFit.cover, alignment: Alignment.center),
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

  Widget _buildForm(double contentWidth, bool isDesktop) {
    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // =====================================
            // INI DIA PERUBAHAN FONT OLEO SCRIPT NYA
            // =====================================
            const Text(
              'Selamat Datang', 
              style: TextStyle(
                fontFamily: 'Oleo Script', // Pakai font Oleo Script 
                color: AppColors.textDark, 
                fontSize: 38, 
                fontWeight: FontWeight.w900, 
              )
            ),
            const Text('Login Untuk Mulai Memesan', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textDark, fontSize: 18)),
            const SizedBox(height: 30),

            Container(
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.primary, // Menggunakan warna utama oranye coklat
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Username/No Telp', 'Ketik Disini', Icons.person, _usernameController),
                  _buildInputField('Password', '******', Icons.lock, _passwordController, isPassword: true),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/lupa-password'),
                    child: const Text('Lupa password?', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 14, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Wrap(
              spacing: 20, runSpacing: 15, alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: isDesktop ? 300 : double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                    onPressed: _handleLogin,
                    child: const Text('LOGIN', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20)), 
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 300 : double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.pushNamed(context, '/register'); // <-- Ganti ke /register kalau mau pindah ke halaman register
                    },
                    child: const Text('REGISTER', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20)), 
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 65, width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary, // Menggunakan warna utama oranye coklat
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

  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600)), 
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(12)), 
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 16, color: AppColors.textDark), 
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primaryDark, size: 24), 
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

class HeaderClipper extends CustomClipper<Path> {
  @override Path getClip(Size size) { Path path = Path(); path.lineTo(0, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, 0); path.close(); return path; }
  @override bool shouldReclip(oldClipper) => false;
}

class HeaderPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final paint = Paint()..color = AppColors.textBrown..strokeWidth = 7.0..style = PaintingStyle.stroke; final path = Path(); path.moveTo(0, size.height); path.lineTo(size.width, size.height); canvas.drawPath(path, paint); } 
  @override bool shouldRepaint(oldDelegate) => false;
}