import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- TAMBAHAN INI
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; // Import gudang 14 warna kita

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
  bool _isProcessing = false; // Tambahan untuk efek loading tombol
  String currentUserId = ""; // Sesuai session login

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); 
  }

  // FUNGSI PENGISI OTOMATIS BERDASARKAN DATA LOGIN DI MEMORI HP
  Future<void> _loadUserProfile() async {
    try {
      // Buka brankas memori HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Ambil data langsung dari memori tanpa perlu loading ke API XAMPP
        currentUserId = prefs.getString('id_user') ?? "0";
        _namaController.text = prefs.getString('nama_user') ?? ''; 
        _telpController.text = prefs.getString('phone_user') ?? '';
        
        _isLoadingProfile = false;
      });
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

  // ============================================================
  // FUNGSI PROSES PESANAN KE DATABASE & PINDAH HALAMAN
  // ============================================================
 Future<void> _prosesPesanan(List<dynamic> cartItems, int totalHarga) async {
    if (_namaController.text.isEmpty || _telpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi Nama dan Nomor Telepon!", style: TextStyle(fontFamily: 'Signika Negative'))),
      );
      return;
    }

    // TAMBAHAN: Validasi keamanan memastikan ID User tidak kosong/nol
    if (currentUserId.isEmpty || currentUserId == "0") {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesi login tidak valid, silakan login ulang.", style: TextStyle(fontFamily: 'Signika Negative'))),
      );
      return;
    }

    setState(() => _isProcessing = true);
    // ... lanjut panggil API Checkout

    // Memanggil API Checkout
    var response = await ApiService.checkoutPesanan(
      currentUserId, 
      _namaController.text, 
      _telpController.text
    );

    setState(() => _isProcessing = false);

    if (response['status'] == 'sukses') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pesanan Berhasil Dibuat! 🚀", style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)), backgroundColor: AppColors.success), 
      );
      
      // Pindah ke halaman Bukti Pesanan dan bawa SEMUA datanya
      Navigator.pushReplacementNamed(
        context, 
        '/bukti_pemesanan',
        arguments: {
          'kode_resi': response['kode_resi'],
          'nama': _namaController.text,
          'telp': _telpController.text,
          'items': cartItems,
          'total': totalHarga,
        }
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${response['pesan']}", style: const TextStyle(fontFamily: 'Signika Negative')), backgroundColor: AppColors.error), 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menangkap data dari keranjang.dart
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final List<dynamic> cartItems = args?['items'] ?? [];
    final int totalHarga = args?['total'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bgUtama, // Disamakan dengan krem Colour.dart baru
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER COKELAT (UDAH DISAMAIN SAMA KERANJANG)
            // ============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary, // Disamakan dengan oranye coklat Colour.dart
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textWhite,
                      size: 26, // Dibuat polosan tanpa kotak
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Konfirmasi Pesanan',
                        style: TextStyle(
                          fontFamily: 'Oleo Script', // <-- FONT DISAMAKAN DENGAN KERANJANG
                          color: AppColors.textWhite,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 26), // Biar text di tengah seimbang sama icon back
                ],
              ),
            ),

            Expanded(
              child: _isLoadingProfile 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Pesanan",
                      style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 10),

                    // CONTAINER ITEM PESANAN (Dinamis dari Keranjang)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow, // Disamakan dengan bayangan Colour.dart
                            blurRadius: 10,
                            offset: const Offset(0, 4), // Biar bayangannya ke bawah dikit
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
                                style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                              Text(
                                "Rp $totalHarga",
                                style: const TextStyle(
                                  fontFamily: 'Signika Negative',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary, // Oranye warna utama
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
                      style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 10),

                    // TEXTFIELD (OTOMATIS SESUAI DATA REGISTRASI)
                    _buildTextField("Nama Lengkap", Icons.person, AppColors.primary, _namaController),
                    const SizedBox(height: 12),
                    _buildTextField("Nomor Telepon", Icons.phone, AppColors.primary, _telpController),

                    const SizedBox(height: 40),

                    // TOMBOL PESAN SEKARANG (Desain Utuh)
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, // Warna oranye utama
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        // PERUBAHAN: Memanggil _prosesPesanan dan mencegah double click
                        onPressed: _isProcessing ? null : () => _prosesPesanan(cartItems, totalHarga),
                        child: _isProcessing 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2)
                            )
                          : const Text(
                              "Pesan Sekarang",
                              style: TextStyle(
                                fontFamily: 'Signika Negative', // <-- FONT DITAMBAHKAN
                                color: AppColors.textWhite,
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
  // WIDGET HELPER 
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
                style: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
              ),
              Text(
                qty,
                style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 12), // Menggunakan warna abu dari AppColors
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontFamily: 'Signika Negative',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primary, // Warna oranye utama
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, IconData icon, Color iconColor, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 13),
        prefixIcon: Icon(icon, color: iconColor, size: 22),
        fillColor: AppColors.bgCard, // Disamakan dengan warna cream terang di AppColors
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}