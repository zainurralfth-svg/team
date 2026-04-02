import 'package:flutter/material.dart';
import 'menu.dart'; // Pastikan file ini ada dan class-nya bernama MenuPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengambil teks yang diinputkan user (opsional, bisa ditambahkan nanti)
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Variabel state untuk buka-tutup (hide/show) password
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Membersihkan controller dari memori saat halaman ditutup untuk mencegah kebocoran memori (memory leak)
    _namaController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background layar utama (Krem/Beige muda)
      backgroundColor: const Color(0xFFEFE2C8), 
      
      // Menggunakan SingleChildScrollView agar layar bisa di-scroll 
      // ketika keyboard hp muncul, sehingga tidak error "Bottom Overflowed"
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. BAGIAN HEADER (GAMBAR KUE MIRING & GARIS HITAM)
            // ==========================================
            Stack(
              children: [
                // ClipPath bertugas memotong gambar sesuai bentuk yang kita buat di class HeaderClipper
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 320, // Tinggi gambar header
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/brow.jpeg'), // Memanggil gambar iya.jpeg
                        fit: BoxFit.cover, // Memastikan gambar memenuhi kotak
                      ),
                    ),
                  ),
                ),
                
                // CustomPaint ini bertugas MENGGAMBAR GARIS HITAM tebal
                // Tepat di tepi potongan gambar agar terlihat seperti desain aslinya
                CustomPaint(
                  size: const Size(double.infinity, 320),
                  painter: GarisMiringPainter(),
                ),
                
                // Tombol Kembali (Panah Putih di pojok kiri atas)
                Positioned(
                  left: 20,
                  top: 50, // Jarak dari atas layar (aman dari status bar HP)
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context), // Fungsi kembali ke layar sebelumnya
                  ),
                ),
              ],
            ),

            // ==========================================
            // 2. BAGIAN TEKS JUDUL (REGISTER)
            // ==========================================
            // Padding untuk memberi jarak antara gambar atas dan teks judul
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Column(
                children: [
                  const Text(
                    'REGISTER',
                    style: TextStyle(
                      color: Color(0xFF270C0C), // Cokelat sangat gelap / Hitam
                      fontSize: 36, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2, // Jarak antar huruf
                    ),
                  ),
                  const SizedBox(height: 5), // Jarak antara judul dan sub-judul
                  const Text(
                    'Register Untuk Membuat Akun',
                    style: TextStyle(
                      color: Color(0xFF270C0C),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 3. BAGIAN KOTAK FORM (Warna Cokelat/Oranye)
            // ==========================================
            Container(
              width: MediaQuery.of(context).size.width * 0.88, // Lebar kotak 88% dari layar
              padding: const EdgeInsets.all(25), // Jarak ke dalam (ruang bernafas di dalam kotak)
              decoration: BoxDecoration(
                color: const Color(0xFFC9792B), // Warna background kotak form
                borderRadius: BorderRadius.circular(35), // Melengkungkan sudut kotak
                boxShadow: [
                  // Efek bayangan (shadow) di bawah kotak form
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Memanggil Fungsi pembantu _buildInputField yang kita buat di bawah
                  _buildInputField('Nama Lengkap', 'Arif Dwi Firmansyah', Icons.badge_outlined, _namaController),
                  _buildInputField('Username', 'Arif12309', Icons.person_outline, _usernameController),
                  _buildInputField('Phone', '08123456789', Icons.phone_outlined, _phoneController),
                  // Khusus password, kita aktifkan mode 'isPassword: true' agar titik-titik dan ada ikon mata
                  _buildInputField('Password', '*********', Icons.lock_outline, _passwordController, isPassword: true),
                  
                  const SizedBox(height: 20), // Jarak sebelum tombol
                  
                  // Tombol Konfirmasi Register
                  SizedBox(
                    width: double.infinity, // Tombol melebar penuh mengikuti kotak
                    height: 55, // Tinggi tombol
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A1F0F), // Warna tombol cokelat tua
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Melengkungkan tombol
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        // Navigasi ke halaman Menu setelah di-klik
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MenuPage()),
                        );
                      },
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Jarak kosong di bagian paling bawah agar bisa di scroll lega
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET PEMBANTU: UNTUK MEMBUAT KOLOM INPUT
  // ==========================================
  // Dibuat terpisah agar kodenya tidak panjang dan berulang-ulang
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15), // Jarak antar input field
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
        children: [
          // Teks Label (Contoh: "Nama Lengkap")
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5), // Jarak antara label dan kotak input
          
          // Kotak tempat mengetik
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7E6C4), // Warna dasar kotak input (krem muda)
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              // Jika isPassword true, periksa _passwordVisible. Jika false, teks biasa.
              obscureText: isPassword ? !_passwordVisible : false,
              decoration: InputDecoration(
                // Ikon di kiri teks
                prefixIcon: Icon(icon, color: const Color(0xFFC9792B), size: 20),
                
                // Ikon mata di kanan teks (hanya muncul kalau mode password)
                suffixIcon: isPassword 
                  ? GestureDetector(
                      onTap: () {
                        // Mengubah status buka/tutup password saat diklik
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      child: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off, 
                        color: Colors.grey, 
                        size: 20,
                      ),
                    )
                  : null,
                  
                // Teks bayangan (placeholder)
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                border: InputBorder.none, // Menghilangkan garis bawaan TextField
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Padding dalam
              ),
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// KELAS PEMBANTU: ALAT POTONG GAMBAR (CLIPPER)
// ==========================================
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Proses membuat potongan:
    path.lineTo(0, size.height); // Tarik garis lurus dari atas ke kiri bawah
    path.lineTo(size.width, size.height - 70); // Tarik garis MIRING ke ujung kanan (lebih tinggi 70 pixel)
    path.lineTo(size.width, 0); // Tarik garis lurus ke atas kanan
    path.close(); // Tutup jalur kembali ke titik awal (kiri atas)
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ==========================================
// KELAS PEMBANTU: PENGGAMBAR GARIS HITAM
// ==========================================
class GarisMiringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111) // Warna hitam garis
      ..strokeWidth = 6.0 // Ketebalan garis
      ..style = PaintingStyle.stroke; // Mode menggambar outline/garis tepi

    final path = Path();
    // Koordinat titik awal dan akhirnya SAMA PERSIS dengan Clipper di atas
    // Agar garisnya nempel sempurna di ujung potongan gambar
    path.moveTo(0, size.height); 
    path.lineTo(size.width, size.height - 70); 

    // Perintahkan canvas untuk menggambar garisnya
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}