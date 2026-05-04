import 'package:flutter/material.dart';
import '../Backend/Api_service.dart';

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
  static const Color orange = Color(0xFFD27F30);
  static const Color beige  = Color(0xFFC7BCA1);

  List<Map<String, dynamic>> menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  // ── FETCH DATA DARI DATABASE ──────────────────────────────
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── EDIT ─────────────────────────────────────────────────────
  void bukaSHeetEdit(int i) {
    final nameCtrl  = TextEditingController(text: menuItems[i]['nama_produk']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: menuItems[i]['harga']?.toString() ?? '');
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Menu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: orange, fontFamily: 'Signika Negative')),
                const SizedBox(height: 16),
                const Text('Nama Menu',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Nama menu...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: orange, width: 1.5)),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                const Text('Harga (Rp)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 35000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: orange, width: 1.5)),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
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
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx);
                          // Update lokal dulu (optimistic update)
                          setState(() {
                            menuItems[i]['nama_produk'] = nameCtrl.text.trim().toUpperCase();
                            menuItems[i]['harga'] = priceCtrl.text.trim();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Menu berhasil diperbarui ✓'),
                              backgroundColor: orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
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
    );
  }

  // ── HAPUS ────────────────────────────────────────────────────
  void bukaDialogHapus(int i) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.delete_outline, color: Colors.red),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              final nama = menuItems[i]['nama_produk']?.toString() ?? '';
              setState(() => menuItems.removeAt(i));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$nama" dihapus'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      body: Stack(
        children: [
          Container(
            height: 330,
            decoration: const BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 15),
                _buildStatCards(),
                const SizedBox(height: 25),
                _buildIncomeCard(),
                const SizedBox(height: 15),
                _buildSectionTitle(),
                const SizedBox(height: 10),
                Expanded(child: _buildMenuList()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selamat Datang',
                    style: TextStyle(color: Colors.white, fontSize: 26,
                        fontFamily: 'Tai Heritage Pro', fontWeight: FontWeight.bold)),
                Text('Dashboard Admin',
                    style: TextStyle(color: Colors.white, fontSize: 26,
                        fontFamily: 'Tai Heritage Pro', fontWeight: FontWeight.bold)),
              ]),
          Container(
            width: 50, height: 50,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: orange, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard('${menuItems.length} Produk', Icons.inventory_2_outlined),
          _statCard('Riwayat\nPesanan', Icons.shopping_bag_outlined),
          _statCard('Laporan', Icons.bar_chart),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon) {
    return Container(
      width: 105, height: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.24),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14,
                fontFamily: 'Signika Negative', fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildIncomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Pendapatan',
              style: TextStyle(color: orange, fontSize: 16,
                  fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
          Text('570.000',
              style: TextStyle(color: orange, fontSize: 16,
                  fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(15)),
      child: const Center(
        child: Text('Manajemen Menu',
            style: TextStyle(color: Colors.white, fontSize: 20,
                fontFamily: 'Signika Negative', fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMenuList() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: orange),
      );
    }

    // Empty state
    if (menuItems.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.fastfood_outlined, size: 60, color: Colors.white54),
          const SizedBox(height: 12),
          const Text('Belum ada menu',
              style: TextStyle(color: Colors.white70, fontSize: 16,
                  fontFamily: 'Signika Negative')),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchMenu,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      color: orange,
      onRefresh: _fetchMenu,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];

          // Ambil data dari response API
          final namaMenu  = item['nama_produk']?.toString() ?? 'Tanpa Nama';
          final harga     = item['harga']?.toString() ?? '0';
          final urlGambar = item['gambar']?.toString() ?? '';
          final baseUrl   = 'http://127.0.0.1/api_puddingku/';

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              // Gambar dari database, fallback ke placeholder jika kosong
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
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fastfood, color: Colors.white54, size: 30),
                      )
                    : const Icon(Icons.fastfood, color: Colors.white54, size: 30),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaMenu,
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Signika Negative',
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      Text('Rp $harga',
                          style: const TextStyle(fontSize: 12, color: orange,
                              fontFamily: 'Signika Negative',
                              fontWeight: FontWeight.w600)),
                    ]),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green, size: 20),
                onPressed: () => bukaSHeetEdit(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.orange, size: 20),
                onPressed: () => bukaDialogHapus(index),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(color: orange),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home, 'BERANDA', true),
          _navItem(Icons.person, 'PENGGUNA', false),
          _navItem(Icons.add_box, 'PRODUK BARU', false),
          _navItem(Icons.description, 'PESANAN', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Stack(alignment: Alignment.center, children: [
        if (active)
          Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        Icon(icon, color: active ? orange : Colors.white, size: 24),
      ]),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 10,
              fontFamily: 'Tai Heritage Pro', fontWeight: FontWeight.bold)),
    ]);
  }
}