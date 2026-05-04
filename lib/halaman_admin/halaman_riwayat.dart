import 'package:flutter/material.dart';
import '../Backend/api_service.dart'; // Pastikan path ini benar sesuai struktur foldermu

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  List<dynamic> _listPesanan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataPesanan(); // Panggil fungsi ambil data saat halaman pertama kali dibuka
  }

  // ============================================================
  // FUNGSI MENYEDOT DATA DARI DATABASE (API)
  // ============================================================
  Future<void> _fetchDataPesanan() async {
    try {
      final data = await ApiService.getPesanan();
      setState(() {
        // ========================================================
        // KODE FILTER: HANYA Tampilkan status SELESAI & DIBATALKAN
        // ========================================================
        _listPesanan = data.where((item) {
          String status = item['status_pesanan'] ?? '';
          return status == 'SELESAI' || status == 'DIBATALKAN';
        }).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching pesanan: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD27F30), // Warna oranye utama
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER (Teks Selamat Datang & Avatar)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dashboard Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Tai Heritage Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Color(0xFFD27F30), size: 30),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. KARTU STATISTIK & PENDAPATAN
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('12\nProduk', Icons.inventory_2_outlined),
                  _buildStatCard('Riwayat\npesanan', Icons.shopping_bag, isActive: true),
                  _buildStatCard('Laporan', Icons.bar_chart),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // (Nantinya total pendapatan ini bisa di-dinamiskan juga)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pendapatan',
                    style: TextStyle(color: Color(0xFFD27F30), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp -', // Disembunyikan sementara sampai kita buat API Pendapatan
                    style: TextStyle(color: Color(0xFFD27F30), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // 3. AREA DAFTAR RIWAYAT PESANAN (Beige Background)
            // ==========================================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF0D5), // Warna krem/beige terang
                ),
                child: Column(
                  children: [
                    // Judul berbentuk pil melayang
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD27F30),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: const Text(
                          'Daftar Pesanan',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    // ============================================================
                    // LIST VIEW BUILDER (DINAMIS DARI DATABASE)
                    // ============================================================
                    Expanded(
                      child: _isLoading 
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD27F30))) // Efek Loading
                        : _listPesanan.isEmpty 
                          ? const Center(child: Text("Belum ada pesanan masuk", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
                          : RefreshIndicator(
                              color: const Color(0xFFD27F30),
                              onRefresh: _fetchDataPesanan, // Tarik ke bawah untuk refresh data
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                itemCount: _listPesanan.length,
                                itemBuilder: (context, index) {
                                  return _buildOrderCard(_listPesanan[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // ==========================================
      // 4. BOTTOM NAVIGATION BAR
      // ==========================================
      bottomNavigationBar: Container(
        color: const Color(0xFFD27F30),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'BERANDA'),
            _buildNavItem(Icons.person, 'PENGGUNA'),
            _buildNavItem(Icons.add_box, 'PRODUK BARU'),
            _buildNavItem(Icons.list_alt, 'PESANAN', isActive: true),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // WIDGET BANTUAN (Helper)
  // ----------------------------------------------------

  Widget _buildStatCard(String title, IconData icon, {bool isActive = false}) {
    return Container(
      width: 105,
      height: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.24),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FUNGSI PEMBUAT DESAIN KARTU PESANAN (MAPPING DARI DATABASE)
  // ============================================================
  Widget _buildOrderCard(Map<String, dynamic> item) {
    // Membongkar data dari Database
    String namaPemesan = item['nama_pemesan'] ?? 'Tanpa Nama';
    String hurufAwal = namaPemesan.isNotEmpty ? namaPemesan[0].toUpperCase() : '?';
    String ringkasan = item['ringkasan_pesanan'] ?? 'Detail Kosong';
    String harga = 'Rp ${item['total_harga'] ?? 0}';
    String status = item['status_pesanan'] ?? 'PROSES';
    
    // Format Waktu sederhana (ambil jam/tanggal dari datetime)
    String waktuLengkap = item['tanggal_pesan'] ?? '';
    String waktuSingkat = waktuLengkap.length > 16 ? waktuLengkap.substring(0, 16) : waktuLengkap;

    // Menentukan warna label status
    Color statusColor = status == 'SELESAI' ? Colors.green : (status == 'DIBATALKAN' ? Colors.red : Colors.blue);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon Huruf di sebelah kiri
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0D5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Center(
              child: Text(
                hurufAwal,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD27F30)),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // Detail Informasi Pesanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Nama & Label Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      namaPemesan,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0D5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle, color: Colors.green, size: 10),
                          SizedBox(width: 4),
                          Text('Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Teks Detail Produk
                Text(
                  ringkasan,
                  style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                
                // Baris Harga & Waktu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      harga,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD27F30)),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          waktuSingkat,
                          style: const TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}