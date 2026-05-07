import 'package:flutter/material.dart';
import '../Backend/Api_service.dart'; // <-- sesuaikan path import-mu

class HalamanPesanan extends StatefulWidget {
  const HalamanPesanan({super.key});

  @override
  State<HalamanPesanan> createState() => _HalamanPesananState();
}

class _HalamanPesananState extends State<HalamanPesanan> {
  String? _selectedMenu;
  bool _isLoading = false;

  final TextEditingController _kodeNamaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  // Daftar menu beserta harga default-nya
  final Map<String, int> _daftarMenu = {
    'Taro Pudding': 13000,
    'Brownie Burnt Cheesecake': 20000,
    'Death By Chocolate': 18000,
    'Mango Pudding': 13000,
  };

  @override
  void dispose() {
    _kodeNamaController.dispose();
    _jumlahController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  // =====================================================
  // FUNGSI UTAMA: Kirim pesanan ke database via ApiService
  // =====================================================
  Future<void> _buatPesanan() async {
    // Validasi input
    if (_kodeNamaController.text.trim().isEmpty) {
      _showSnackBar('Kode/Nama pemesan wajib diisi!', isError: true);
      return;
    }
    if (_selectedMenu == null) {
      _showSnackBar('Pilih menu terlebih dahulu!', isError: true);
      return;
    }
    if (_jumlahController.text.trim().isEmpty) {
      _showSnackBar('Jumlah wajib diisi!', isError: true);
      return;
    }
    if (_hargaController.text.trim().isEmpty) {
      _showSnackBar('Harga wajib diisi!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      int jumlah = int.parse(_jumlahController.text.trim());
      int harga = int.parse(_hargaController.text.trim().replaceAll('.', ''));
      int totalHarga = jumlah * harga;

      // Kirim data ke API — sesuaikan key dengan yang diterima backend kamu
      final response = await ApiService.tambahPesanan({
        'nama_pemesan': _kodeNamaController.text.trim(),
        'ringkasan_pesanan': '$jumlah x $_selectedMenu',
        'total_harga': totalHarga,
        'status_pesanan': 'PROSES', // Status awal selalu MENUNGGU
      });

      if (response['status'] == 'sukses') {
        _showSnackBar('Pesanan berhasil dibuat!');
        _resetForm();

        // Kembali ke HomeAdmin dengan sinyal "true" agar halaman admin refresh
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnackBar('Gagal: ${response['pesan'] ?? 'Terjadi kesalahan'}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _kodeNamaController.clear();
    _jumlahController.clear();
    _hargaController.clear();
    setState(() => _selectedMenu = null);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD27F30),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text('Kembali',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat Datang',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('Dashboard Admin',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 45, height: 45,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Color(0xFFD27F30), size: 28),
                  ),
                ],
              ),
            ),
            // Stat Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('12\nProduk', Icons.inventory_2_outlined),
                  _buildStatCard('Riwayat\nPesanan', Icons.shopping_bag),
                  _buildStatCard('Laporan', Icons.bar_chart),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Income card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pendapatan',
                      style: TextStyle(color: Color(0xFFD27F30), fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('570.000',
                      style: TextStyle(color: Color(0xFFD27F30), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Form area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFFC67727),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                                color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
                            child: const Icon(Icons.add, color: Colors.green, size: 40),
                          ),
                          const SizedBox(width: 15),
                          const Text('Tambah pesanan',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildInputLabel('Kode/Nama'),
                      _buildTextField(controller: _kodeNamaController),
                      const SizedBox(height: 15),
                      _buildInputLabel('Menu'),
                      _buildDropdown(),
                      const SizedBox(height: 15),
                      _buildInputLabel('Jumlah'),
                      _buildTextField(controller: _jumlahController, isNumber: true),
                      const SizedBox(height: 15),
                      _buildInputLabel('Harga'),
                      _buildTextField(controller: _hargaController, isNumber: true),
                      const SizedBox(height: 40),
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFE8C4),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                icon: const Icon(Icons.receipt_long, size: 20),
                                label: const Text('Buat pesanan',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                // =====================
                                // PANGGIL FUNGSI KIRIM
                                // =====================
                                onPressed: _buatPesanan,
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

  Widget _buildStatCard(String title, IconData icon) {
    return Container(
      width: 105, height: 105, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.24), borderRadius: BorderRadius.circular(22)),
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

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5.0),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({TextEditingController? controller, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        fillColor: const Color(0xFFFFE8C4),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: const Color(0xFFFFE8C4), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedMenu,
          hint: const Text('Pilih Menu', style: TextStyle(color: Colors.black54)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 30),
          items: _daftarMenu.keys.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedMenu = newValue;
              // Auto-isi harga saat menu dipilih
              if (newValue != null) {
                _hargaController.text = _daftarMenu[newValue].toString();
              }
            });
          },
        ),
      ),
    );
  }
}