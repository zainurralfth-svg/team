import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../halaman_user/profil_pengguna.dart';
import '../Core/Colour.dart';

// Halaman untuk menampilkan struk digital (bukti pembayaran) setelah pesanan berhasil dikirim.
class BuktiPemesanan extends StatelessWidget {
  const BuktiPemesanan({super.key});

  // TAMBAHAN: Fungsi format Rupiah
  String formatRupiah(dynamic angka) {
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    // Menangkap kiriman data (seperti nama, no HP, keranjang belanja) dari halaman konfirmasi sebelumnya.
    final Map<String, dynamic>? dataPesanan =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Mengambil rincian data satu per satu. Jika data kosong/gagal terbaca, otomatis diganti dengan nilai default.
    final String kodeResi = dataPesanan?['kode_resi'] ?? '#PUD0000';
    final String namaTampil = dataPesanan?['nama'] ?? 'Pelanggan';
    final String telpTampil = dataPesanan?['telp'] ?? '-';
    final int totalHarga = dataPesanan?['total'] ?? 0;
    final List<dynamic> items = dataPesanan?['items'] ?? [];

    // Memeriksa isi catatan pembeli. Jika pembeli tidak mengisi catatan (kosong atau bernilai 'null'), maka ubah tampilannya menjadi tanda strip (-).
    String rawCatatan = dataPesanan?['catatan']?.toString() ?? '';
    final String catatanTampil = (rawCatatan.isEmpty || rawCatatan == 'null')
        ? '-'
        : rawCatatan;

    return Scaffold(
      backgroundColor: AppColors.bgUtama,
      // Menggunakan Stack untuk menempatkan gambar hiasan puding di bawah kotak struk putih.
      body: Stack(
        children: [
          // Kumpulan hiasan gambar puding transparan yang ditempel pada berbagai sudut layar.
          Positioned(
            right: -20,
            top: 50,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/dua.png', width: 150),
            ),
          ),
          Positioned(
            left: -30,
            top: 150,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/satu.png', width: 120),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 200,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/tiga.png', width: 100),
            ),
          ),
          Positioned(
            left: -10,
            bottom: 100,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/empat.png', width: 160),
            ),
          ),

          // Area aman agar struk tidak tertutup oleh lekukan (notch) atas layar HP.
          SafeArea(
            child: Center(
              // SingleChildScrollView: Memastikan kotak struk bisa di-scroll ke bawah jika isi daftar belanjaannya panjang.
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  // Kotak utama struk (berwarna putih) dengan efek bayangan melayang.
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25.0),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Tinggi kotak putih ini akan otomatis menyesuaikan dengan seberapa banyak isinya.
                      children: [
                        // Lingkaran hijau dengan ikon centang sebagai tanda visual bahwa pesanan sukses.
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              color: AppColors.success,
                              size: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Menampilkan Nomor Resi Pudingku
                        Text(
                          kodeResi,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Menampilkan tulisan "CEK OUT BERHASIL"
                        const Text(
                          'CEK OUT BERHASIL',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontFamily: 'Tai Heritage Pro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Divider(
                          color: Colors.black54,
                          thickness: 1,
                        ), // Garis pembatas hitam.
                        const SizedBox(height: 15),

                        // Menampilkan Identitas Pembeli (Nama, Telp, dan Catatan).
                        // Menggunakan widget buatan _buildInfoRow agar titik duanya rapi dan sejajar.
                        _buildInfoRow('Nama', ':', namaTampil),
                        const SizedBox(height: 10),
                        _buildInfoRow('No Telp', ':', telpTampil),
                        const SizedBox(height: 10),
                        _buildInfoRow('Catatan', ':', catatanTampil),

                        const SizedBox(height: 15),

                        const Divider(
                          color: Colors.black54,
                          thickness: 1,
                        ), // Garis pembatas hitam.
                        const SizedBox(height: 15),

                        // Looping (Perulangan) untuk mencetak daftar barang belanjaan satu per satu ke dalam struk.
                        ...items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _buildProductRow(
                              item['nama_produk'] ?? 'Produk',
                              '${item['jumlah']}x',
                              formatRupiah(item['harga']),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        const Divider(
                          color: Colors.black54,
                          thickness: 1,
                        ), // Garis pembatas hitam terakhir.
                        const SizedBox(height: 10),

                        // Baris informasi total jumlah pembayaran di bagian paling bawah kotak struk.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Harga',
                              style: TextStyle(
                                fontFamily: 'Signika Negative', // 👈 FONT BARU
                                color: AppColors.textBrown,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatRupiah(totalHarga),
                              style: const TextStyle(
                                fontFamily: 'Signika Negative', // 👈 FONT BARU
                                color: AppColors.primary,
                                fontSize: 18, // Gedein dikit biar mantap
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // =========================================================================
      // BILAH NAVIGASI BAWAH (BOTTOM NAVIGATION BAR)
      // =========================================================================
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          // Ujung kiri dan kanan atas dibikin melengkung.
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        // Menyusun 3 ikon menu berjejer ke samping secara merata (spaceAround).
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tombol Menu Pesanan
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/cek_pesanan'),
              child: _buildBottomNavItem(
                Icons.receipt_long,
                'Pesanan',
                false,
                AppColors.primary,
              ),
            ),
            // Tombol Menu Utama (Produk)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/menu'),
              child: _buildBottomNavItem(
                Icons.cake,
                'Produk',
                false,
                AppColors.primary,
              ),
            ),
            // Tombol Menu Profil User
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HalamanProfil()),
              ),
              child: _buildBottomNavItem(
                Icons.person,
                'Profil',
                false,
                AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // RANCANGAN WIDGET BANTUAN (Agar struktur kode di atas bersih dan ringkas)
  // =========================================================================

  // Cetakan untuk membuat baris informasi (Label : Isi teks).
  // Digunakan untuk menampilkan Nama, Telp, dan Catatan pembeli agar jarak titik duanya rata dan rapi.
  Widget _buildInfoRow(String label, String separator, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment
          .start, // Jika isi teks terlalu panjang, tulisan akan turun ke bawah dengan rapi.
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textBrown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          separator,
          style: const TextStyle(
            color: AppColors.textBrown,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textBrown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Cetakan khusus untuk mencetak rincian barang yang dibeli di dalam struk.
  // Membagi layar menjadi 3 bagian: Nama (paling lebar), Jumlah (tengah), dan Harga (rata kanan).
  Widget _buildProductRow(String nama, String qty, String harga) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            nama,
            style: const TextStyle(
              color: AppColors.textBrown,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            qty,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textBrown,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            harga,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textBrown,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Cetakan untuk membuat ikon dan tulisan pada menu di bar navigasi bawah.
  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool isSelected,
    Color activeColor,
  ) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            // Jika ikon sedang dipilih (aktif), akan muncul lingkaran putih di belakangnya.
            decoration: BoxDecoration(
              color: isSelected ? AppColors.textWhite : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? activeColor : AppColors.textWhite,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
