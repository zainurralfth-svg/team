import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib diimport untuk membatasi input 
import '../Core/Colour.dart'; // Memanggil file palet warna aplikasi kita
import '../Backend/API_Service.dart'; // Menghubungkan fungsi Register ke file PHP/Database
import '../Widget/custom_text.dart'; // Mengambil komponen teks kustom kita

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Box/Remot kontrol untuk merekam apa yang diketik user di masing-masing kolom input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Saklar buat buka/tutup mata password (false = disensor)
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Menghapus semua kontroler dari memori kalau halaman ditutup biar HP nggak lemot
    _namaController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==============================================================
  // TAHAP UTAMA: LOGIKA PROSES DAFTAR AKUN Saat Tombol Diklik
  // ==============================================================
  Future<void> _prosesRegister() async {
    // Ambil semua teks yang diketik, lalu hapus spasi di ujungnya (trim)
    final nama = _namaController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi: Cek Apakah Ada Kolom yang Dibiarkan Kosong
    if (nama.isEmpty || username.isEmpty || phone.isEmpty || password.isEmpty) {
      // Munculkan notifikasi error melayang di bagian atas layar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 20, right: 20),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error, // Warna merah error
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.textWhite, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: CustomText('Semua data register harus diisi!', color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
      return; // Stop proses di sini, jangan kirim data ke server
    }

    // 1b. Validasi Keamanan: Cek Panjang Karakter Password
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 20, right: 20),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.textWhite, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: CustomText('Kata sandi minimal harus 6 karakter!', color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
      return; // Stop proses di sini
    }

    // 2. Kirim Data ke File PHP Lewat ApiService
    try {
      var hasil = await ApiService.registerUser(nama, username, phone, password);

      // 3. Membaca Respon Hasil Balikan dari Server
      if (hasil['status'] == 'sukses') {
        // Tampilkan snackbar warna hijau tanda berhasil daftar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(hasil['pesan']),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Bersihkan seluruh kolom inputan biar kosong kembali
        _namaController.clear();
        _usernameController.clear();
        _phoneController.clear();
        _passwordController.clear();

        // Kasih jeda 1.5 detik, lalu otomatis balik ke Halaman Login
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        // Jika server menolak (Misal: Username sudah pernah dipakai orang lain)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(hasil['pesan']),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Menangkap error jika laptop lu mati, XAMPP belum aktif, atau salah ketik IP baseUrl
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText('Gagal terhubung ke server! Cek koneksi / XAMPP.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==============================================================
  // DESAIN TAMPILAN LAYAR (UI BUILDER)
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Biar kotak form ikutan naik ke atas pas keyboard HP aktif
      backgroundColor: AppColors.bgUtama,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Deteksi ukuran layar otomatis (Jaga-jaga responsif tablet/laptop)
          bool isDesktop = constraints.maxWidth > 800;
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(), // Biar pas di-scroll mentok nggak mantul goyang lebay
                child: Column(
                  children: [
                    _buildHeader(isDesktop),     // Tampilkan gambar dessert box di atas
                    const SizedBox(height: 20),
                    _buildForm(contentWidth, isDesktop), // Tampilkan form input (kotak oranye)
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
          clipper: HeaderClipper(), // Memotong gambar atas mengikuti pola kustom kita
          child: Container(
            width: double.infinity,
            height: isDesktop ? 230 : 280,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Dessert Box Banafe.png'), // Gambar dessert pudding lu bro
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        CustomPaint(size: Size(double.infinity, isDesktop ? 230 : 280), painter: HeaderPainter()), // Garis dekorasi coklat di bawah gambar
        Positioned(
          left: 10,
          top: 30,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 30),
            onPressed: () => Navigator.pop(context), // Tombol kembali ke halaman login jika diklik
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // WIDGET BAGIAN 2: KOTAK FORM DAFTAR & TOMBOL UTAMA
  // ==============================================================
  Widget _buildForm(double contentWidth, bool isDesktop) {
    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const CustomText(
              'Register',
              isOleo: true, // Pakai font estetik 'Oleo Script' buat judul register
              color: AppColors.textDark,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
            const CustomText('Register Untuk Membuat  Anda', color: AppColors.textDark, fontSize: 18),
            const SizedBox(height: 30),
            
            // Kotak besar berwarna oranye-coklat tempat menampung inputan
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
                  _buildInputField('Nama Lengkap', 'Ketik Disini', Icons.badge_outlined, _namaController),
                  _buildInputField('Nama Pengguna', 'Arif12309', Icons.person_outline, _usernameController),
                  // Input nomor HP diberi tanda saklar khusus 'isPhone: true'
                  _buildInputField('Nomor Telepon', '0812345678', Icons.phone_outlined, _phoneController, isPhone: true),
                  // Input password diberi tanda saklar khusus 'isPassword: true'
                  _buildInputField('Kata Sandi', 'Minimal 6 Karakter', Icons.lock_outline, _passwordController, isPassword: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Tombol Eksekusi Daftar Akun Baru
            SizedBox(
              width: isDesktop ? 350 : double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: _prosesRegister, // Jalankan fungsi validasi & kirim data saat diklik
                child: const CustomText('REGISTER', color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 20),
              ),
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
      height: 65,
      width: double.infinity,
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
  Widget _buildInputField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false, // pendeteksi input password
    bool isPhone = false,    // pendeteksi input nomor HP
  }) {
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
              obscureText: isPassword ? !_passwordVisible : false, // Sembunyikan karakter jika bertipe password
              keyboardType: isPhone ? TextInputType.number : TextInputType.text, // Jika nomor HP, otomatis buka keyboard angka di HP
              inputFormatters: isPhone
                  ? [
                      FilteringTextInputFormatter.digitsOnly, // Blokir semua karakter huruf, hanya izinkan angka murni!
                      LengthLimitingTextInputFormatter(15),  // Batasi panjang nomor HP maksimal 15 angka saja
                    ]
                  : null,
              style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 16, color: AppColors.textDark),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primaryDark, size: 24),
                // Jika tipenya password, pasang tombol ikon mata di sebelah kanan
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(() => _passwordVisible = !_passwordVisible), // Klik buat buka/tutup sensor mata
                        child: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: AppColors.textHint, size: 24),
                      )
                    : null,
                hintText: hint,
                hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                counterText: '', // Menghilangkan teks hitungan angka bawaan TextField bawaan Flutter
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