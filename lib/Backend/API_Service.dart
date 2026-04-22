import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1/api_puddingku";

  // =========================================================
  // PERBAIKAN UTAMA: Helper decode JSON dengan aman.
  // Jika server mengembalikan HTML (misal karena PHP warning),
  // fungsi ini TIDAK akan crash — langsung kembalikan error map.
  // =========================================================
  static Map<String, dynamic> _safeDecodeMap(String body) {
    try {
      final trimmed = body.trim();
      if (trimmed.isEmpty) {
        return {"status": "error", "pesan": "Server mengembalikan response kosong."};
      }
      // HTML selalu diawali '<' — tangkap sebelum jsonDecode
      if (trimmed.startsWith('<')) {
        return {
          "status": "error",
          "pesan": "Server error: PHP mengembalikan HTML bukan JSON. "
              "Cek log error di server."
        };
      }
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      return {"status": "error", "pesan": "Format response tidak dikenali."};
    } catch (e) {
      return {"status": "error", "pesan": "Gagal membaca response: $e"};
    }
  }

  static List<dynamic> _safeDecodeList(String body) {
    try {
      final trimmed = body.trim();
      if (trimmed.isEmpty || trimmed.startsWith('<')) return [];
      final decoded = jsonDecode(trimmed);
      if (decoded is List) return decoded;
      return [];
    } catch (_) {
      return [];
    }
  }

  // ==========================================
  // 1. FUNGSI OTENTIKASI
  // ==========================================
  static Future<Map<String, dynamic>> registerUser(
      String nama, String username, String phone, String password) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: {"nama": nama, "username": username, "phone": phone, "password": password},
      );
      return _safeDecodeMap(response.body); // ← diganti
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {"username": username, "password": password},
      );
      return _safeDecodeMap(response.body); // ← diganti
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String phone, {String? newPassword}) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/reset_password.php"),
        body: {"phone": phone, "new_password": newPassword ?? ""},
      );
      return _safeDecodeMap(response.body); // ← diganti
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  // ==========================================
  // 2. FUNGSI MENU / PRODUK
  // ==========================================
  static Future<List<dynamic>> getMenu() async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/api_menu.php"));
      return _safeDecodeList(response.body); // ← diganti
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> tambahMenu(
      String nama, String kategori, int harga, int stok, String deskripsi, var imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/api_menu.php"));

      request.fields['nama_produk'] = nama;
      request.fields['kategori']    = kategori;
      request.fields['harga']       = harga.toString();
      request.fields['stok']        = stok.toString();
      request.fields['deskripsi']   = deskripsi;

      if (imageFile != null) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'gambar',
          bytes,
          filename: imageFile.name,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // PERBAIKAN: cek status code dulu, lalu decode dengan aman
      if (response.statusCode != 200) {
        return {"status": "error", "pesan": "Server Error: ${response.statusCode}"};
      }

      return _safeDecodeMap(response.body); // ← diganti (ini inti perbaikannya)
    } catch (e) {
      return {"status": "error", "pesan": "Gagal mengirim data: $e"};
    }
  }

  // ==========================================
  // 3. FUNGSI KERANJANG
  // ==========================================
  static Future<List<dynamic>> getKeranjang(String idUser) async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/api_keranjang.php?id_user=$idUser"));
      return _safeDecodeList(response.body); // ← diganti
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> tambahKeranjang(String idUser, String idMenu, int jumlah) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/api_keranjang.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_user": idUser, "id_menu": idMenu, "jumlah": jumlah}),
      );
      return _safeDecodeMap(response.body); // ← diganti
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  // ==========================================
  // 4. FUNGSI PESANAN & CHECKOUT
  // ==========================================
  static Future<List<dynamic>> getPesanan({String? idUser}) async {
    try {
      String url = "$baseUrl/api_pesanan.php";
      if (idUser != null && idUser.isNotEmpty) url += "?id_user=$idUser";
      var response = await http.get(Uri.parse(url));
      return _safeDecodeList(response.body); // ← diganti
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
      return _safeDecodeMap(response.body); // ← diganti
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  // ==========================================
  // 5. FUNGSI PROFIL PENGGUNA
  // ==========================================
  static Future<Map<String, dynamic>> getProfil(String idUser) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/get_profil.php'),
        body: {'id_user': idUser},
      );
      return _safeDecodeMap(response.body); // ← diganti
    } catch (e) {
      return {'status': 'error', 'pesan': 'Gagal koneksi ke server: $e'};
    }
  }
}