import 'package:flutter/material.dart';
import 'menu.dart'; // Pastikan file ini ada dan class-nya bernama MenuPage

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color(0xFFF2D7A6), // Background Beige
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // 1. Header Image dengan Potongan Menyamping/Miring
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  width: double.infinity,
                  height: 320,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/brow.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // 2. GARIS HITAM MIRING (sesuai gambar)
              Positioned(
                left: 0,
                top: 270,
                child: Transform.rotate(
                  angle: -0.15, // Sudut kemiringan
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.2,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Tombol Kembali
              Positioned(
                left: 20,
                top: 50,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // 4. Konten Form (tanpa teks di gambar)
              Padding(
                padding: const EdgeInsets.only(top: 290), 
                child: Column(
                  children: [
                    // Tulisan REGISTER (hitam)
                    const Text(
                      'REGISTER',
                      style: TextStyle(
                        color: Color(0xFF270C0C), 
                        fontSize: 36, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    
                    // Subtitle (hitam)
                    const Text(
                      'Register Untuk Membuat Akun',
                      style: TextStyle(
                        color: Color(0xFF270C0C),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Card Form (Warna Cokelat #C9792B)
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.88,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9792B),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
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
                            // Input Fields
                            _buildInputField('Nama Lengkap', 'Arif Dwi Firmansyah', Icons.badge_outlined),
                            _buildInputField('Username', 'Arif12309', Icons.person_outline),
                            _buildInputField('Phone', '08123456789', Icons.phone_outlined),
                            _buildInputField('Password', '*********', Icons.lock_outline, isPassword: true),
                            
                            const SizedBox(height: 20),
                            
                            // Tombol Register
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A1F0F), // Coklat tua
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                ),
                                onPressed: () {
                                  Navigator.push(
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
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Footer Puddingku
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cake, color: Color(0xFFC9792B), size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'Puddingku',
                          style: TextStyle(
                            color: Color(0xFFC9792B),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk Input Field
  Widget _buildInputField(String label, String hint, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7E6C4),
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
              obscureText: isPassword,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFFC9792B), size: 20),
                suffixIcon: isPassword 
                  ? const Icon(Icons.visibility_off, color: Colors.grey, size: 20)
                  : null,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper untuk membuat potongan gambar miring
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height); 
    path.lineTo(size.width, size.height - 70);
    path.lineTo(size.width, 0); 
    path.close();
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}