import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; // File warna 14 Palet Baru

// IMPORT HALAMAN LAIN UNTUK NAVIGASI
import 'admin.dart'; 
import 'halaman_pengguna.dart';
import 'halaman_riwayat.dart'; 
import 'halaman_profil_admin.dart';
import 'halaman_laporan.dart'; 

// KELAS SUDAH DIGABUNG BIAR GAK MUBASIR KARDUS DALAM KARDUS
class HalamanProduk extends StatefulWidget {
  const HalamanProduk({super.key});
  @override
  State<HalamanProduk> createState() => _HalamanProdukState();
}

class _HalamanProdukState extends State<HalamanProduk> {
  List<Map<String, dynamic>> menuItems = [];
  bool _isLoading = false;

  // ── DAFTAR KATEGORI ──
  final List<String> listKategoriFilter = ['Semua', 'Pudding', 'Dessert', 'Cake', 'Brownies', 'Cookies'];
  final List<String> listKategoriInput = ['Pudding', 'Dessert', 'Cake', 'Brownies', 'Cookies'];
  String kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  // ── FETCH DATA DARI DATABASE (XAMPP) ───────────────────────────────────────
  Future<void> _fetchMenu() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      setState(() {
        menuItems = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _snackbar('Gagal memuat data: $e', AppColors.error); 
    }
  }

  // ── TAMPILAN POP-UP (BOTTOM SHEET) UNTUK TAMBAH PRODUK ────────────────────
  void _bukaSheetTambah() {
    final nameCtrl     = TextEditingController();
    final priceCtrl    = TextEditingController();
    final stokCtrl     = TextEditingController(); 
    final descCtrl     = TextEditingController();
    final formKey      = GlobalKey<FormState>();
    
    String namaFileDipilih = ''; 
    XFile? fileFoto;
    String? selectedKat;

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
                    const Align(alignment: Alignment.centerLeft, child: Text('Tambah Produk', style: TextStyle(fontFamily: 'Signika Negative', fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary))), 
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Nama Produk'),
                            TextFormField(controller: nameCtrl, textCapitalization: TextCapitalization.characters, decoration: _inputDeco('Ketik nama produk...'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),
                            
                            _label('Kategori Produk'),
                            DropdownButtonFormField<String>(
                              value: selectedKat,
                              decoration: _inputDeco('Pilih kategori...'),
                              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 30),
                              items: listKategoriInput.map((String k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)))).toList(),
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

                            _label('Foto Produk'),
                            _buildImagePicker(namaFileDipilih, () async {
                              final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (img != null) setSheetState(() { fileFoto = img; namaFileDipilih = img.name; });
                            }),

                            const SizedBox(height: 30),
                            Row(children: [
                              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Batal', style: TextStyle(fontFamily: 'Signika Negative', color: Colors.grey, fontWeight: FontWeight.w900)))),
                              const SizedBox(width: 12),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;
                                  
                                  String hargaBeres = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                                  String stokBeres = stokCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

                                  Navigator.pop(ctx);
                                  _snackbar('Sedang menyimpan...', AppColors.primary);

                                  final hasil = await ApiService.tambahMenu(
                                    nameCtrl.text.trim().toUpperCase(), 
                                    selectedKat!, 
                                    hargaBeres, 
                                    stokBeres, 
                                    descCtrl.text.trim(), 
                                    fileFoto
                                  );

                                  if (hasil['status'] == 'sukses' || hasil['status'] == 'success') {
                                    _snackbar('Produk berhasil ditambahkan ✓', AppColors.success); 
                                    _fetchMenu();
                                  } else {
                                    _snackbar('Gagal: ${hasil['pesan']}', AppColors.error);
                                  }
                                }, child: const Text('Simpan', style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.w900, fontSize: 16)))),
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

  // ── TAMPILAN POP-UP (BOTTOM SHEET) UNTUK EDIT PRODUK ──────────────────────
  void bukaSHeetEdit(int i) {
    final item         = menuItems[i];
    final nameCtrl     = TextEditingController(text: item['nama_produk']?.toString() ?? '');
    final priceCtrl    = TextEditingController(text: item['harga']?.toString() ?? '');
    final stokCtrl     = TextEditingController(text: item['stok']?.toString() ?? ''); 
    final descCtrl     = TextEditingController(text: item['deskripsi']?.toString() ?? '');
    final formKey      = GlobalKey<FormState>();

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
                    const Align(alignment: Alignment.centerLeft, child: Text('Edit Produk', style: TextStyle(fontFamily: 'Signika Negative', fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary))),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Nama Produk'),
                            TextFormField(controller: nameCtrl, textCapitalization: TextCapitalization.characters, decoration: _inputDeco('Ketik nama produk...'), validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null),
                            const SizedBox(height: 14),
                            
                            _label('Kategori Produk'),
                            DropdownButtonFormField<String>(
                              value: selectedKat,
                              decoration: _inputDeco('Pilih kategori...'),
                              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 30),
                              items: listKategoriInput.map((String k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)))).toList(),
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

                            _label('Foto Produk'),
                            _buildImagePicker(namaFileDipilih, () async {
                              final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (img != null) setSheetState(() { fileFotoUpdate = img; namaFileDipilih = img.name; });
                            }),

                            const SizedBox(height: 30),
                            Row(children: [
                              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Batal', style: TextStyle(fontFamily: 'Signika Negative', color: Colors.grey, fontWeight: FontWeight.w900)))),
                              const SizedBox(width: 12),
                              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;
                                  
                                  String hargaBeres = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                                  String stokBeres = stokCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                                  String idProduk = item['id_produk']?.toString() ?? '';

                                  Navigator.pop(ctx);
                                  _snackbar('Memperbarui produk...', AppColors.primary);

                                  final hasil = await ApiService.editMenu(
                                    idProduk, 
                                    nameCtrl.text.trim().toUpperCase(), 
                                    selectedKat!, 
                                    hargaBeres, 
                                    stokBeres, 
                                    descCtrl.text.trim(), 
                                    fileFotoUpdate
                                  );

                                  if (hasil['status'] == 'sukses' || hasil['status'] == 'success') {
                                    _snackbar('Produk diperbarui ✓', AppColors.success);
                                    _fetchMenu();
                                  } else {
                                    _snackbar('Gagal: ${hasil['pesan']}', AppColors.error);
                                  }
                                }, child: const Text('Simpan', style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.w900, fontSize: 16)))),
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

  // ── DIALOG KONFIRMASI HAPUS PRODUK ────────────────────────────────────────
  void bukaDialogHapus(int i) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.delete_outline, color: AppColors.error), SizedBox(width: 8), Text('Hapus Produk?', style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold))]),
        content: Text('Yakin ingin menghapus\n"${menuItems[i]['nama_produk']}"?', style: const TextStyle(fontFamily: 'Signika Negative')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(fontFamily: 'Signika Negative', color: Colors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
            onPressed: () async {
              final idProduk = menuItems[i]['id_produk']?.toString() ?? '';
              Navigator.pop(ctx);
              final hasil = await ApiService.hapusMenu(idProduk);
              if (hasil['status'] == 'sukses' || hasil['status'] == 'success') {
                _snackbar('Produk dihapus', AppColors.success);
                _fetchMenu();
              } else {
                _snackbar('Gagal: ${hasil['pesan']}', AppColors.error);
              }
            }, child: const Text('Hapus', style: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // ── WIDGET-WIDGET BANTUAN (HELPER) ────────────────────────────────────────
  void _snackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Signika Negative', color: Colors.white)), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textDark)));

  InputDecoration _inputDeco(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint), filled: true, fillColor: AppColors.bgInput, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)));

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
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: const Text('Pilih File', style: TextStyle(fontFamily: 'Signika Negative', fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold))),
              const SizedBox(width: 10),
              Expanded(child: Text(fileName.isNotEmpty ? fileName : 'Belum ada file dipilih', style: TextStyle(fontFamily: 'Signika Negative', fontSize: 12, color: fileName.isNotEmpty ? AppColors.success : Colors.grey, fontWeight: fileName.isNotEmpty ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }

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
            Text(title, style: TextStyle(fontFamily: 'Signika Negative', fontSize: 11, fontWeight: FontWeight.w900, color: textColor)),
          ],
        ),
      ),
    );
  }

  // ── DESAIN HALAMAN UTAMA MANAJEMEN PRODUK ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgUtama, 
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PuddingKu', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('Panel Admin UMKM', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.textBrown, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanProfilAdmin())),
                    child: const CircleAvatar(radius: 20, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/images/profil admin.png')),
                  )
                ],
              ),
            ),
            const Divider(color: Colors.white70, thickness: 1.5, height: 12),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('Manajemen Produk', style: TextStyle(fontFamily: 'Signika Negative', color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)), 
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _bukaSheetTambah, 
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                label: const Text('Tambah Produk', style: TextStyle(fontFamily: 'Signika Negative', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
              ),
            ),
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Daftar Menu', style: TextStyle(fontFamily: 'Signika Negative', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)), 
                  Container(
                    height: 35, padding: const EdgeInsets.symmetric(horizontal: 14), 
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary, width: 2)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: kategoriTerpilih,
                        icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 20),
                        style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                        onChanged: (val) { if (val != null) setState(() => kategoriTerpilih = val); },
                        items: listKategoriFilter.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
      bottomNavigationBar: _buildNewBottomNavigation(context),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final menuTampil = kategoriTerpilih == 'Semua' 
        ? menuItems 
        : menuItems.where((item) => item['kategori']?.toString().toLowerCase() == kategoriTerpilih.toLowerCase()).toList();

    if (menuTampil.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.fastfood_rounded, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        const Text('Belum ada menu', style: TextStyle(fontFamily: 'Signika Negative', color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
      ]));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchMenu,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.75),
        itemCount: menuTampil.length, 
        itemBuilder: (context, index) {
          final item = menuTampil[index];
          final baseUrl = '${ApiService.baseUrl}/uploads/'; 
          return Container(
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: item['gambar'] != null ? Image.network('$baseUrl${item['gambar']}', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,__,___) => const Icon(Icons.fastfood, size: 50)) : const Icon(Icons.fastfood, size: 50))),
                Padding(
                  padding: const EdgeInsets.all(10.0), 
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['nama_produk'].toString().toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textBrown)),
                    Text('Rp ${item['harga']}', style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                    Text('Stok : ${item['stok'] ?? 0} pcs', style: const TextStyle(fontFamily: 'Signika Negative', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
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

  Widget _buildNewBottomNavigation(BuildContext context) {
    return Container(
      height: 75, decoration: const BoxDecoration(color: AppColors.primary),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _navItem(Icons.assignment_outlined, 'Laporan', false, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HalamanLaporan()))),
        _navItem(Icons.cake_outlined, 'Produk', true, () {}),
        _navItem(Icons.home_outlined, 'Beranda', false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()))),
        _navItem(Icons.history, 'Riwayat', false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanRiwayat()))),
        _navItem(Icons.person_outline, 'Pengguna', false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanPengguna()))),
      ]),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isSelected ? AppColors.primaryDark : Colors.transparent, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 30)), 
      Text(label, style: const TextStyle(fontFamily: 'Signika Negative', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    ]));
  }
}