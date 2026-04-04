import 'package:flutter/material.dart'; // Mengimpor alat-alat utama Flutter untuk membuat tampilan layar.

class MasukPage extends StatefulWidget { // Mendeklarasikan halaman ini agar bisa berubah tampilan/statenya (contoh: buka tutup mata password).
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState(); // Menghubungkan tampilan antarmuka (UI) dengan logika State di bawahnya.
}

class _MasukPageState extends State<MasukPage> {
  final TextEditingController _usernameController = TextEditingController(); // Alat penampung ketikan teks untuk kolom Username.
  final TextEditingController _passwordController = TextEditingController(); // Alat penampung ketikan teks untuk kolom Password.
  bool _passwordVisible = false; // Status awal fitur mata password: false berarti password masih disembunyikan.

  @override
  void dispose() { // Fungsi bawaan yang otomatis jalan saat kita keluar/tutup halaman ini.
    _usernameController.dispose(); // Membuang data controller username dari memori HP supaya aplikasi gak lemot.
    _passwordController.dispose(); // Membuang data controller password dari memori.
    super.dispose();
  }

  void _handleLogin() { // Fungsi yang dipanggil ketika tombol LOGIN ditekan.
    final username = _usernameController.text.trim(); // Mengambil isi username lalu menghapus spasi kosong yang mungkin gak sengaja keketik di awal/akhir kata.
    final password = _passwordController.text.trim(); // Mengambil isi password lalu menghapus spasi kosong.

<<<<<<< HEAD
    if (username.isEmpty || password.isEmpty) { // Pengecekan: Jika kolom username ATAU kolom password kosong, maka...
      ScaffoldMessenger.of(context).showSnackBar( // Munculkan pop-up peringatan hitam di bagian bawah layar.
        const SnackBar(content: Text('Username dan password tidak boleh kosong!')), // Isi teks peringatannya.
=======
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 20,
            right: 20,
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD9534F),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Username dan password tidak boleh kosong!',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
      );
      return; // Berhentikan proses di sini, jangan biarkan user pindah ke halaman selanjutnya.
    }
<<<<<<< HEAD

    // Melanjutkan navigasi ke halaman berikutnya
    Navigator.pushNamed(context, '/login'); // Kalau semua kolom terisi, arahkan user ke rute bernama '/login'.
  }

  @override
  Widget build(BuildContext context) { // Fungsi utama tempat kita menggambar seluruh tampilan UI.
    final screenWidth = MediaQuery.of(context).size.width; // Membaca lebar layar HP user agar desain kita bisa menyesuaikan (responsif).

    return Scaffold( // Kanvas utama untuk satu halaman penuh.
      backgroundColor: const Color(0xFFF2D7A6), // Background warna beige (seperti di screenshot) // Memberi warna krem kecokelatan untuk layar belakang.
      body: Stack( // Menyusun elemen dengan sistem tumpuk-menumpuk (layer bawah ke atas).
        children: [
          // --- BACKGROUND DEKORATIF (GAMBAR ROTI/KUE) ---
          Positioned( // Posisi elemen bisa kita atur manual letaknya.
            right: -30, // Geser posisi gambar ke kanan sampai nembus sedikit dari batas layar.
            top: 360, // Letaknya dari layar paling atas turun sejauh 360 pixel.
            child: Opacity( // Mengatur seberapa tembus pandang elemen di dalamnya.
              opacity: 0.15, // Dibuat 15% saja agar samar-samar dan teks di atasnya tetap terbaca.
              child: Image.asset( // Memanggil gambar dari folder komputer/aset.
                'assets/images/tiga.png',
                width: 150, // Mengunci lebar gambarnya jadi 150 pixel.
                errorBuilder: (context, error, stackTrace) => const SizedBox(), // Kalau gambar gagal dimuat, biarkan kosong aja biar aplikasi nggak error (crash).
              ),
            ),
          ),
          Positioned(
            left: -40, // Geser posisi gambar ke kiri sampai nembus dikit.
            bottom: 80, // Letaknya dihitung dari layar paling bawah sejauh 80 pixel.
            child: Opacity(
              opacity: 0.15, // Dibuat samar-samar juga.
              child: Image.asset(
                'assets/images/tiramisu.png',
                width: 180, // Gambar ini sedikit lebih besar yaitu 180 pixel.
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // --- KONTEN UTAMA (BISA DI-SCROLL) ---
          SingleChildScrollView( // Membungkus konten form agar bisa digeser ke atas-bawah (sangat berguna kalau keyboard muncul menutupi layar).
            child: Padding( // Menambah ruang kosong (padding).
              padding: const EdgeInsets.only(bottom: 80.0), // Memberi jarak agar tidak tertutup bar footer // Bantalan ekstra 80px di bawah biar isi form nggak nyangkut/ketutup bar bawah.
              child: Column( // Menyusun elemen dari atas ke bawah secara berurutan.
                children: [
                  // 1. HEADER GAMBAR MIRING (MENGGUNAKAN iya.jpeg)
                  Stack( // Memakai tumpukan lagi khusus untuk area header gambar dan tombol back.
                    children: [
                      ClipPath( // Widget canggih pemotong bentuk sesuai pola matematika.
                        clipper: HeaderClipper(), // Memanggil rumus pola potongan miring dari class paling bawah.
                        child: Container( // Wadah untuk menempatkan gambar header.
                          width: double.infinity, // Memaksa lebar wadah mentok dari kiri ke kanan layar.
                          height: 300, // Tinggi wadah gambar fix 300 pixel.
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/iya.jpeg'), // Ganti dengan nama gambarmu // Memanggil foto untuk header.
                              fit: BoxFit.cover, // Memaksa foto direntangkan memenuhi seluruh ukuran kotak.
                            ),
                          ),
                        ),
                      ),
                      // GARIS HITAM DI UJUNG POTONGAN
                      CustomPaint( // Alat untuk menggambar langsung di atas layar.
                        size: const Size(double.infinity, 300), // Ukuran area gambarnya disamakan dengan tinggi header (300).
                        painter: HeaderPainter(), // Memanggil rumus pena coretan garis tepi dari class di bawah.
                      ),
                      // TOMBOL KEMBALI
                      Positioned(
                        left: 10, // Jarak dari kiri layar.
                        top: 40, // Jarak dari atas layar (biar gak ketutup status bar/baterai HP).
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), // Menggunakan icon panah mundur warna putih.
                          onPressed: () => Navigator.pop(context), // Perintah aksi untuk "mundur/kembali" ke halaman sebelumnya.
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10), // Membuat jarak (spasi vertikal) selebar 10 pixel ke elemen bawahnya.

                  // 2. TEKS SELAMAT DATANG
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      color: Color(0xFF1A0A0A), // Warna teks hampir hitam gelap.
                      fontSize: 32, // Ukuran huruf sangat besar (judul).
                      fontWeight: FontWeight.w900, // Ketebalan maksimal (bold tebal).
                      fontStyle: FontStyle.italic, // Gaya tulisannya miring.
                      letterSpacing: 1, // Jarak antar hurufnya dilebarkan sedikit.
                    ),
                  ),
                  const SizedBox(height: 5), // Jarak 5 pixel.
                  const Text(
                    'Login untuk mulai memesan',
                    style: TextStyle(
                      color: Color(0xFF1A0A0A), // Teks sub-judul.
                      fontSize: 16, // Ukuran font normal.
                      fontWeight: FontWeight.w500, // Ketebalan font sedang (medium).
                    ),
                  ),
                  const SizedBox(height: 25), // Jarak agak longgar (25 pixel) menuju kotak input.

                  // 3. KOTAK FORM ORANYE KECOKLATAN
                  Center( // Memastikan form input ini berada persis di tengah layar secara horizontal.
                    child: Container(
                      width: screenWidth * 0.85, // Lebar kotak adalah 85% dari total lebar HP user.
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25), // Memberi bantalan/ruang bernafas di dalam kotak.
                      decoration: BoxDecoration(
                        color: const Color(0xFFD27F30), // Sesuai warna di screenshot // Memberi warna utama kotak jadi oranye.
                        borderRadius: BorderRadius.circular(25), // Membuat sudut kotaknya melengkung mulus (radius 25).
                        boxShadow: [ // Membuat efek bayangan agar kotaknya kelihatan pop-up/melayang.
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15), // Warna bayangan hitam tipis transparan.
                            blurRadius: 8, // Efek keburaman bayangan 8 pixel.
                            offset: const Offset(0, 4), // Bayangan digeser ke bawah sedikiiiit (4 pixel).
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Semua isi di dalam form didorong/diratakan ke sebelah kiri.
                        children: [
                          _buildInputField('Username/No Telp', 'Ketik Disini', Icons.person, _usernameController), // Memanggil fungsi pembuat input yang dibikin sendiri di bawah.
                          _buildInputField('Password', '*********', Icons.lock, _passwordController, isPassword: true), // Sama, tapi ini isPassword diset True biar tulisannya jadi bintang/sensor.
                          const SizedBox(height: 5),
                          const Text( // Tulisan link Lupa Password.
                            'Lupa password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13, // Ukuran huruf agak kecil.
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25), // Jarak sebelum menuju tombol.

                  // 4. TOMBOL LOGIN & REGISTER
                  SizedBox(
                    width: screenWidth * 0.6, // Panjang tombol 60% dari layar.
                    height: 50, // Tombol agak gendut/tinggi 50 pixel.
                    child: ElevatedButton( // Tombol yang gaya desainnya ada bayangan (timbul).
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD27F30), // Warna tombol.
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Sudut tombol dibulatkan sedikit.
                        elevation: 3, // Bayangan tombolnya.
                      ),
                      onPressed: _handleLogin, // Aksi Login // Saat diklik, arahkan perintahnya ke fungsi pengecekan 'kosong atau tidak' yang di atas tadi.
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15), // Jarak antar tombol.
                  SizedBox(
                    width: screenWidth * 0.6, // Ukurannya disamakan dengan tombol atas.
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD27F30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      onPressed: () {}, // Aksi Register // Perintahnya masih kosong (belum ada logika saat diklik).
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 5. FOOTER BOTTOM BAR ---
          Positioned( // Memaksa posisi Footer untuk terus diam menempel.
            bottom: 0, // Nempel paling bawah.
            left: 0, // Nempel rata kiri.
            right: 0, // Nempel rata kanan.
            child: Container( // Wadah dari footer.
              height: 60, // Ketinggian footernya 60 pixel.
              decoration: const BoxDecoration(
                color: Color(0xFFD27F30), // Warna sesuai screenshot // Warna oranye disesuaikan.
                borderRadius: BorderRadius.only( // Melengkungkan sudut container...
                  topLeft: Radius.circular(20), // ...HANYA pada ujung kiri atas.
                  topRight: Radius.circular(20), // ...dan ujung kanan atas. Bawahnya tetap rata/siku.
                ),
              ),
              child: Row( // Menyusun elemen logo dan nama secara horizontal (baris).
                mainAxisAlignment: MainAxisAlignment.center, // Keduanya disejajarkan ke tengah-tengah footer.
                children: [
                  Container( // Lingkaran putih tempat menaruh logo kue.
                    padding: const EdgeInsets.all(4), // Jarak putihnya dari ikon kue ke pinggir.
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle, // Memaksa containernya berbentuk bulat sempurna.
                    ),
                    child: const Icon(Icons.cake, color: Color(0xFFD27F30), size: 24), // Logo kue // Ikon kue warna oranye ukuran 24.
                  ),
                  const SizedBox(width: 8), // Jarak kecil memisahkan logo bulat dari teks.
                  const Text(
                    'Puddingku', // Nama tokonya.
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
=======
    _usernameController.clear();
    _passwordController.clear();
    Navigator.pushReplacementNamed(context, '/menu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2D7A6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          
          // Agar Desktop penuh, kita buat lebar content mengikuti lebar layar tapi dengan padding yang pas
          // Jika Desktop, ambil 80% layar. Jika Mobile, ambil 90%.
          double contentWidth = isDesktop ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9;

          return Stack(
            children: [
              // --- KONTEN UTAMA ---
              SingleChildScrollView(
                child: Column(
                  children: [
                    // 1. HEADER GAMBAR (Dibuat Full Width di Desktop)
                    Stack(
                      children: [
                        ClipPath(
                          clipper: HeaderClipper(),
                          child: Container(
                            width: double.infinity, // Paksa lebar penuh layar
                            height: isDesktop ? 400 : 280, // Desktop lebih tinggi
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/iya.jpeg'),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: Size(double.infinity, isDesktop ? 400 : 280),
                          painter: HeaderPainter(),
                        ),
                        Positioned(
                          left: 10, top: 30,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 2. TEKS & FORM (Mengisi Rongga Desktop)
                    Center(
                      child: Container(
                        width: contentWidth, // Lebar yang sudah dihitung agar pas
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(
                                color: Color(0xFF1A0A0A),
                                fontSize: 36, // Ukuran teks judul diperbesar sedikit
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const Text(
                              'Login untuk mulai memesan',
                              style: TextStyle(color: Color(0xFF1A0A0A), fontSize: 18),
                            ),
                            const SizedBox(height: 30),

                            // 3. KOTAK FORM
                            Container(
                              width: isDesktop ? 700 : double.infinity, // Maksimal lebar form di desktop
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD27F30),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputField('Username/No Telp', 'Ketik Disini', Icons.person, _usernameController, isDesktop),
                                  _buildInputField('Password', '*********', Icons.lock, _passwordController, isDesktop, isPassword: true),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/lupa-password');
                                    },
                                    child: const Text(
                                      'Lupa password?', 
                                      style: TextStyle(
                                        color: Colors.white, 
                                        fontSize: 14,
                                        decoration: TextDecoration.underline, // Memberi garis bawah supaya terlihat bisa diklik
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 4. TOMBOL LOGIN & REGISTER
                            Wrap( // Menggunakan Wrap agar di Desktop bisa berdampingan jika ruang cukup
                              spacing: 20,
                              runSpacing: 15,
                              alignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: isDesktop ? 300 : double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD27F30),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 5,
                                    ),
                                    onPressed: _handleLogin,
                                    child: const Text('LOGIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),
                                ),
                                SizedBox(
                                  width: isDesktop ? 300 : double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD27F30),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 5,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: const Text('REGISTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 6. FOOTER (Full Width) ---
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD27F30),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.cake, color: Color(0xFFD27F30), size: 28),
                      ),
                      const SizedBox(width: 10),
                      const Text('Puddingku', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

<<<<<<< HEAD
  // --- WIDGET HELPER UNTUK TEXTFIELD ---
  // Penjelasan: Fungsi buatan sendiri biar codingan kamu nggak kepanjangan (DRY/Don't Repeat Yourself).
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Padding( // Membuat spasi tiap kali kolom input dipanggil.
      padding: const EdgeInsets.only(bottom: 15), // Kasih spasi 15 pixel ke bawah biar gak dempetan dengan input berikutnya.
=======
  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, bool isDesktop, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Meratakan judul/label inputan ke sisi kiri.
        children: [
<<<<<<< HEAD
          Text(
            label, // Memunculkan teks label (cth: "Username/No Telp").
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600, // Tulisan semi-bold.
            ),
          ),
          const SizedBox(height: 6), // Jarak kecil antara label dan kotaknya.
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEBE0C8), // Background Textfield krem // Warna putih krem dalam kotak ketiknya.
              borderRadius: BorderRadius.circular(10), // Kotaknya agak membulat.
            ),
            child: TextField( // Widget area ketik betulan dari Flutter.
              controller: controller, // Menangkap tulisan ketikan.
              obscureText: isPassword ? !_passwordVisible : false, // Logika Password: Jika isPassword TRUE, cek tombol matanya. Kalau sembunyi (true), ubah jadi bintang.
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFFFF9800), size: 20), // Icon sebelum area ketik (sebelah kiri).
                suffixIcon: isPassword // Apakah ini form password?
                    ? GestureDetector( // Jika iya, munculkan ikon mata yang bisa disentuh/klik.
                        onTap: () { // Saat diklik...
                          setState(() { // Refresh halaman...
                            _passwordVisible = !_passwordVisible; // ...ubah nilai benar/salah dari fitur tampilan matanya (toggle).
                          });
                        },
                        child: Icon( // Tampilan ikon sesuai statusnya.
                          _passwordVisible ? Icons.visibility : Icons.visibility_off, // Mata melotot = lihat password. Mata dicoret = sembunyi password.
                          color: Colors.grey,
                          size: 20,
                        ),
                      )
                    : null, // Jika bukan form password, area sebelah kanan ini kosongkan saja (null).
                hintText: hint, // Teks bantuan transparan (cth: "Ketik Disini").
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14), // Warnanya abu-abu.
                border: InputBorder.none, // Mematikan garis luar (outline) jelek bawaan asli TextField.
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15), // Jarak antara tulisan dalam dengan batas sisi kotaknya.
              ),
              style: const TextStyle(color: Colors.black, fontSize: 14), // Tulisan user saat ngetik akan berwarna hitam.
=======
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFEBE0C8), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? !_passwordVisible : false,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFFFF9800), size: 24),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(() => _passwordVisible = !_passwordVisible),
                        child: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 24),
                      )
                    : null,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              ),
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
<<<<<<< HEAD
  Path getClip(Size size) { // Size = tinggi dan lebar area gambarnya.
    Path path = Path(); // Memulai proses pembentukan jalur gunting (path).
    path.lineTo(0, size.height); // Tarik garis ke kiri bawah // Potongan awal lurus dari kiri atas ke ujung kiri paling bawah.
    path.lineTo(size.width, size.height - 50); // Miring ke kanan atas // Gunting menuju ke pojok kanan tapi naik sedikit sejauh 50 pixel (ini yang bikin efek miring).
    path.lineTo(size.width, 0); // Tarik ke kanan atas // Gunting langsung lari ke garis langit pojok kanan atas.
    path.close(); // Tutup path kembali ke kiri atas // Menutup pola potongan kembali ke tempat mulai agar area gambarnya kebentuk utuh.
=======
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 60); // Sudut miring lebih tajam
    path.lineTo(size.width, 0);
    path.close();
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
    return path;
  }
  @override
<<<<<<< HEAD
  bool shouldReclip(CustomClipper<Path> oldClipper) => false; // Efisiensi memori, ngasih tau Flutter "gak usah potong ulang tiap detik, desain ini fix/diam".
=======
  bool shouldReclip(oldClipper) => false;
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
}

class HeaderPainter extends CustomPainter {
  @override
<<<<<<< HEAD
  void paint(Canvas canvas, Size size) { // Kanvas ini ditiban di atas gambar yang udah dipotong.
    final paint = Paint() // Kita seting pulpen kita dulu.
      ..color = const Color(0xFF270C0C) // Warna hitam/cokelat gelap // Warna garis tepi.
      ..strokeWidth = 6.0 // Ketebalan garis hitam // Tebalnya 6 pixel.
      ..style = PaintingStyle.stroke; // Supaya dia ngegambar garis (stroke) aja, bukan memblok area dengan warna.

    final path = Path(); // Pola buat garis.
    // Koordinat harus sama dengan potongan di atas
    path.moveTo(0, size.height); // Taruh titik pulpen mulai di sebelah kiri paling bawah gambar.
    path.lineTo(size.width, size.height - 50); // Tarik garis tebal ke pojok kanan bawah, lalu naikkan 50 pixel. Set, jadi satu garis tepi miring.

    canvas.drawPath(path, paint); // Terapkan tinta garis miring ini ke atas kanvas/layar.
=======
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF270C0C)..strokeWidth = 7.0..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height - 60);
    canvas.drawPath(path, paint);
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
  }
  @override
<<<<<<< HEAD
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Efisiensi, "gak usah digambar ulang kalau halamannya nggak berubah ukurannya."
}


=======
  bool shouldRepaint(oldDelegate) => false;
}
>>>>>>> c53cb26489ec8c3a03738dd21d2c60be4d97f6c1
