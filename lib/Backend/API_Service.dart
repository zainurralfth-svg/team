import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Gunakan 127.0.0.1 jika running di Edge/Chrome Browser
  static const String baseUrl = "http://localhost/api_puddingku";

  // =========================================================
  // HELPER: Decode JSON aman agar aplikasi tidak crash
  // =========================================================
  static Map<String, dynamic> _safeDecodeMap(String body) {
    try {
      final trimmed = body.trim();
      if (trimmed.isEmpty) return {"status": "error", "pesan": "Response kosong"};
      if (trimmed.startsWith('<')) {
        return {"status": "error", "pesan": "PHP Error: Server mengirim HTML (Cek XAMPP)"};
      }
      return jsonDecode(trimmed);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal membaca JSON: $e"};
    }
  }

  static List<dynamic> _safeDecodeList(String body) {
    try {
      final trimmed = body.trim();
      if (trimmed.isEmpty || trimmed.startsWith('<')) return [];
      final decoded = jsonDecode(trimmed);
      return decoded is List ? decoded : [];
    } catch (_) {
      return [];
    }
  }

  // ==========================================
  // 1. OTENTIKASI (LOGIN, REGISTER, RESET)
  // ==========================================
  static Future<Map<String, dynamic>> registerUser(
      String nama, String username, String phone, String password) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: {"nama": nama, "username": username, "phone": phone, "password": password},
      );
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Koneksi gagal: $e"};
    }
  }

  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {"username": username, "password": password},
      );
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Koneksi gagal: $e"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String phone, {String? newPassword}) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/reset_password.php"),
        body: {"phone": phone, "new_password": newPassword ?? ""},
      );
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Koneksi gagal: $e"};
    }
  }

  // ==========================================
  // 2. MENU & PRODUK (ADMIN & USER)
  // ==========================================
  static Future<List<dynamic>> getMenu() async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/api_menu.php"));
      return _safeDecodeList(response.body);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> tambahMenu(
      String nama, String kategori, int harga, int stok, String deskripsi, var imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/api_menu.php"));
      request.fields['nama_produk'] = nama;
      request.fields['kategori'] = kategori;
      request.fields['harga'] = harga.toString();
      request.fields['stok'] = stok.toString();
      request.fields['deskripsi'] = deskripsi;

      if (imageFile != null) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('gambar', bytes, filename: imageFile.name));
      }
      var res = await http.Response.fromStream(await request.send());
      return _safeDecodeMap(res.body);
    } catch (e) { return {"status": "error", "pesan": e.toString()}; }
  }

  // ==========================================
  // 2b. EDIT MENU (BARU) ✅
  // ==========================================
  static Future<Map<String, dynamic>> editMenu(
    String idMenu, String nama, String harga, {String deskripsi = ''}) async {
  try {
    var response = await http.post(
      Uri.parse("$baseUrl/edit_menu.php"),
      body: {
        "id_menu"     : idMenu,
        "nama_produk" : nama,
        "harga"       : harga,
        "deskripsi"   : deskripsi, // ← tambahan ini
      },
    );
    return _safeDecodeMap(response.body);
  } catch (e) {
    return {"status": "error", "pesan": "Koneksi gagal: $e"};
  }
}

  // ==========================================
  // 3. KERANJANG (CUSTOMER)
  // ==========================================
  static Future<List<dynamic>> getKeranjang(String idUser) async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/api_keranjang.php?id_user=$idUser"));
      return _safeDecodeList(response.body);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> tambahKeranjang(String idUser, String idMenu, int jumlah) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/api_keranjang.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "id_user": idUser.toString(),
          "id_menu": idMenu.toString(),
          "jumlah": jumlah.toString(),
        },
      );
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  // ==========================================
  // 4. PESANAN & CHECKOUT
  // ==========================================
  static Future<List<dynamic>> getPesanan({String? idUser}) async {
    try {
      String url = "$baseUrl/api_pesanan.php";
      if (idUser != null && idUser.isNotEmpty) url += "?id_user=$idUser";
      var response = await http.get(Uri.parse(url));
      return _safeDecodeList(response.body);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> checkout(
      String idUser, int totalHarga, List<dynamic> items, String metode) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/api_pesanan.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": idUser,
          "total_harga": totalHarga,
          "metode_pembayaran": metode,
          "items": items,
        }),
      );
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal checkout: $e"};
    }
  }

  static Future<Map<String, dynamic>> checkoutPesanan(String idUser, String nama, String noTelp) async {
    try {
      var url = Uri.parse('$baseUrl/checkout.php');
      var response = await http.post(url, body: {
        'id_user': idUser,
        'nama_pemesan': nama,
        'no_telp': noTelp,
      });
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {'status': 'error', 'pesan': 'Terjadi kesalahan jaringan: $e'};
    }
  }

  // ==========================================
  // 5. PROFIL PENGGUNA
  // ==========================================
  static Future<Map<String, dynamic>> getProfil(String idUser) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/get_profil.php'),
        body: {'id_user': idUser},
      );
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {'status': 'error', 'pesan': 'Gagal koneksi profil: $e'};
    }
  }

  // ==========================================
  // 6. UPDATE STATUS PESANAN (UNTUK ADMIN)
  // ==========================================
  static Future<Map<String, dynamic>> updateStatusPesanan(String idPesanan, String status) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/update_status_pesanan.php"),
        body: {
          "id_pesanan": idPesanan,
          "status": status,
        },
      );
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Koneksi gagal: $e"};
    }
  }

  // ==========================================
  // 7. AMBIL DATA PENGGUNA (UNTUK ADMIN)
  // ==========================================
  static Future<List<dynamic>> getPengguna() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_pengguna.php'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'sukses') {
          return jsonResponse['data'];
        }
      }
      return []; 
    } catch (e) {
      print('Error getPengguna: $e');
      return [];
    }
  }

  // ==========================================
  // 8. HAPUS PENGGUNA (UNTUK ADMIN)
  // ==========================================
  static Future<Map<String, dynamic>> hapusPengguna(String id) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/hapus_pengguna.php"),
        body: {"id": id}, // Kirim ID user yang mau dihapus
      );
      return _safeDecodeMap(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Koneksi gagal: $e"};
    }
  }

  static Future<Map<String, dynamic>> hapusMenu(String idMenu) async {
  try {
    var response = await http.post(
      Uri.parse("$baseUrl/hapus_menu.php"),
      body: {
        "id_menu": idMenu,
      },
    );
    return _safeDecodeMap(response.body);
  } catch (e) {
    return {"status": "error", "pesan": "Koneksi gagal: $e"};
  }
}
} // <--- SEKARANG SEMUANYA AMAN DI DALAM KANDANG (CLASS)