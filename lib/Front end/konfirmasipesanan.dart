import 'package:flutter/material.dart';

class KonfirmasiPage extends StatefulWidget {
  const KonfirmasiPage({super.key});

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage> {
  // ALAT PENANGKAP TEKS
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan memori saat pindah halaman
    _namaController.dispose();
    _telpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2D7A6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: const BoxDecoration(color: Color(0xFFD27F30)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Kembali',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Konfirmasi Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Oleo Script',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), 
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long, color: Color(0xFF270C0C)),
                        const SizedBox(width: 10),
                        const Text(
                          'Ringkasan Pemesanan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF270C0C)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3)),
                        ],
                      ),

                      //Kolom Untuk Foto Produk
                      child: Column(
                        children: [
                          _buildItemRingkasan('Brownie Burnt Cheesecake', 'x2', 'Rp 36.000'),
                          const SizedBox(height: 15),
                          Positioned(
                          left: -50,
                          top: 10,
                          child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage('assets/images/Brownie Burn Cheesecake.png'),
                            fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          _buildItemRingkasan('Death By Cokelat', 'x1', 'Rp 18.000'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: Colors.black, thickness: 1.5), 
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              const Text('Rp 54.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD27F30))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Color(0xFFD27F30)),
                        const SizedBox(width: 10),
                        const Text(
                          'Data Diri',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF270C0C)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NAMA LENGKAP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 5),
                          // Masukkan controller nama ke sini
                          _buildTextField('Nama Kamu', Icons.person, const Color(0xFFFF9800), _namaController),
                          const SizedBox(height: 15),
                          const Text('NO. TELP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 5),
                          // Masukkan controller telp ke sini
                          _buildTextField('No. Telp', Icons.phone_in_talk_outlined, Colors.black, _telpController),
                          const SizedBox(height: 30),
                          
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1C574), 
                                foregroundColor: Colors.black, 
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.black, width: 0.5), 
                                ),
                              ),
                              icon: const Icon(Icons.shopping_bag, color: Color(0xFFFF7043), size: 20),
                              label: const Text('Checkout Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                // AMBIL TEKS YANG DIKETIK
                                String namaInput = _namaController.text;
                                String telpInput = _telpController.text;

                                // Pindah ke bukti pemesanan sambil MEMBAWA DATA (arguments)
                                Navigator.pushNamed(
                                  context, 
                                  '/bukti_pemesanan',
                                  arguments: {
                                    'nama': namaInput.isEmpty ? 'Pelanggan' : namaInput, // Jika kosong, tulis 'Pelanggan'
                                    'telp': telpInput.isEmpty ? '-' : telpInput,
                                  }
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E0),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFD27F30)),
                              ),
                              child: const Text(
                                'Nb: Lakukan pembayaran di outlet',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRingkasan(String title, String qty, String price) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.cake, color: Colors.grey),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
              Text(qty, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD27F30))),
      ],
    );
  }

  // UBAH: Tambahkan parameter TextEditingController di sini
  Widget _buildTextField(String hint, IconData icon, Color iconColor, TextEditingController controller) {
    return TextField(
      controller: controller, // Pasang controller-nya
      decoration: InputDecoration(
        hintText: hint, 
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: iconColor, size: 22), 
        fillColor: const Color(0xFFFEF6E8), 
        filled: true, 
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD27F30), width: 1.5),
        ),
      ),
    );
  }
}