import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Core/Colour.dart'; 
import '../Backend/api_service.dart'; 
import 'profil_pengguna.dart';
import '../Widget/custom_user_navbar.dart'; 
import '../Widget/custom_text.dart'; 

class CekPesananPage extends StatefulWidget {
  const CekPesananPage({super.key});

  @override
  State<CekPesananPage> createState() => _CekPesananPageState();
}

class _CekPesananPageState extends State<CekPesananPage> {
  bool _isLoading = true;
  String _currentUserId = "";

  List<dynamic> _pesananAktif = [];
  List<dynamic> _pesananRiwayat = [];

  @override
  void initState() {
    super.initState();
    _fetchPesananUser();
  }

  String formatRupiah(dynamic angka) {
    if (angka == null) return "Rp 0";
    int value = int.tryParse(angka.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  String _formatWaktu(Map<String, dynamic> item) {
    String status = (item['status_pesanan'] ?? '').toString().toUpperCase();
    String? rawTime;

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
      return rawTime.length > 15 ? rawTime.substring(0, 15) : rawTime;
    }
  }

  Future<void> _fetchPesananUser() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('id_user') ?? ""; 

      if (_currentUserId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final semuaPesanan = await ApiService.getPesanan();
      final pesananSaya = semuaPesanan.where((p) => p['id_user'].toString() == _currentUserId).toList();

      List<dynamic> aktif = [];
      List<dynamic> riwayat = [];

      for (var p in pesananSaya) {
        String status = p['status_pesanan']?.toString().toUpperCase() ?? 'MENUNGGU';
        if (status == 'SELESAI' || status == 'DIBATALKAN') {
          riwayat.add(p);
        } else {
          aktif.add(p);
        }
      }

      setState(() {
        _pesananAktif = aktif;
        _pesananRiwayat = riwayat;
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: CustomText('Gagal memuat pesanan: $e', color: Colors.white), backgroundColor: AppColors.error),
        );
      }
    }
  }

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
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              
              final response = await ApiService.updateStatusPesanan(idPesanan, 'DIBATALKAN');
              
              if (response['status'] == 'sukses') {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: CustomText('Pesanan berhasil dibatalkan.', color: Colors.white), backgroundColor: AppColors.success),
                  );
                }
                _fetchPesananUser();
              } else {
                setState(() => _isLoading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: CustomText('Gagal: ${response['pesan']}', color: Colors.white), backgroundColor: AppColors.error),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: AppColors.bgUtama,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 70,
          iconTheme: const IconThemeData(color: AppColors.textWhite),
          title: const CustomText('Pesanan Saya', color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            indicatorWeight: 4,
            labelColor: AppColors.textWhite,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontFamily: 'Signika Negative', fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Saat Ini'),
              Tab(text: 'Pesanan Selesai'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : TabBarView(
                children: [
                  _buildListPesanan(_pesananAktif, isRiwayat: false),
                  _buildListPesanan(_pesananRiwayat, isRiwayat: true),
                ],
              ),
        bottomNavigationBar: CustomUserNavbar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              // Biarin kosong
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/menu'); 
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HalamanProfil()));
            }
          },
        ),
      ),
    );
  }

  Widget _buildListPesanan(List<dynamic> listData, {required bool isRiwayat}) {
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchPesananUser,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: listData.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(listData[index], isRiwayat);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> dataPesanan, bool isRiwayat) {
    String idTampil = dataPesanan['kode_resi']?.toString() ?? '-';
    String idDatabase = dataPesanan['id_pesanan']?.toString() ?? '';
    
    String statusRaw = dataPesanan['status_pesanan']?.toString().toUpperCase() ?? '';
    String status = statusRaw.isEmpty ? 'MENUNGGU' : statusRaw; 
    
    String totalHarga = formatRupiah(dataPesanan['total_harga']);
    String waktuTampil = _formatWaktu(dataPesanan); 
    
    // TAMBAHAN: Tarik data catatan dari database
    // Pastikan nama 'catatan' ini sama dengan nama kolom di database lu ya!
    String catatan = dataPesanan['catatan']?.toString() ?? ''; 
    
    List<String> listProduk = [];
    if (dataPesanan['ringkasan_pesanan'] != null) {
      listProduk = dataPesanan['ringkasan_pesanan'].toString().split(RegExp(r',\s*'));
    }

    Color warnaStatus = AppColors.primary;
    if (status == 'PROSES') warnaStatus = AppColors.info;
    if (status == 'SELESAI') warnaStatus = AppColors.success;
    if (status == 'DIBATALKAN') warnaStatus = AppColors.error;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(idTampil, color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
              CustomText(waktuTampil, color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.bold),
            ],
          ),
          const Divider(color: AppColors.bgInput, thickness: 1, height: 25),
          
          ...listProduk.map((produk) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fastfood_rounded, size: 16, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(produk, color: AppColors.textBrown, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          
          // TAMBAHAN: Tampilan Catatan Pesanan
          if (catatan.isNotEmpty && catatan != 'null') ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.edit_note, size: 16, color: AppColors.textHint), // Icon kecil buat catatan
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    'Catatan: $catatan', 
                    color: AppColors.textHint, // Pakai warna agak redup biar beda sama menu utama
                    fontSize: 13, 
                    fontStyle: FontStyle.italic, // Dibikin miring biar kerasa kayak notes
                  ),
                ),
              ],
            ),
          ],
          
          const Divider(color: AppColors.bgInput, height: 20),

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
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: warnaStatus, shape: BoxShape.circle)),
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

          if (!isRiwayat && status == 'MENUNGGU') ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _batalkanPesanan(idDatabase),
                child: const CustomText('Batalkan Pesanan', color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ] else if (!isRiwayat && status == 'PROSES') ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const CustomText(
                'Pesanan sedang disiapkan, tidak bisa dibatalkan.',
                textAlign: TextAlign.center,
                color: AppColors.info, 
                fontSize: 12, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ]
        ],
      ),
    );
  }
}