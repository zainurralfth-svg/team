import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; 

class KonfirmasiPage extends StatefulWidget {
  const KonfirmasiPage({super.key});

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage> {
  // Controller asli abang
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  
  // TAMBAHAN: Controller untuk Catatan
  final TextEditingController _catatanController = TextEditingController(); 
  
  bool _isLoadingProfile = true;
  bool _isProcessing = false; 
  String currentUserId = ""; 

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); 
  }

  Future<void> _loadUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      setState(() {
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
    _catatanController.dispose(); // TAMBAHAN: Bersihkan memori controller catatan
    super.dispose();
  }

  // ============================================================
  // FUNGSI PROSES PESANAN KE DATABASE & PINDAH HALAMAN
  // ============================================================
 Future<void> _prosesPesanan(List<dynamic> cartItems, int totalHarga) async {
    // 1. Validasi Input
    if (_namaController.text.isEmpty || _telpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi Nama dan Nomor Telepon!", style: TextStyle(fontFamily: 'Signika Negative'))),
      );
      return;
    }

    if (currentUserId.isEmpty || currentUserId == "0") {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesi login tidak valid, silakan login ulang.", style: TextStyle(fontFamily: 'Signika Negative'))),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    // 2. Bungkus pakai Try-Catch biar kalau API error nggak langsung mati
    try {
      print("Mengirim data ke API Checkout..."); // Cek di terminal muncul nggak
      
      var response = await ApiService.checkoutPesanan(
        currentUserId, 
        _namaController.text, 
        _telpController.text,
        _catatanController.text,
      );

      print("Response dari Server: $response"); // Ngecek balasan server sukses/gagal

      setState(() => _isProcessing = false);

      if (response['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan Berhasil Dibuat! 🚀", style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)), backgroundColor: AppColors.success), 
        );
        
        // Pindah ke halaman Bukti Pesanan
        Navigator.pushReplacementNamed(
          context, 
          '/bukti_pemesanan',
          arguments: {
            'kode_resi': response['kode_resi'],
            'nama': _namaController.text,
            'telp': _telpController.text,
            'catatan': _catatanController.text, 
            'items': cartItems,
            'total': totalHarga,
          }
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${response['pesan']}", style: const TextStyle(fontFamily: 'Signika Negative')), backgroundColor: AppColors.error), 
        );
      }
    } catch (e) {
      // 3. Kalau API-nya yang ngadat/error, bakal ketahuan di sini
      setState(() => _isProcessing = false);
      print("Error Waktu Checkout: $e"); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi Kesalahan Server: $e", style: const TextStyle(fontFamily: 'Signika Negative')), backgroundColor: AppColors.error), 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final List<dynamic> cartItems = args?['items'] ?? [];
    final int totalHarga = args?['total'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bgUtama, 
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER COKELAT
            // ============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary, 
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textWhite,
                      size: 26, 
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Konfirmasi Pesanan',
                        style: TextStyle(
                          fontFamily: 'Oleo Script', 
                          color: AppColors.textWhite,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 26), 
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

                    // CONTAINER ITEM PESANAN
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow, 
                            blurRadius: 10,
                            offset: const Offset(0, 4), 
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
                                  color: AppColors.primary, 
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

                    // TEXTFIELD (NAMA, TELP, & CATATAN)
                    _buildTextField("Nama Lengkap", Icons.person, AppColors.primary, _namaController),
                    const SizedBox(height: 12),
                    _buildTextField("Nomor Telepon", Icons.phone, AppColors.primary, _telpController),
                    const SizedBox(height: 12), // Jarak sebelum catatan
                    
                    // TAMBAHAN: Kolom Catatan Pesanan
                    _buildNotesField("Tambahkan Jika Ada Catatan Untuk Pesanan Anda", Icons.edit_note, AppColors.primary, _catatanController),

                    const SizedBox(height: 40),

                    // TOMBOL PESAN SEKARANG
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, 
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
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
                                fontFamily: 'Signika Negative', 
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
                style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 12), 
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
            color: AppColors.primary, 
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
        fillColor: AppColors.bgCard, 
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

  // TAMBAHAN: Widget Helper khusus untuk Catatan biar multiline rapi
  Widget _buildNotesField(String hint, IconData icon, Color iconColor, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 3, // Bikin kotaknya agak lebar ke bawah
      style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 13),
        // Pakai Padding biar iconnya tetep di atas kiri, nggak di tengah-tengah kotak yang gede
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 45), 
          child: Icon(icon, color: iconColor, size: 22),
        ),
        fillColor: AppColors.bgCard, 
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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