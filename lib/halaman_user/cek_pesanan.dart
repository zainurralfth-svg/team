import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Buat mengambil ID user yang lagi login
import 'package:intl/intl.dart'; // Buat format mata uang Rupiah
import '../Core/Colour.dart'; // Palet warna resmi Puddingku
import '../Backend/api_service.dart'; // Koneksi ke database PHP/XAMPP
import 'profil_pengguna.dart'; //untuk navigasi ke halaman profil pengguna
import '../Widget/custom_user_navbar.dart'; // Navigasi bawah kustom
import '../Widget/custom_text.dart'; // Komponen teks kustom buatan kita
import '../Widget/notification_helper.dart';

class CekPesananPage extends StatefulWidget { // Halaman utama buat cek status pesanan pudding yang udah dibuat sama user
  const CekPesananPage({super.key});

  @override
  State<CekPesananPage> createState() => _CekPesananPageState();
}

class _CekPesananPageState extends State<CekPesananPage> {
  // Saklar loading & penampung ID user
  bool _isLoading = true; // loading untuk kontrol tampilan indikator muter-muter saat data pesanan sedang diambil dari database
  String _currentUserId = ""; // Penampung ID user yang lagi login, nanti dipakai buat filter data pesanan sesuai usernya di database

  // penampung data pesanan yang dipisah berdasarkan status
  List<dynamic> _pesananAktif = [];   // Tampung pesanan yang lagi MENUNGGU / PROSES
  List<dynamic> _pesananRiwayat = []; // Tampung pesanan yang sudah SELESAI / DIBATALKAN

  @override
  void initState() {
    super.initState();
    _fetchPesananUser(); // Gerak cepat ambil data begitu halaman pertama kali dibuka
  }

  // FUNGSI: Mengubah angka mentah jadi format Rupiah (Contoh: 15000 -> Rp 15.000)
  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  // FUNGSI: Menghitung selisih waktu biar tampil (Contoh: '3 jam lalu')
  String _formatWaktu(Map<String, dynamic> item) {
    String status = (item['status_pesanan'] ?? '').toString().toUpperCase();
    String? rawTime;

    // Kalau pesanan udah selesai/batal, patokannya waktu update status terakhir. Kalau belum, waktu pas baru pesan.
    if (status == 'SELESAI' || status == 'DIBATALKAN') {
      rawTime = item['updated_at'] ?? item['tanggal_pesanan'] ?? item['created_at'];
    } else {
      rawTime = item['tanggal_pesanan'] ?? item['created_at'] ?? item['waktu'];
    }

    if (rawTime == null || rawTime.isEmpty) return 'Baru saja';

    try {
      DateTime orderTime = DateTime.parse(rawTime);
      Duration diff = DateTime.now().difference(orderTime);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (e) {
      // Jalur darurat kalau format tanggal dari MySQL agak aneh, potong stringnya aja
      return rawTime.length > 15 ? rawTime.substring(0, 15) : rawTime;
    }
  }

  // ==============================================================
  // LOGIKA UTAMA: AMBIL DATA PESANAN DARI DATABASE & PILIHKAN TAB
  // ==============================================================
  Future<void> _fetchPesananUser() async {
    setState(() => _isLoading = true);
    try {
      // 1. Intip SharedPreferences dulu, cari tahu siapa user yang lagi buka
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('id_user') ?? ""; 

      if (_currentUserId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. Tarik semua data pesanan dari API PHP
      final semuaPesanan = await ApiService.getPesanan();
      
      // 3. Filter/Saring: Ambil pesanan yang "id_user"-nya cocok dengan user yang lagi login saat ini
      final pesananSaya = semuaPesanan.where((p) => p['id_user'].toString() == _currentUserId).toList();

      List<dynamic> aktif = [];
      List<dynamic> riwayat = [];

      // 4. Sortir masuk keranjang mana: Masih diproses atau udah selesai?
      for (var p in pesananSaya) {
        String status = p['status_pesanan']?.toString().toUpperCase() ?? 'MENUNGGU';
        if (status == 'SELESAI' || status == 'DIBATALKAN') {
          riwayat.add(p); // Masuk tab Riwayat pesanan
        } else {
          aktif.add(p);   // Masuk tab pesanan aktif
        }
      }

      // 5. Masukkan ke dalam State utama biar UI ke-refresh otomatis
      setState(() {
        _pesananAktif = aktif;
        _pesananRiwayat = riwayat;
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        NotificationHelper.show(
          context,
          message: 'Gagal memuat pesanan.',
          type: NotificationType.error,
        );
      }
    }
  }

  // ==============================================================
  // PROSES: TOMBOL AKSI BATALKAN PESANAN (KHUSUS STATUS 'MENUNGGU')
  // ==============================================================
  Future<void> _batalkanPesanan(String idPesanan) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const CustomText('Batalkan Pesanan?', fontWeight: FontWeight.bold),
        content: const CustomText('Yakin nih mau batalin pesanan puddingnya? 🥺'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const CustomText('Nggak Jadi', color: Colors.grey)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              setState(() => _isLoading = true);
              
              // Tembak API ubah status pesanan jadi 'DIBATALKAN'
              final response = await ApiService.updateStatusPesanan(idPesanan, 'DIBATALKAN');
              
              //notifikasi hasil batalin pesanan ke user berdasarkan response dari API
              if (response['status'] == 'sukses') {
                if (mounted) {
                  NotificationHelper.show(
                    context,
                    message: 'Pesanan berhasil dibatalkan.',
                    type: NotificationType.success,
                  );
                }
                _fetchPesananUser(); // Ambil ulang data terbaru biar kartu pesanannya pindah tab
              } else {
                setState(() => _isLoading = false);
                if (mounted) {
                  NotificationHelper.show(
                    context,
                    message: 'Gagal membatalkan pesanan.',
                    type: NotificationType.error,
                  );
                }
              }
            },
            child: const CustomText('Ya, Batalkan', color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PROSES: HAPUS RIWAYAT KARTU PESANAN DARI LAYAR SECARA PERMANEN
  // ==============================================================
  Future<void> _hapusRiwayatPesanan(String idPesanan) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const CustomText('Hapus Riwayat?', fontWeight: FontWeight.bold),
        content: const CustomText('Riwayat pesanan ini akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const CustomText('Batal', color: Colors.grey)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              
              // Tembak API delete data berdasarkan ID di database MySQL
              final response = await ApiService.deletePesanan(idPesanan);
              
              if (response['status'] == 'sukses') {
                if (mounted) {
                  NotificationHelper.show(
                    context,
                    message: 'Riwayat pesanan berhasil dihapus.',
                    type: NotificationType.success,
                  );
                }
                _fetchPesananUser(); // Refresh UI
              } else {
                setState(() => _isLoading = false);
                if (mounted) {
                  NotificationHelper.show(
                    context,
                    message: 'Gagal menghapus riwayat pesanan.',
                    type: NotificationType.error,
                  );
                }
              }
            },
            child: const CustomText('Hapus', color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PROSES: EDIT CATATAN PESANAN 
  // ==============================================================
  void _tampilkanDialogEditCatatan(String idPesanan, String catatanLama) {
    TextEditingController editController = TextEditingController(text: catatanLama);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const CustomText('Edit Catatan Pesanan', fontWeight: FontWeight.bold, fontSize: 18),
        content: TextField(
          controller: editController,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: "Contoh: Bang, gulanya dikit aja ya...",
            hintStyle: const TextStyle(fontFamily: 'Signika Negative', color: AppColors.textHint, fontSize: 13),
            filled: true,
            fillColor: AppColors.bgInput,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const CustomText('Batal', color: Colors.grey)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx); 
              setState(() => _isLoading = true); 
              
              // Tembak API update text catatan/request user ke MySQL
              final response = await ApiService.updateCatatan(idPesanan, editController.text);
              
              if (response['status'] == 'sukses') {
                if (mounted) {
                  NotificationHelper.show(
                    context,
                    message: 'Catatan berhasil diperbarui! 🎉',
                    type: NotificationType.success,
                  );
                }
                _fetchPesananUser(); // Ambil ulang data biar text catatan langsung berubah di layar
              } else {
                setState(() => _isLoading = false);
                if (mounted) {
                  NotificationHelper.show(
                    context,
                    message: 'Gagal memperbarui catatan.',
                    type: NotificationType.error,
                  );
                }
              }
            },
            child: const CustomText('Simpan', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // DESAIN STRUKTUR HALAMAN UTAMA (TAB BAR & NAVBAR BAWAH)
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tab: 'Saat Ini' dan 'Pesanan Selesai'
      child: Scaffold(
        backgroundColor: AppColors.bgUtama,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Matikan tombol back bawaan flutter
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 70,
          iconTheme: const IconThemeData(color: AppColors.textWhite),
          title: const CustomText('Pesanan Saya', color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.accent, // Garis bawah penanda tab aktif (warna kuning/aksen)
            indicatorWeight: 4,
            labelColor: AppColors.textWhite,
            unselectedLabelColor: Colors.white54, // Warna tab kalau lagi ga dipilih/redup
            labelStyle: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Saat Ini'),
              Tab(text: 'Pesanan Selesai'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) // Efek muter-muter pas loading data
            : TabBarView(
                children: [
                  _buildListPesanan(_pesananAktif, isRiwayat: false),  // Isi konten Tab saat ini (pesanan yang masih menunggu/proses)
                  _buildListPesanan(_pesananRiwayat, isRiwayat: true), // Isi konten Tab riwayat (pesanan yang sudah selesai/dibatalkan)
                ],
              ),
        bottomNavigationBar: CustomUserNavbar(
          currentIndex: 0, // Penanda kalau menu 'Pesanan' lagi aktif di navbar bawah
          onTap: (index) {
            if (index == 0) {
              // Sudah di halaman cek pesanan, diam di tempat
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/menu'); // Pindah ke Katalog menu pudding
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProfil())); // Pindah ke Profile
            }
          },
        ),
      ),
    );
  }

  // ==============================================================
  // WIDGET BUILDER: MEMBENTUK DAFTAR PESANAN / NOTIFIKASI KOSONG
  // ==============================================================
  Widget _buildListPesanan(List<dynamic> listData, {required bool isRiwayat}) {
    // KONDISI: Jika datanya kosong melompong, tampilin ikon sedih/box kosong
    if (listData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isRiwayat ? Icons.history : Icons.shopping_bag_outlined, size: 60, color: AppColors.textHint.withOpacity(0.5)),
            const SizedBox(height: 10),
            CustomText(
              isRiwayat ? 'Belum ada riwayat pesanan.' : 'Belum ada pesanan aktif nih.',
              color: AppColors.textHint, fontSize: 16, fontWeight: FontWeight.bold,
            ),
          ],
        ),
      );
    }

    // KONDISI: Jika ada datanya, bungkus pakai RefreshIndicator biar bisa ditarik ke bawah (Swipe to Refresh)
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchPesananUser, // Kalau ditarik ke bawah, otomatis ambil data ulang ke database
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(), // Memaksa halaman bisa discroll walau isinya sedikit (syarat wajib RefreshIndicator)
        itemCount: listData.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(listData[index], isRiwayat); // Gambar kartu orderan satu per satu
        },
      ),
    );
  }

  // ==============================================================
  // WIDGET BUILDER: KARTU DESAIN PER-PESANAN (KOTAK PUTIH DETAIL)
  // ==============================================================
  Widget _buildOrderCard(Map<String, dynamic> dataPesanan, bool isRiwayat) {
    String idTampil = dataPesanan['kode_resi']?.toString() ?? '-'; // Nomor resi unik transaksi Puddingku
    String idDatabase = dataPesanan['id_pesanan']?.toString() ?? '';
    String namaPemesan = dataPesanan['nama_pemesan']?.toString() ?? 'Pelanggan';
    
    String statusRaw = dataPesanan['status_pesanan']?.toString().toUpperCase() ?? '';
    String status = statusRaw.isEmpty ? 'MENUNGGU' : statusRaw; 
    
    String totalHarga = formatRupiah(dataPesanan['total_harga']);
    String waktuTampil = _formatWaktu(dataPesanan); 
    
    String catatan = dataPesanan['catatan']?.toString() ?? ''; 
    bool hasCatatan = catatan.isNotEmpty && catatan != 'null';

    // Memecah tulisan ringkasan menu yang dipisah tanda koma dari MySQL jadi bentuk List (Contoh: "Pudding Coklat x2, Pudding Susu x1")
    List<String> listProduk = [];
    if (dataPesanan['ringkasan_pesanan'] != null) {
      listProduk = dataPesanan['ringkasan_pesanan'].toString().split(RegExp(r',\s*'));
    }

    // LOGIKA WARNA STATUS: Menentukan warna dot & teks status pesanan pudding
    Color warnaStatus = AppColors.primary; // Default Oranye (MENUNGGU)
    if (status == 'PROSES') warnaStatus = AppColors.info; // Biru
    if (status == 'SELESAI') warnaStatus = AppColors.success; // Hijau
    if (status == 'DIBATALKAN') warnaStatus = AppColors.error; // Merah

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BAGIAN 1: BARIS ATAS (Kode Resi, Nama, & Status Waktu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(idTampil, color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      CustomText(namaPemesan, color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                    ],
                  ),
                ],
              ),
              CustomText(waktuTampil, color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.bold),
            ],
          ),
          const Divider(color: AppColors.bgInput, thickness: 1, height: 25),
          
          // BAGIAN 2: BARIS DAFTAR MENU PUDDING (Looping pakai widget Map)
          ...listProduk.map((produk) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fastfood_rounded, size: 16, color: AppColors.primaryDark), // Ikon makanan imut
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(produk, color: AppColors.textBrown, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 8),
          
          // BAGIAN 3: BOX CATATAN / REQUEST KHUSUS PELANGGAN JIKA ADA (Contoh: "Bang, gulanya dikit aja ya...")
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.bgInput.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.edit_note, size: 18, color: AppColors.textHint), 
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    hasCatatan ? catatan : 'Belum ada catatan pesanan', 
                    color: hasCatatan ? AppColors.textDark : AppColors.textHint, 
                    fontSize: 13, 
                    fontStyle: FontStyle.italic, 
                  ),
                ),
                // Tombol Edit Catatan hanya akan muncul jika pesanan belum diproses penjual/ dengan status proses(Status masih 'MENUNGGU')
                if (!isRiwayat && status == 'MENUNGGU')
                  GestureDetector(
                    onTap: () => _tampilkanDialogEditCatatan(idDatabase, hasCatatan ? catatan : ''),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        children: [
                          const Icon(Icons.edit_square, size: 20, color: AppColors.primary),
                          const SizedBox(height: 2),
                          const CustomText('Edit Catatan', color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(color: AppColors.bgInput, height: 25),

          // BAGIAN 4: BARIS BAWAH (Total Harga Belanjaan & Indikator Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText('Total Bayar', color: AppColors.textHint, fontSize: 12),
                  CustomText(totalHarga, color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CustomText('Status', color: AppColors.textHint, fontSize: 12),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: warnaStatus, shape: BoxShape.circle)), // Dot warna dinamis
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.bgUtama, borderRadius: BorderRadius.circular(5)),
                        child: CustomText(status, color: AppColors.textDark, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // BAGIAN 5: TOMBOL AKSI DINAMIS DI BAGIAN BAWAH KARTU
          // Kondisi A: Masih menunggu konfirmasi, kasih tombol "Batalkan Pesanan Jika Ingin Mmebatalkan Pesanan"
          if (!isRiwayat && status == 'MENUNGGU') ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () => _batalkanPesanan(idDatabase),
                child: const CustomText('Batalkan Pesanan', color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
            // Kondisi B: kunci tombol pembatalan dan beri pemberitahuan info bahwa pesanan sedang diproses dan tidak bisa dibatalkan
          ] else if (!isRiwayat && status == 'PROSES') ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const CustomText(
                'Pesanan sedang disiapkan, tidak bisa dibatalkan.',
                textAlign: TextAlign.center, color: AppColors.info, fontSize: 12, fontWeight: FontWeight.bold,
              ),
            ),
          ] else if (isRiwayat) ...[
            // Kondisi C: Pesanan udah selesai/batal di sebelum nya, kasih tombol "Hapus Riwayat" biar layar bersih di riwayat pesanan
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.textHint), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () => _hapusRiwayatPesanan(idDatabase),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline, color: AppColors.textHint, size: 20),
                    const SizedBox(width: 8),
                    const CustomText('Hapus Riwayat Pesanan', color: AppColors.textHint, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}