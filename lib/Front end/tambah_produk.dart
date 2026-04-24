import 'dart:convert'; // PERBAIKAN: import ini untuk jsonDecode manual
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Core/Colour.dart';
import '../Backend/api_service.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  String? _selectedKategori;
  final List<String> _kategoriList = [
    'Pudding',
    'Dessert',
    'Cake',
    'Brownies',
    'Cookies'
  ];

  XFile? _selectedImage;
  String _fileName = 'Tidak Ada File Yang Di Pilih';
  bool _isLoading = false; // PERBAIKAN: tambah state loading

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _fileName = image.name;
      });
    }
  }

  // =========================================================
  // PERBAIKAN: Helper untuk parse response JSON dengan aman.
  // Jika server mengembalikan HTML bukan JSON, fungsi ini
  // akan mengembalikan pesan error yang mudah dibaca.
  // =========================================================
  Map<String, dynamic> _safeParseResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;

    if (raw is String) {
      final trimmed = raw.trim();
      // Cek apakah response adalah HTML (biasanya diawali '<')
      if (trimmed.startsWith('<')) {
        return {
          'status': 'error',
          'pesan':
              'Server mengembalikan HTML bukan JSON. Cek error PHP di server.',
        };
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'status': 'error', 'pesan': 'Format response tidak dikenali.'};
      } catch (_) {
        return {
          'status': 'error',
          'pesan': 'Response tidak valid: $trimmed',
        };
      }
    }

    return {'status': 'error', 'pesan': 'Terjadi kesalahan tidak dikenal.'};
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Kembali',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white, fontSize: 26,
                          fontFamily: 'Tai Heritage Pro', fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Dashboard Admin',
                        style: TextStyle(
                          color: Colors.white, fontSize: 26,
                          fontFamily: 'Tai Heritage Pro', fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50, height: 50,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: AppColors.primaryOrange, size: 30),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. KARTU STATISTIK
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('12\nProduk', Icons.inventory_2_outlined),
                  _buildStatCard('Riwayat\nPesanan', Icons.shopping_bag_outlined),
                  _buildStatCard('Laporan', Icons.bar_chart),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pendapatan',
                      style: TextStyle(color: AppColors.primaryOrange, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('570.000',
                      style: TextStyle(color: AppColors.primaryOrange, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ==========================================
            // 3. AREA FORM TAMBAH PRODUK
            // ==========================================
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50), topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300], borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.add_box, color: Colors.black87, size: 30),
                          ),
                          const SizedBox(width: 15),
                          const Text('Tambah Produk',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 25),

                      _buildInputLabel('Nama Produk'),
                      _buildInputField('Ketik Disini...', Icons.inventory_2, _namaController),
                      const SizedBox(height: 15),

                      _buildInputLabel('Kategori Produk'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg, borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: AppColors.inputBg,
                            hint: const Text('Pilih Kategori...', style: TextStyle(color: Colors.black45, fontSize: 14)),
                            value: _selectedKategori,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                            items: _kategoriList.map((String kategori) {
                              return DropdownMenuItem<String>(
                                value: kategori,
                                child: Text(kategori, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (newValue) => setState(() => _selectedKategori = newValue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildInputLabel('Harga Produk'),
                      _buildInputField('Ketik Disini...', Icons.monetization_on, _hargaController,
                          type: TextInputType.number),
                      const SizedBox(height: 15),

                      _buildInputLabel('Stok Produk'),
                      _buildInputField('Ketik Disini...', Icons.layers, _stokController,
                          type: TextInputType.number),
                      const SizedBox(height: 15),

                      _buildInputLabel('Deskripsi Produk'),
                      _buildInputField('Ketik Disini...', Icons.description, _deskripsiController),
                      const SizedBox(height: 15),

                      _buildInputLabel('Tambah Foto Produk'),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.inputBg, borderRadius: BorderRadius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _pickImage,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              child: Row(
                                children: [
                                  _selectedImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: kIsWeb
                                              ? Image.network(_selectedImage!.path, width: 30, height: 30, fit: BoxFit.cover)
                                              : Image.file(File(_selectedImage!.path), width: 30, height: 30, fit: BoxFit.cover),
                                        )
                                      : const Icon(Icons.image, color: Colors.black54),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                                    child: const Text('Pilih File...', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(_fileName,
                                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ==========================================
                      // TOMBOL SUBMIT — dengan penanganan error aman
                      // ==========================================
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bgCream,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.check, color: Colors.green, size: 24),
                          label: Text(
                            _isLoading ? 'Menyimpan...' : 'Konfirmasi Produk',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _isLoading ? null : _submitProduk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PERBAIKAN: Pisahkan logika submit ke fungsi sendiri
  // dengan try-catch agar error apapun tidak crash aplikasi
  // =========================================================
  Future<void> _submitProduk() async {
    String nama = _namaController.text.trim();
    String deskripsi = _deskripsiController.text.trim();
    String hargaBeresih = _hargaController.text.replaceAll(RegExp(r'[^0-9]'), '');
    String stokBeresih = _stokController.text.replaceAll(RegExp(r'[^0-9]'), '');
    int harga = int.tryParse(hargaBeresih) ?? 0;
    int stok = int.tryParse(stokBeresih) ?? 0;

    if (nama.isEmpty || _selectedKategori == null || harga == 0 || stok == 0 || deskripsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong isi semua data dan pilih kategori produk!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // PERBAIKAN: Bungkus pemanggilan API dengan try-catch
      final rawResponse = await ApiService.tambahMenu(
        nama, _selectedKategori!, harga, stok, deskripsi, _selectedImage,
      );

      // Parse dengan aman — tidak akan crash walau server kirim HTML
      final response = _safeParseResponse(rawResponse);

      if (!mounted) return;

      if (response['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk beserta foto berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${response['pesan'] ?? 'Error tidak diketahui'}')),
        );
      }
    } catch (e) {
      // PERBAIKAN: Tangkap error jaringan / parsing di sini
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan koneksi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 10.0),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInputField(String hint, IconData icon, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black54),
        fillColor: AppColors.inputBg,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon) {
    return Container(
      width: 105, height: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.24), borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}