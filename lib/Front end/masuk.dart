import 'package:flutter/material.dart';
import '../Core/Colour.dart'; 
import '../Backend/API_Service.dart';

class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
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

  // FUNGSI UTAMA: Logika Autentikasi Login
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
              color: AppColors.errorRed, 
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: AppColors.shadowCustom, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.textWhite, size: 24), 
                SizedBox(width: 12),
                Expanded(
                  child: Text('Username dan Password tidak boleh kosong!', style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 2. Eksekusi API dengan Try-Catch untuk menangani Network Error
    try {
      var hasil = await ApiService.loginUser(username, password);

      // 3. Evaluasi Respon dari Server
      if (hasil['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil['pesan']), 
            backgroundColor: AppColors.successGreen, 
            behavior: SnackBarBehavior.floating,
          ),
        );

        _usernameController.clear();
        _passwordController.clear();
        
        // --- LOGIKA MULTI-ROLE (Routing berdasarkan hak akses) ---
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
        // Tampilkan pesan error jika kredensial salah
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil['pesan']), 
            backgroundColor: AppColors.errorRed, 
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Penanganan error jika server XAMPP mati atau IP salah
      print("Error Server: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal terhubung ke server! Cek koneksi / XAMPP.'), 
          backgroundColor: AppColors.errorRed, 
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
      resizeToAvoidBottomInset: false, // Mencegah layout terdorong ke atas saat keyboard aktif
      backgroundColor: AppColors.bgCream, 
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          // Perhatikan bagian ini: Footer udah dimasukin ke dalam Column!
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(isDesktop),             // Memanggil komponen Header Gambar
                    const SizedBox(height: 20),
                    _buildForm(contentWidth, isDesktop), // Memanggil komponen Form Utama
                    const SizedBox(height: 80),          // Jarak antara form dan footer
                    _buildFooter(),                      // <-- FOOTER SEKARANG IKUT KE-SCROLL DI SINI
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

<<<<<<< HEAD
  // --- TOMBOL MATA ---
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, bool isDesktop, {bool isPassword = false}) {
=======
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

  // KOMPONEN 2: Struktur Form Login
  Widget _buildForm(double contentWidth, bool isDesktop) {
    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Text('SELAMAT DATANG', style: TextStyle(color: AppColors.textDark, fontSize: 36, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
            const Text('Login Untuk Mulai Memesan', style: TextStyle(color: AppColors.textDark, fontSize: 18)),
            const SizedBox(height: 30),

            // Container Background Form (Oranye)
            Container(
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange, 
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.shadowCustom, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Username/No Telp', 'Ketik Disini', Icons.person, _usernameController),
                  _buildInputField('Password', '******', Icons.lock, _passwordController, isPassword: true),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/lupa-password'),
                    child: const Text('Lupa password?', style: TextStyle(color: AppColors.textWhite, fontSize: 14, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Login & Register
            Wrap(
              spacing: 20, runSpacing: 15, alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: isDesktop ? 300 : double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                    onPressed: _handleLogin,
                    child: const Text('LOGIN', style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20)), 
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 300 : double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.pushNamed(context, '/login'); // Arahkan ke halaman Register
                    },
                    child: const Text('REGISTER', style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20)), 
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // KOMPONEN 3: Footer Statis Bawah (Lem Super "Positioned" udah dicabut!)
  Widget _buildFooter() {
    return Container(
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

  // WIDGET REUSABLE: Cetakan Input Field
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
>>>>>>> 3f19fe5fead7c791e2f9752b300ec2b121bd537c
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600)), 
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)), 
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.iconOrange, size: 24), 
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(() => _passwordVisible = !_passwordVisible),
                        child: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: AppColors.textHint, size: 24),
                      )
                    : null,
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16), 
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
// --- CLASS DEKORASI BENTUK GARIS HITAM LURUS ---
// ==============================================================

// Class untuk memotong kontainer gambar secara lurus
class HeaderClipper extends CustomClipper<Path> {
  @override Path getClip(Size size) { Path path = Path(); path.lineTo(0, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, 0); path.close(); return path; }
  @override bool shouldReclip(oldClipper) => false;
}
<<<<<<< HEAD
//GARIS MIRING
=======

// Class untuk menggambar garis batas dekoratif pada potongan gambar
>>>>>>> 3f19fe5fead7c791e2f9752b300ec2b121bd537c
class HeaderPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final paint = Paint()..color = AppColors.strokeDark..strokeWidth = 7.0..style = PaintingStyle.stroke; final path = Path(); path.moveTo(0, size.height); path.lineTo(size.width, size.height); canvas.drawPath(path, paint); }
  @override bool shouldRepaint(oldDelegate) => false;
}