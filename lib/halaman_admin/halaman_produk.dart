import 'package:flutter/material.dart';
import '../Backend/api_service.dart';
import '../Core/Colour.dart'; // IMPORT GUDANG WARNA

// IMPORT HALAMAN LAIN UNTUK NAVIGASI
import 'admin.dart'; 
import 'halaman_pengguna.dart';
import 'tambah_produk.dart';
import 'halaman_pesanan.dart';
import 'halaman_riwayat.dart'; 
import 'halaman_profil_admin.dart';
import 'halaman_laporan.dart'; 

class HalamanProduk extends StatefulWidget {
  const HalamanProduk({super.key});
  @override
  State<HalamanProduk> createState() => _HalamanProdukState();
}

class _HalamanProdukState extends State<HalamanProduk> {
  @override
  Widget build(BuildContext context) {
    return const ManajemenMenuPage();
  }
}

class ManajemenMenuPage extends StatefulWidget {
  const ManajemenMenuPage({super.key});
  @override
  State<ManajemenMenuPage> createState() => _ManajemenMenuPageState();
}

class _ManajemenMenuPageState extends State<ManajemenMenuPage> {
  List<Map<String, dynamic>> menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  // ── FETCH ─────────────────────────────────────────────────
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
      _snackbar('Gagal memuat data: $e', AppColors.errorRed);
    }
  }

  // ── EDIT ─────────────────────────────────────────────────
  void bukaSHeetEdit(int i) {
    final item      = menuItems[i];
    final nameCtrl  = TextEditingController(text: item['nama_produk']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: item['harga']?.toString() ?? '');
    final descCtrl  = TextEditingController(text: item['deskripsi']?.toString() ?? '');
    final formKey   = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Text('Edit Menu',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                          color: AppColors.adminPrimary, fontFamily: 'Signika Negative')),
                  const SizedBox(height: 16),

                  // Nama
                  _label('Nama Menu'),
                  TextFormField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _inputDeco('Nama menu...'),
                    validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Harga
                  _label('Harga (Rp)'),
                  TextFormField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Contoh: 35000'),
                    validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Deskripsi
                  _label('Deskripsi'),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: _inputDeco('Deskripsi produk...'),
                  ),
                  const SizedBox(height: 24),

                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.adminPrimary,
                          foregroundColor: AppColors.textWhite,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final idProduk  = item['id_produk']?.toString() ?? '';
                          final namaBaru  = nameCtrl.text.trim().toUpperCase();
                          final hargaBaru = priceCtrl.text.trim();
                          final descBaru  = descCtrl.text.trim();

                          // Tutup sheet
                          Navigator.pop(ctx);

                          // Simpan data lama untuk rollback
                          final namaLama  = menuItems[i]['nama_produk'];
                          final hargaLama = menuItems[i]['harga'];
                          final descLama  = menuItems[i]['deskripsi'];

                          // Update tampilan langsung (optimistic)
                          setState(() {
                            menuItems[i]['nama_produk'] = namaBaru;
                            menuItems[i]['harga']       = hargaBaru;
                            menuItems[i]['deskripsi']   = descBaru;
                          });

                          // Kirim ke database
                          final hasil = await ApiService.editMenu(
                            idProduk, namaBaru, hargaBaru,
                            deskripsi: descBaru,
                          );

                          if (hasil['status'] == 'sukses' || hasil['status'] == 'success') {
                            _snackbar('Menu berhasil diperbarui ✓', AppColors.successGreen);
                          } else {
                            // Gagal — kembalikan data lama
                            setState(() {
                              menuItems[i]['nama_produk'] = namaLama;
                              menuItems[i]['harga']       = hargaLama;
                              menuItems[i]['deskripsi']   = descLama;
                            });
                            _snackbar('Gagal: ${hasil['pesan'] ?? 'Error server'}', AppColors.errorRed);
                          }
                        },
                        child: const Text('Simpan',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HAPUS ─────────────────────────────────────────────────
  void bukaDialogHapus(int i) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.delete_outline, color: AppColors.errorRed),
          SizedBox(width: 8),
          Text('Hapus Menu?',
              style: TextStyle(fontFamily: 'Signika Negative', fontSize: 18)),
        ]),
        content: Text(
          'Yakin ingin menghapus\n"${menuItems[i]['nama_produk']}"?',
          style: const TextStyle(fontFamily: 'Signika Negative'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              final idProduk = menuItems[i]['id_produk']?.toString() ?? '';
              final nama     = menuItems[i]['nama_produk']?.toString() ?? '';
              final backup   = Map<String, dynamic>.from(menuItems[i]);

              Navigator.pop(ctx);
              setState(() => menuItems.removeAt(i));

              final hasil = await ApiService.hapusMenu(idProduk);
              if (hasil['status'] == 'sukses' || hasil['status'] == 'success') {
                _snackbar('"$nama" berhasil dihapus', AppColors.successGreen);
              } else {
                setState(() => menuItems.insert(i, backup));
                _snackbar('Gagal: ${hasil['pesan'] ?? 'Error server'}', AppColors.errorRed);
              }
            },
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _snackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textWhite)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87)),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.adminPrimary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5)),
      );

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminPrimary, 
      body: Stack(
        children: [
          Container(
            height: 330,
            decoration: const BoxDecoration(
              color: AppColors.adminPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 15),
                _buildStatCards(context), 
                const SizedBox(height: 25),
                _buildIncomeCard(),
                const SizedBox(height: 15),
                
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.adminCardLight, 
                    ),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -15),
                          child: _buildSectionTitle(),
                        ),
                        Expanded(child: _buildMenuList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // ==========================================
      // PANGGIL BOTTOM NAVIGATION BAR INTERAKTIF
      // ==========================================
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // ==========================================
  // HEADER (Ikon Profil Interaktif)
  // ==========================================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text('Selamat Datang',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 26,
                      fontFamily: 'Tai Heritage Pro', fontWeight: FontWeight.bold)),
              Text('Dashboard Admin',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 26,
                      fontFamily: 'Tai Heritage Pro', fontWeight: FontWeight.bold)),
            ]
          ),
          
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HalamanProfilAdmin()
                ),
              );
            },
            child: Container(
              width: 50, height: 50,
              decoration: const BoxDecoration(color: AppColors.textWhite, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: AppColors.adminPrimary, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STAT CARDS (KARTU ATAS INTERAKTIF)
  // ==========================================
  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard('${menuItems.length}\nProduk', Icons.inventory_2_outlined, isActive: true, onTap: () {}),
          
          _statCard('Riwayat\nPesanan', Icons.shopping_bag_outlined, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanRiwayat()),
            );
          }),
          
          _statCard('Laporan', Icons.bar_chart, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanLaporan()),
            );
          }),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon, {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105, height: 105,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.4) : AppColors.adminStatCard,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppColors.textWhite, size: 30),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 14,
                  fontFamily: 'Signika Negative', fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0), 
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.textWhite, borderRadius: BorderRadius.circular(30)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Pendapatan', style: TextStyle(color: AppColors.adminPrimary, fontSize: 16,
              fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
          Text('Rp -', style: TextStyle(color: AppColors.adminPrimary, fontSize: 16,
              fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.adminPrimary, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.shadowCustom, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: const Text('Manajemen Menu',
          style: TextStyle(color: AppColors.textWhite, fontSize: 20,
              fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMenuList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.adminPrimary));
    }
    if (menuItems.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.fastfood_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Belum ada menu',
              style: TextStyle(color: Colors.grey, fontSize: 16,
                  fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchMenu,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPrimary,
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      color: AppColors.adminPrimary,
      onRefresh: _fetchMenu,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), 
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item      = menuItems[index];
          final namaMenu  = item['nama_produk']?.toString() ?? 'Tanpa Nama';
          final harga     = item['harga']?.toString() ?? '0';
          final deskripsi = item['deskripsi']?.toString() ?? '';
          final urlGambar = item['gambar']?.toString() ?? '';
          final baseUrl   = '${ApiService.baseUrl}/uploads/';

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.textWhite, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.shadowCustom, blurRadius: 5, offset: const Offset(0, 3))] 
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar produk
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C6353),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: urlGambar.isNotEmpty
                      ? Image.network(
                          '$baseUrl$urlGambar',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.fastfood, color: Colors.white54, size: 30),
                        )
                      : const Icon(Icons.fastfood, color: Colors.white54, size: 30),
                  ),
                ),
                const SizedBox(width: 12),

                // Nama + harga + deskripsi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaMenu,
                          style: const TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Signika Negative',
                              color: AppColors.textDark)),
                      const SizedBox(height: 3),
                      Text('Rp $harga',
                          style: const TextStyle(
                              fontSize: 13, 
                              color: AppColors.adminPrimary,
                              fontFamily: 'Signika Negative',
                              fontWeight: FontWeight.bold)),
                      if (deskripsi.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          deskripsi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontFamily: 'Signika Negative'),
                        ),
                      ],
                    ],
                  ),
                ),

                // Tombol edit & hapus
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.successGreen, size: 20),
                      onPressed: () => bukaSHeetEdit(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.errorRed, size: 20),
                      onPressed: () => bukaDialogHapus(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // FUNGSI BOTTOM NAVIGATION INTERAKTIF
  // ==========================================
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(color: AppColors.adminPrimary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // BERANDA (IsSelected = true agar muncul lingkaran putih)
          _bottomNavItem(Icons.home, 'BERANDA', false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdmin()),
            );
          }),
          
          _bottomNavItem(Icons.person, 'PENGGUNA', false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HalamanPengguna()),
            );
          }),
          
          _bottomNavItem(Icons.add_box, 'PRODUK BARU', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TambahProdukPage()),
            );
          }),
          
          // Ikon pakai add_circle_outline sesuai request lu
          _bottomNavItem(Icons.add_circle_outline, 'PESANAN', false, () {
            Navigator.push( 
              context,
              MaterialPageRoute(builder: (context) => const HalamanPesanan()),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET ITEM NAVIGASI
  // ==========================================
  Widget _bottomNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Padding disamakan biar ukurannya pas
              decoration: BoxDecoration(
                color: isSelected ? AppColors.textWhite : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                // Jika aktif warnanya oranye, jika tidak aktif warnanya putih
                color: isSelected ? AppColors.adminPrimary : AppColors.textWhite,
                size: 28, // Ukuran diperbesar disamakan dengan desain aslimu
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }}