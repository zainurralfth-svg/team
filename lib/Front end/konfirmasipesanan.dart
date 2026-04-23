import 'package:flutter/material.dart';
import '../Backend/api_service.dart';

class KonfirmasiPage extends StatefulWidget {
  const KonfirmasiPage({super.key});

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage> {
  // Controller asli abang
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  
  bool _isLoadingProfile = true;
  final String currentUserId = "1"; // Sesuai session login

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); 
  }

  // FUNGSI PENGISI OTOMATIS BERDASARKAN REGISTRASI
  Future<void> _loadUserProfile() async {
    try {
      final profil = await ApiService.getProfil(currentUserId);
      if (profil.isNotEmpty && profil['status'] != 'error') {
        setState(() {
          // Mengisi field secara otomatis dari database
          _namaController.text = profil['nama'] ?? ''; 
          _telpController.text = profil['phone'] ?? '';
          _isLoadingProfile = false;
        });
      } else {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _telpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menangkap data dari keranjang.dart
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final List<dynamic> cartItems = args?['items'] ?? [];
    final int totalHarga = args?['total'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2D7A6),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER COKELAT (Sesuai Baris Kode Asli Abang - 100% Utuh)
            // ============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: const BoxDecoration(
                color: Color(0xFFD27F30),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Konfirmasi Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: _isLoadingProfile 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD27F30)))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Pesanan",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    // CONTAINER ITEM PESANAN (Dinamis dari Keranjang)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildOrderItem(
                                  item['nama_produk'] ?? '',
                                  "${item['jumlah']}x",
                                  "Rp ${item['harga']}",
                                ),
                              );
                            },
                          ),
                          const Divider(thickness: 1, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Pembayaran",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Rp $totalHarga",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFFD27F30),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Informasi Pengiriman",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    // TEXTFIELD (OTOMATIS SESUAI DATA REGISTRASI)
                    _buildTextField("Nama Lengkap", Icons.person, const Color(0xFFD27F30), _namaController),
                    const SizedBox(height: 12),
                    _buildTextField("Nomor Telepon", Icons.phone, const Color(0xFFD27F30), _telpController),

                    const SizedBox(height: 40),

                    // TOMBOL PESAN SEKARANG (Desain Utuh)
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD27F30),
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () {
                          if (_namaController.text.isEmpty || _telpController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Lengkapi Nama dan Nomor Telepon!")),
                            );
                            return;
                          }
                          // Lanjut ke Proses Database
                          print("Konfirmasi Pesanan Berhasil");
                        },
                        child: const Text(
                          "Pesan Sekarang",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET HELPER (Sesuai Baris Kode Asli Abang - 100% Utuh)
  // ============================================================
  Widget _buildOrderItem(String title, String qty, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                qty,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFFD27F30),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, IconData icon, Color iconColor, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: iconColor, size: 22),
        fillColor: const Color(0xFFFEF6E8),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30), width: 2),
        ),
      ),
    );
  }
}