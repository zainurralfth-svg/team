import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; 
import '../Widget/notification_helper.dart';
import 'package:intl/intl.dart';

// Halaman untuk menampilkan ulang rincian pesanan pembeli sebelum data dikirim ke database.
class KonfirmasiPage extends StatefulWidget {
  const KonfirmasiPage({super.key});

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage> {
  // Kotak pengontrol untuk menampung teks yang diketik oleh pengguna (Nama, Telp, Catatan).
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController(); 
  
  // Variabel untuk mengatur perubahan tampilan di layar.
  bool _isLoadingProfile = true; // Status untuk menampilkan animasi loading saat aplikasi mencari data user.
  bool _isProcessing = false;    // Status untuk mengunci tombol agar pengguna tidak klik berkali-kali (mencegah pesanan dobel).
  String currentUserId = "";     // Tempat menyimpan ID pengguna yang sedang login.

  // Fungsi yang otomatis berjalan pertama kali saat halaman ini dibuka.
  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Memanggil fungsi untuk mencari data profil pengguna.
  }

  // Fungsi untuk mengambil data pengguna (Nama, No HP) yang tersimpan di memori HP.
  Future<void> _loadUserProfile() async {
    try {
      // Membuka memori HP (SharedPreferences) untuk mengambil data login sebelumnya.
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Mengambil data pengguna. Jika datanya kosong, maka diisi dengan nilai bawaan (default).
        currentUserId = prefs.getString('id_user') ?? "0";
        _namaController.text = prefs.getString('nama_user') ?? ''; 
        _telpController.text = prefs.getString('phone_user') ?? '';
        
        // Mematikan animasi loading karena data sudah berhasil ditampilkan ke layar.
        _isLoadingProfile = false;
      });
    } catch (e) {
      // Jika terjadi error saat membaca memori HP, matikan loading agar aplikasi tidak macet.
      setState(() => _isLoadingProfile = false);
    }
  }

  // Fungsi untuk membersihkan memori ketikan saat halaman ditutup agar aplikasi tidak menjadi berat.
  @override
  void dispose() {
    _namaController.dispose();
    _telpController.dispose();
    _catatanController.dispose(); 
    super.dispose();
  }

  // Fungsi format Rupiah
  String formatRupiah(dynamic angka) {
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // ============================================================
  // FUNGSI PROSES PESANAN KE DATABASE & PINDAH HALAMAN
  // ============================================================
  Future<void> _prosesPesanan(List<dynamic> cartItems, int totalHarga) async {
    // 1. Validasi Input
    if (_namaController.text.isEmpty || _telpController.text.isEmpty) {
      NotificationHelper.show(
        context,
        message: "Lengkapi Nama dan Nomor Telepon!",
        type: NotificationType.warning,
      );
      return; // Berhenti di sini, jangan kirim data ke server jika form belum lengkap.
    }

    // Pastikan pengguna benar-benar memiliki ID login yang sah.
    if (currentUserId.isEmpty || currentUserId == "0") {
       NotificationHelper.show(
        context,
        message: "Sesi login tidak valid, silakan login ulang.",
        type: NotificationType.error,
      );
      return;
    }

    // Ubah status tombol menjadi proses (loading) agar tidak bisa diklik lagi.
    setState(() => _isProcessing = true);
    
    // 2. Mengirim Data ke Server (Gunakan Try-Catch agar aplikasi tidak force close jika internet putus)
    try {
      print("Mengirim data ke API Checkout..."); 
      
      // Membawa data pembeli dan catatan untuk dikirim ke server melalui file ApiService.
      var response = await ApiService.checkoutPesanan(
        currentUserId, 
        _namaController.text, 
        _telpController.text,
        _catatanController.text,
      );

      print("Response dari Server: $response"); 

      // Mematikan status proses di tombol karena sudah mendapat balasan dari server.
      setState(() => _isProcessing = false);

      // 3. Mengecek Balasan dari Server
      if (response['status'] == 'sukses') {
        NotificationHelper.show(
          context,
          message: "Pesanan Berhasil Dibuat! 🚀",
          type: NotificationType.success,
        );
        
        // Pindah ke halaman bukti pesanan. 
        // Menggunakan pushReplacementNamed agar halaman konfirmasi ini terhapus dari memori dan pengguna tidak bisa kembali (Back) ke sini.
        Navigator.pushReplacementNamed(
          context, 
          '/bukti_pemesanan',
          arguments: {
            'kode_resi': response['kode_resi'], // Kode unik pesanan dari server.
            'nama': _namaController.text,
            'telp': _telpController.text,
            'catatan': _catatanController.text, 
            'items': cartItems,
            'total': totalHarga,
          }
        );
      } else {
        // Tampilkan pesan gagal jika pesanan ditolak oleh server.
        NotificationHelper.show(
          context,
          message: "Gagal membuat pesanan.",
          type: NotificationType.error,
        );
      }
    } catch (e) {
      // Tangkap pesan error di sini jika tiba-tiba koneksi terputus saat proses pengiriman.
      setState(() => _isProcessing = false);
      print("Error Waktu Checkout: $e"); 
      NotificationHelper.show(
        context,
        message: "Gagal terhubung ke server! Cek koneksi Anda.",
        type: NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menerima data daftar belanjaan dan total harga dari halaman keranjang sebelumnya.
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final List<dynamic> cartItems = args?['items'] ?? []; 
    final int totalHarga = args?['total'] ?? 0;           

    return Scaffold(
      backgroundColor: AppColors.bgUtama, 
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // BAGIAN HEADER (JUDUL HALAMAN DI ATAS)
            // ============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary, 
              ),
              child: Row(
                children: [
                  // Tombol untuk kembali ke halaman sebelumnya.
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textWhite,
                      size: 26, 
                    ),
                  ),
                  // Teks judul halaman.
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Konfirmasi Pesanan',
                        style: TextStyle(
                          fontFamily: 'Signika Negative', // 👈 Diganti biar normal
                          fontWeight: FontWeight.bold,    // 👈 Ditambahin biar tebal & tegas
                          color: AppColors.textWhite,
                          fontSize: 24, // 👈 Disesuaikan ukurannya biar sama persis kayak di keranjang
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 26), // Ruang kosong untuk menjaga teks judul tetap di tengah.
                ],
              ),
            ),

            // ============================================================
            // BAGIAN ISI HALAMAN (BISA DI-SCROLL KE BAWAH)
            // ============================================================
            Expanded(
              // Aturan tampilan: Jika data profil masih dicari, tampilkan loading. Jika selesai, tampilkan form.
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

                    // KOTAK PUTIH: RINGKASAN BARANG YANG DIBELI
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
                          // Menampilkan daftar pesanan secara otomatis ke bawah sesuai jumlah barang yang dibeli.
                          ListView.builder(
                            shrinkWrap: true, // Membatasi tinggi daftar barang agar tidak memakan ruang kosong.
                            physics: const NeverScrollableScrollPhysics(), // Mematikan scroll bawaan agar bisa di-scroll menyatu dengan halaman.
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              // Memanggil rancangan baris pesanan untuk setiap barang.
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildOrderItem(
                                  item['nama_produk'] ?? '',
                                  "${item['jumlah']}x",
                                  formatRupiah(item['harga']),
                                ),
                              );
                            },
                          ),
                          const Divider(thickness: 1, height: 20), // Garis pembatas.
                          
                          // Informasi total uang yang harus dibayarkan.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Pembayaran",
                                style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                              Text(
                                formatRupiah(totalHarga),
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
                    // Ubah teksnya jadi "Informasi Pemesan:" sesuai screenshot terbarumu
                    const Text(
                      "Informasi Pemesan:", 
                      style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 15),

                    // 1. LABEL & TEXTFIELD NAMA LENGKAP
                    const Text(
                      "Nama Lengkap", 
                      style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6), // Jarak tipis antara label dan kotak input
                    _buildTextField("Contoh: Muhammad Arief", Icons.person, AppColors.primary, _namaController),
                    
                    const SizedBox(height: 15), // Jarak agak lebar antar form

                    // 2. LABEL & TEXTFIELD NOMOR TELEPON
                    const Text(
                      "Nomor Telepon", 
                      style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField("Contoh: 081528821611", Icons.phone, AppColors.primary, _telpController),
                    
                    const SizedBox(height: 15),
                    
                    // 3. LABEL & TEXTFIELD CATATAN PELANGGAN
                    const Text(
                      "Catatan pesanan keinginan Pelanggan (Jika ada)", 
                      style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    _buildNotesField("Ketik catatan untuk pesanan kamu di sini...", Icons.edit_note, AppColors.primary, _catatanController),

                    const SizedBox(height: 40),

                    // TOMBOL AKSI: KIRIM PESANAN
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
                        // Aturan klik: Jika aplikasi sedang memproses data, matikan tombol (null) agar tidak diklik dua kali.
                        onPressed: _isProcessing ? null : () => _prosesPesanan(cartItems, totalHarga),
                        // Mengubah tulisan tombol menjadi putaran loading saat pesanan sedang dikirim.
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

  // =========================================================================
  // RANCANGAN WIDGET TAMBAHAN (Agar kodingan utama di atas lebih rapi)
  // =========================================================================
  
  // Rancangan baris untuk menyusun teks nama barang, jumlah, dan harga di nota.
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

  // Rancangan otomatis untuk membuat kotak input standar (Satu baris tulisan).
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  // Rancangan khusus untuk kotak catatan agar bentuk kotaknya lebih tinggi (Muat banyak baris tulisan).
  Widget _buildNotesField(String hint, IconData icon, Color iconColor, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 3, // Mengatur agar kotak menampung maksimal 3 baris tulisan secara vertikal.
      style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 13),
        // Menjaga agar ikon catatan tetap berada di sudut kiri atas kotak.
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 45), 
          child: Icon(icon, color: iconColor, size: 22),
        ),
        fillColor: AppColors.bgCard, 
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}