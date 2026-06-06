import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart';
import 'admin.dart'; 
import 'halaman_pengguna.dart';
import 'riwayat_pesanan.dart'; 
import 'halaman_profil_admin.dart';
import 'halaman_laporan.dart';
import '../Widget/custom_admin_navbar.dart';
import '../Widget/custom_text.dart'; // <-- IMPORT COMPONENT CUSTOM TEXT KITA BRO!
import '../Widget/notification_helper.dart';
import 'package:intl/intl.dart';

// Pake StatefulWidget karena halaman ini butuh ngerubah tampilan (refresh data, ganti kategori, loading)
class HalamanProduk extends StatefulWidget {
  const HalamanProduk({super.key});
  @override
  State<HalamanProduk> createState() => _HalamanProdukState();
}

class _HalamanProdukState extends State<HalamanProduk> {
  // 1. TEMPAT NYIMPEN DATA & STATE AWAL
  List<Map<String, dynamic>> menuItems = []; // Wadah buat nyimpen data produk dari database
  bool _isLoading = false; // Indikator muter-muter (loading) pas lagi memuat API

  // Pilihan kategori buat fitur Filter di bagian atas halaman
  final List<String> listKategoriFilter = ['Semua', 'Pudding', 'Dessert', 'Cake', 'Brownies', 'Cookies'];
  final List<String> listKategoriInput = ['Pudding', 'Dessert', 'Cake', 'Brownies', 'Cookies'];
  String kategoriTerpilih = 'Semua'; // Default filter pas halaman pertama dibuka

  String formatRupiah(dynamic angka) {
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // Fungsi yang otomatis jalan pertama kali pas halaman ini dibuka
  @override
  void initState() {
    super.initState();
    _fetchMenu(); // Langsung ambil data produk!
  }

  // 2. FUNGSI AMBIL DATA DARI BACKEND (READ)
  Future<void> _fetchMenu() async {
    setState(() => _isLoading = true); // animasi loading
    try {
      final data = await ApiService.getMenu(); // Nembak API ambil menu
      setState(() {
        // Masukin data dari API ke wadah 'menuItems' trus matiin loading
        menuItems = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _snackbar('Gagal memuat data: $e', AppColors.error); // Munculin notif error kalo gagal
    }
  }

  // 3. FUNGSI MUNCULIN FORM TAMBAH PRODUK (CREATE)
  void _bukaSheetTambah() {
    // Controller ini tugasnya nangkep teks yang diketik admin di kolom input
    final nameCtrl     = TextEditingController();
    final priceCtrl    = TextEditingController();
    final stokCtrl     = TextEditingController(); 
    final descCtrl     = TextEditingController();
    final formKey      = GlobalKey<FormState>(); // Buat validasi form (biar ga boleh kosong)
    
    String namaFileDipilih = ''; 
    XFile? fileFoto; // Wadah buat nyimpen file foto yang dipilih dari galeri
    String? selectedKat;

    // showModalBottomSheet = Munculin layar dari bawah ke atas
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Biar formnya bisa di-scroll kalo layarnya kecil
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder( 
        // StatefulBuilder dipakai biar form di dalam Sheet ini bisa update tampilan (contoh: pas milih foto)
        builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            // Biar formnya gak ketutup keyboard pas admin ngetik
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.85, 
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // Garis abu-abu kecil di atas sheet (pemanis UI)
                    Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                    const Align(alignment: Alignment.centerLeft, child: CustomText('Tambah Produk', fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)), 
                    const SizedBox(height: 20),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KOLOM INPUT NAMA
                            _label('Nama Produk'),
                            TextFormField(controller: nameCtrl, textCapitalization: TextCapitalization.characters, decoration: _inputDeco('Ketik nama produk...'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),
                            
                            // DROPDOWN PILIH KATEGORI
                            _label('Kategori Produk'),
                            DropdownButtonFormField<String>(
                              initialValue: selectedKat,
                              decoration: _inputDeco('Pilih kategori...'),
                              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 30),
                              items: listKategoriInput.map((String k) => DropdownMenuItem(value: k, child: CustomText(k, fontWeight: FontWeight.bold))).toList(),
                              onChanged: (val) => setSheetState(() => selectedKat = val),
                              validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
                            ),
                            const SizedBox(height: 14),
                            
                            // KOLOM INPUT HARGA (Cuma bisa masukin angka)
                            _label('Harga (Rp)'),
                            TextFormField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Contoh: 35000'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),

                            // KOLOM INPUT STOK (Cuma bisa masukin angka)
                            _label('Stok Produk'),
                            TextFormField(controller: stokCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Contoh: 20'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),

                            // KOLOM INPUT DESKRIPSI
                            _label('Deskripsi'),
                            TextFormField(controller: descCtrl, maxLines: 3, decoration: _inputDeco('Ketik deskripsi produk...'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),

                            // TOMBOL PILIH FOTO
                            _label('Foto Produk'),
                            _buildImagePicker(namaFileDipilih, () async {
                              // Buka galeri HP buat milih foto
                              final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                              // Kalo foto udah dipilih, simpan datanya dan ubah teks jadi nama file-nya
                              if (img != null) setSheetState(() { fileFoto = img; namaFileDipilih = img.name; });
                            }),

                            const SizedBox(height: 30),
                            
                            // TOMBOL BATAL & SIMPAN
                            Row(children: [
                              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const CustomText('Batal', color: Colors.grey, fontWeight: FontWeight.w900))),
                              const SizedBox(width: 12),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                                onPressed: () async {
                                  // Kalo form belum diisi lengkap, stop jangan simpan
                                  if (!formKey.currentState!.validate()) return;
                                  
                                  // Bersihin harga & stok dari huruf/simbol aneh, biar masuk ke database murni angka
                                  String hargaBeres = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                                  String stokBeres = stokCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

                                  Navigator.pop(ctx); // Tutup sheet form
                                  _snackbar('Sedang menyimpan...', AppColors.primary);

                                  // Tembak API tambah menu ke PHP
                                  final hasil = await ApiService.tambahMenu(
                                    nameCtrl.text.trim().toUpperCase(), 
                                    selectedKat!, 
                                    hargaBeres, 
                                    stokBeres, 
                                    descCtrl.text.trim(), 
                                    fileFoto
                                  );

                                  // Kalo respon dari PHP sukses, tampilin notif sukses trus refresh datanya
                                  if (hasil['status'] == 'sukses' || hasil['status'] == 'success') {
                                    _snackbar('Produk berhasil ditambahkan ✓', AppColors.success); 
                                    _fetchMenu();
                                  } else {
                                    _snackbar('Gagal menambahkan produk.', AppColors.error);
                                  }
                                }, child: const CustomText('Simpan', fontWeight: FontWeight.w900, fontSize: 16))),
                            ]),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  // 4. FUNGSI MUNCULIN FORM EDIT PRODUK (UPDATE)
  // Logikanya hampir 99% sama kayak Tambah Produk, bedanya kolomnya udah ada isinya otomatis
  void bukaSHeetEdit(int i) {
    final item         = menuItems[i]; // Ambil data produk spesifik yang diklik
    // Controller diisi langsung sama data lama dari database
    final nameCtrl     = TextEditingController(text: item['nama_produk']?.toString() ?? '');
    final priceCtrl    = TextEditingController(text: item['harga']?.toString() ?? '');
    final stokCtrl     = TextEditingController(text: item['stok']?.toString() ?? ''); 
    final descCtrl     = TextEditingController(text: item['deskripsi']?.toString() ?? '');
    final formKey      = GlobalKey<FormState>();

    // Cek apakah produk ini udah punya foto sebelumnya
    String namaFileDipilih = item['gambar']?.toString().isNotEmpty == true ? 'foto_tersimpan.jpg' : '';
    XFile? fileFotoUpdate;
    String? selectedKat = listKategoriInput.contains(item['kategori']) ? item['kategori'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder( 
        builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.85, 
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                    const Align(alignment: Alignment.centerLeft, child: CustomText('Edit Produk', fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // (Kolom Input Sama Kayak Form Tambah di Atas)
                            _label('Nama Produk'),
                            TextFormField(controller: nameCtrl, textCapitalization: TextCapitalization.characters, decoration: _inputDeco('Ketik nama produk...'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),
                            
                            _label('Kategori Produk'),
                            DropdownButtonFormField<String>(
                              initialValue: selectedKat,
                              decoration: _inputDeco('Pilih kategori...'),
                              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 30),
                              items: listKategoriInput.map((String k) => DropdownMenuItem(value: k, child: CustomText(k, fontWeight: FontWeight.bold))).toList(),
                              onChanged: (val) => setSheetState(() => selectedKat = val),
                              validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
                            ),
                            const SizedBox(height: 14),
                            
                            _label('Harga (Rp)'),
                            TextFormField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Contoh: 35000'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),

                            _label('Stok Produk'),
                            TextFormField(controller: stokCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Contoh: 20'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),

                            _label('Deskripsi'),
                            TextFormField(controller: descCtrl, maxLines: 3, decoration: _inputDeco('Ketik deskripsi produk...'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),

                            _label('Foto Produk (Opsional)'), // Kalo edit, foto gak wajib diganti
                            _buildImagePicker(namaFileDipilih, () async {
                              final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (img != null) setSheetState(() { fileFotoUpdate = img; namaFileDipilih = img.name; });
                            }),

                            const SizedBox(height: 30),
                            Row(children: [
                              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const CustomText('Batal', color: Colors.grey, fontWeight: FontWeight.w900))),
                              const SizedBox(width: 12),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;
                                  
                                  String hargaBeres = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                                  String stokBeres = stokCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                                  String idProduk = item['id_produk']?.toString() ?? ''; // Butuh ID buat tau mana yang mau diupdate

                                  Navigator.pop(ctx);
                                  _snackbar('Memperbarui produk...', AppColors.primary);

                                  // Tembak API Edit
                                  final hasil = await ApiService.editMenu(
                                    idProduk, 
                                    nameCtrl.text.trim().toUpperCase(), 
                                    selectedKat!, 
                                    hargaBeres, 
                                    stokBeres, 
                                    descCtrl.text.trim(), 
                                    fileFotoUpdate // Kalau null, API di backend gak bakal nge-replace gambar lama
                                  );

                                  if (hasil['status'] == 'sukses' || hasil['status'] == 'success') {
                                    _snackbar('Produk diperbarui ✓', AppColors.success);
                                    _fetchMenu(); // Refresh biar data baru muncul
                                  } else {
                                    _snackbar('Gagal memperbarui produk.', AppColors.error);
                                  }
                                }, child: const CustomText('Simpan', fontWeight: FontWeight.w900, fontSize: 16))),
                            ]),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  // 5. FUNGSI HAPUS PRODUK (DELETE)
  void bukaDialogHapus(int i) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.delete_outline, color: AppColors.error), SizedBox(width: 8), CustomText('Hapus Produk?', fontWeight: FontWeight.bold)]),
        content: CustomText('Yakin ingin menghapus\n"${menuItems[i]['nama_produk']}"?'), // Nanya konfirmasi ke admin
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const CustomText('Batal', color: Colors.grey)),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
            onPressed: () async {
              final idProduk = menuItems[i]['id_produk']?.toString() ?? '';
              Navigator.pop(ctx); // Tutup dialog
              
              // Tembak API Hapus
              final hasil = await ApiService.hapusMenu(idProduk);
              if (hasil['status'] == 'sukses' || hasil['status'] == 'success') {
                _snackbar('Produk dihapus', AppColors.success);
                _fetchMenu(); // Langsung tarik data terbaru
              } else {
                _snackbar('Gagal menghapus produk.', AppColors.error);
              }
            }, child: const CustomText('Hapus', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET-WIDGET BANTUAN (Biar kodingan rapi)
  // ==========================================
  
  // Buat nampilin notifikasi kecil di bawah layar
  void _snackbar(String msg, Color color) {
    if (!mounted) return;
    NotificationType type = NotificationType.info;
    if (color == AppColors.success) {
      type = NotificationType.success;
    } else if (color == AppColors.error) {
      type = NotificationType.error;
    }
    NotificationHelper.show(context, message: msg, type: type);
  }

  // Buat Label judul di form
  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomText(text, fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textDark));

  // Buat desain kotak textfield biar seragam
  InputDecoration _inputDeco(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint), filled: true, fillColor: AppColors.bgInput, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)));

  // Buat kotak milih gambar (berubah warna kalo udah dipilih)
  Widget _buildImagePicker(String fileName, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: fileName.isNotEmpty ? AppColors.success.withOpacity(0.1) : AppColors.bgInput, borderRadius: BorderRadius.circular(12), border: Border.all(color: fileName.isNotEmpty ? AppColors.success : Colors.grey.shade200)),
          child: Row(
            children: [
              Icon(fileName.isNotEmpty ? Icons.check_circle : Icons.image_outlined, color: fileName.isNotEmpty ? AppColors.success : AppColors.textHint, size: 28),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: const CustomText('Pilih File', fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Expanded(child: CustomText(fileName.isNotEmpty ? fileName : 'Belum ada file dipilih', fontSize: 12, color: fileName.isNotEmpty ? AppColors.success : Colors.grey, fontWeight: fileName.isNotEmpty ? FontWeight.bold : FontWeight.normal, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }

  // Tombol kecil buat aksi Edit/Hapus di dalem kartu produk
  Widget _smallBtn(String title, IconData icon, Color iconColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgInput, 
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            CustomText(title, fontSize: 11, fontWeight: FontWeight.w900, color: textColor),
          ],
        ),
      ),
    );
  }

  // 6. UI UTAMA (KERANGKA HALAMAN)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, 
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER ATAS: Nama Toko & Profil
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText('PuddingKu', color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      SizedBox(height: 2),
                      CustomText('Panel Admin UMKM', color: AppColors.textBrown, fontSize: 12, fontWeight: FontWeight.w600),
                    ],
                  ),
                  // Foto Profil Admin yang bisa diklik
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfilAdmin())),
                    child: Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        image: DecorationImage(image: AssetImage('assets/images/profil admin.png'), fit: BoxFit.cover),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Divider(color: Colors.white70, thickness: 1.5, height: 12),
            
            // TOMBOL TAMBAH PRODUK GEDE
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: CustomText('Manajemen Produk', color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5), 
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _bukaSheetTambah, 
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                label: const CustomText('Tambah Produk', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900), 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
              ),
            ),
            const SizedBox(height: 12),
            
            // BAGIAN FILTER KATEGORI (Dropdown 'Semua', 'Pudding', dll)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomText('Daftar Menu', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary), 
                  Container(
                    height: 35, padding: const EdgeInsets.symmetric(horizontal: 14), 
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary, width: 2)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: kategoriTerpilih,
                        icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 20),
                        style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                        // Kalau kategorinya diganti, layar direfresh (setState) buat nampilin produk yang cocok aja
                        onChanged: (val) { if (val != null) setState(() => kategoriTerpilih = val); },
                        items: listKategoriFilter.map((v) => DropdownMenuItem(value: v, child: CustomText(v))).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // AREA KONTEN DAFTAR PRODUK
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
      
      // NAVBAR BAWAH 
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: 1, // Angka 1 berarti icon 'Produk' lagi nyala
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()));
          if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanPengguna()));
        },
      ),
    );
  }

  // 7. WIDGET MENAMPILKAN PRODUK DALAM BENTUK GRID (KOTAK-KOTAK)
  Widget _buildProductGrid() {
    // Kalau lagi nembak API, munculin muter-muter loading lagi dulu
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    // LOGIKA FILTER: Pisahin produk sesuai kategori yang lagi dipilih
    final menuTampil = kategoriTerpilih == 'Semua' 
        ? menuItems // Kalo 'Semua', tampilin aja isi wadah aslinya
        : menuItems.where((item) => item['kategori']?.toString().toLowerCase() == kategoriTerpilih.toLowerCase()).toList();

    // Kalau setelah difilter ternyata kosong (misal blm ada yg jual 'Cookies')
    if (menuTampil.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.fastfood_rounded, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        const CustomText('Belum ada menu', color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
      ]));
    }

    // RefreshIndicator = Fitur tarik layar ke bawah buat reload data
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchMenu,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        // crossAxisCount: 2 = Dibikin jadi 2 kolom (Kiri-Kanan)
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.75),
        itemCount: menuTampil.length, 
        itemBuilder: (context, index) {
          final item = menuTampil[index];
          // URL dasar buat narik file gambar fisik dari folder 'uploads' di backend PHP
          const baseUrl = '${ApiService.baseUrl}/uploads/'; 
          
          return Container(
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO PRODUK
                Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: item['gambar'] != null ? Image.network('$baseUrl${item['gambar']}', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,_,_) => const Icon(Icons.fastfood, size: 50)) : const Icon(Icons.fastfood, size: 50))),
                
                // INFO PRODUK (Nama, Harga, Stok)
                Padding(
                  padding: const EdgeInsets.all(10.0), 
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CustomText(item['nama_produk'].toString().toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textBrown),
                    CustomText(formatRupiah(item['harga']), fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textDark),
                    CustomText('Stok : ${item['stok'] ?? 0} pcs', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                    const SizedBox(height: 8),
                    
                    // TOMBOL EDIT & HAPUS
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      _smallBtn('Edit', Icons.edit, Colors.green.shade700, AppColors.textBrown, () => bukaSHeetEdit(menuItems.indexOf(item))),
                      _smallBtn('Hapus', Icons.delete, Colors.orange.shade700, AppColors.textBrown, () => bukaDialogHapus(menuItems.indexOf(item))),
                    ]),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}