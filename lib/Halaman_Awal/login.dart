import 'package:flutter/material.dart';
import '../Core/Colour.dart'; // Memanggil file warna aplikasi kita
import 'package:shared_preferences/shared_preferences.dart'; // Library buat simpan data ke memori HP
import '../Models/user.dart'; // Mengambil logika login dari class User (OOP)
import '../Widget/custom_text.dart'; // Mengambil komponen teks kustom
import '../Widget/notification_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Box/Remot kontrol untuk membaca apa yang diketik user di kolom input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Saklar buat buka/tutup mata password (false = disensor)
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Menghapus kontroler dari memori kalau halaman ditutup biar HP nggak lemot
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==============================================================
  // TAHAP UTAMA: LOGIKA PROSES LOGIN Saat Tombol Diklik
  // ==============================================================
  Future<void> _handleLogin() async {
    // Ambil teks yang diketik, lalu hapus spasi di ujungnya (trim)
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Cek Apakah Kolomnya Kosong
    if (username.isEmpty || password.isEmpty) {
      NotificationHelper.show(
        context,
        message: 'Nama Pengguna/No. Telp dan Kata Sandi tidak boleh kosong!',
        type: NotificationType.error,
      );
      return; // Stop proses di sini, jangan lanjut ke bawah
    }

    // 2. Kirim Data Ke Server Lewat Model OOP User
    try {
      var hasil = await User.autentikasiOOP(username, password);

      // 3. Cek Hasil Respon dari Server
      if (hasil['status'] == 'sukses') {
        NotificationHelper.show(
          context,
          message: 'Selamat datang kembali, ${hasil['nama'] ?? 'Pengguna'}! 👋',
          type: NotificationType.success,
        );

        // ==============================================================
        // SIMPAN DATA LOGIN KE MEMORI HP (Biar Halaman Checkout Otomatis Diisi)
        // ==============================================================
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        String idUserLoginStr = hasil['id']?.toString() ?? "0";
        String namaUser = hasil['nama']?.toString() ?? ""; 
        String phoneUser = hasil['phone']?.toString() ?? ""; 
        
        if (idUserLoginStr.isNotEmpty && idUserLoginStr != "0") {
          await prefs.setString('id_user', idUserLoginStr); // Simpan ID
          await prefs.setString('nama_user', namaUser);     // Simpan Nama
          await prefs.setString('phone_user', phoneUser);   // Simpan No Telp
          print("Mantap! Data ID, Nama, dan Telp berhasil disimpan ke memori!");
        }

        // ==============================================================
        // NAVIGASI HALAMAN (DIARAHKAN SESUAI STATUS/ROLE-NYA)
        // ==============================================================
        String roleUser = hasil['role'] ?? 'user'; 

        // Kasih jeda 1 detik biar user sempat baca notifikasi suksesnya
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            if (roleUser == 'admin') {
              print("Membuka Halaman Utama Admin...");
              Navigator.pushReplacementNamed(context, '/admin_home');
            } else {
              print("Membuka Halaman Utama Pembeli (Menu)...");
              Navigator.pushReplacementNamed(context, '/menu');
            }
          }
        });

        // Bersihkan kolom inputan setelah sukses login
        _usernameController.clear();
        _passwordController.clear();
        
      } else {
        NotificationHelper.show(
          context,
          message: 'Nama Pengguna atau Kata Sandi salah!',
          type: NotificationType.error,
        );
      }
    } catch (e) {
      // Menangkap error jika XAMPP mati atau laptop putus koneksi internet
      print("Error Server: $e");
      NotificationHelper.show(
        context,
        message: 'Gagal terhubung ke server! Cek koneksi Anda.',
        type: NotificationType.error,
      );
    }
  }
  
  // ==============================================================
  // DESAIN TAMPILAN LAYAR (UI BUILDER)
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Biar kotak form naik ke atas saat keyboard HP muncul
      backgroundColor: AppColors.bgUtama, 
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Cek ukuran layar (Buat jaga-jaga kalau dibuka di laptop/tablet)
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(isDesktop),     // Tampilkan gambar kue di bagian atas layar
                    const SizedBox(height: 20),
                    _buildForm(contentWidth, isDesktop), // Tampilkan form login (kotak oranye)
                    const SizedBox(height: 80),          
                    _buildFooter(),              // Tampilkan bawah halaman berlogo 'Puddingku'
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
          clipper: HeaderClipper(), // Memotong gambar sesuai bentuk kustom kita
          child: Container(
            width: double.infinity, height: isDesktop ? 230 : 280,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/iya.jpeg'), fit: BoxFit.cover, alignment: Alignment.center),
            ),
          ),
        ),
        CustomPaint(size: Size(double.infinity, isDesktop ? 230 : 280), painter: HeaderPainter()), // Menggambar garis pembatas di bawah gambar
        Positioned(
          left: 10, top: 30,
          child: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 30), onPressed: () => Navigator.pop(context)),
        ),
      ],
    );
  }

  // ==============================================================
  // WIDGET BAGIAN 2: KOTAK FORM LOGIN & TOMBOL-TOMBOL
  // ==============================================================
  Widget _buildForm(double contentWidth, bool isDesktop) {
    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const CustomText(
              'Selamat Datang', 
              isOleo: true, // Mengaktifkan font estetik 'Oleo Script' buat judul utama
              color: AppColors.textDark, 
              fontSize: 38, 
              fontWeight: FontWeight.w900, 
            ),
            const CustomText('Masuk untuk mulai memesan', color: AppColors.textDark, fontSize: 18),
            const SizedBox(height: 30),

            // Kotak besar berwarna oranye-coklat
            Container(
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.primary, 
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Nama Pengguna/No. Telp', 'Ketik Disini', Icons.person, _usernameController),
                  _buildInputField('Kata sandi', '******', Icons.lock, _passwordController, isPassword: true),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/lupa-password'),
                    child: const CustomText('Lupa kata sandi?', color: AppColors.textWhite, fontSize: 14, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Baris Tombol Utama (LOGIN dan REGISTER)
            Wrap(
              spacing: 20, runSpacing: 15, alignment: WrapAlignment.center,
              children: [
                // Tombol LOGIN
                SizedBox(
                  width: isDesktop ? 300 : double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                    onPressed: _handleLogin, // Menjalankan fungsi cek login saat ditekan
                    child: const CustomText('MASUK', color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20), 
                  ),
                ),
                // Tombol REGISTER
                SizedBox(
                  width: isDesktop ? 300 : double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Tutup snackbar dulu biar bersih
                      Navigator.pushNamed(context, '/register'); // Pindah ke halaman daftar akun baru
                    },
                    child: const CustomText('REGISTER', color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20), 
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // WIDGET BAGIAN 3: FOOTER BAWAH (NAMA APLIKASI)
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
  // WIDGET KUSTOM: RUMUS UNTUK MEMBUAT KOLOM INPUT TEXTFIELD
  // ==============================================================
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(label, color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600), 
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(12)), 
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false, // Cek sensor password otomatis
              style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 16, color: AppColors.textDark), 
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primaryDark, size: 24), 
                // Jika tipenya password, tambahkan ikon tombol mata di sebelah kanan
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(() => _passwordVisible = !_passwordVisible), // Klik buat saklar sensor mata
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