import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // PENTING: Menggunakan 127.0.0.1 sebagai pengganti localhost 
  // agar terhindar dari pemblokiran CORS (Failed to fetch) di Google Chrome
  static const String baseUrl = "http://127.0.0.1/api_puddingku";

  // ==========================================
  // 1. FUNGSI OTENTIKASI (LOGIN, REGISTER, RESET)
  // ==========================================
  static Future<Map<String, dynamic>> registerUser(
      String nama, String username, String phone, String password) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: {
          "nama": nama,
          "username": username,
          "phone": phone,
          "password": password,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {
          "username": username,
          "password": password,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String phone, {String? newPassword}) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/reset_password.php"),
        body: {
          "phone": phone,
          "new_password": newPassword ?? "", 
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  // ==========================================
  // 2. FUNGSI MENU / PRODUK
  // ==========================================
  
  // Mengambil daftar produk untuk User dan Admin
  static Future<List<dynamic>> getMenu() async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/api_menu.php"));
      return jsonDecode(response.body);
    } catch (e) {
      print("Error getMenu: $e");
      return []; // Kembalikan list kosong jika error
    }
  }

  // ==============================================================
  // UPDATE BARU: Fungsi tambahMenu menggunakan MultipartRequest
  // Agar bisa mengirim Teks dan File Gambar sekaligus!
  // ==============================================================
  static Future<Map<String, dynamic>> tambahMenu(
      String nama, String kategori, int harga, int stok, String deskripsi, var imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/api_menu.php"));
      
      // 1. Masukkan data teks ke dalam body request
      request.fields['nama_produk'] = nama;
      request.fields['kategori'] = kategori;
      request.fields['harga'] = harga.toString();
      request.fields['stok'] = stok.toString();
      request.fields['deskripsi'] = deskripsi;

      // 2. Masukkan data gambar (jika ada file yang di-upload)
      if (imageFile != null) {
        var bytes = await imageFile.readAsBytes();
        var multipartFile = http.MultipartFile.fromBytes(
          'gambar', // Nama form ini HARUS sama dengan $_FILES['gambar'] di PHP
          bytes,
          filename: imageFile.name,
        );
        request.files.add(multipartFile);
      }

      // 3. Kirim request ke server
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      // Jika server PHP-mu ada pesan error tak terduga (bukan JSON), tangkap di sini
      if (response.statusCode != 200) {
         return {"status": "error", "pesan": "Server Error: ${response.statusCode}"};
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal mengirim data: $e"};
    }
  }

  // ==========================================
  // 3. FUNGSI KERANJANG
  // ==========================================
  
  // Mengambil isi keranjang milik user tertentu
  static Future<List<dynamic>> getKeranjang(String idUser) async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/api_keranjang.php?id_user=$idUser"));
      return jsonDecode(response.body);
    } catch (e) {
      print("Error getKeranjang: $e");
      return [];
    }
  }

  // Menambahkan produk ke keranjang
  static Future<Map<String, dynamic>> tambahKeranjang(String idUser, String idMenu, int jumlah) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/api_keranjang.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": idUser,
          "id_menu": idMenu,
          "jumlah": jumlah,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }

  // ==========================================
  // 4. FUNGSI PESANAN & CHECKOUT
  // ==========================================
  
  // Mengambil riwayat pesanan (Jika idUser null, akan menarik SEMUA pesanan untuk Admin)
  static Future<List<dynamic>> getPesanan({String? idUser}) async {
    try {
      String url = "$baseUrl/api_pesanan.php";
      if (idUser != null && idUser.isNotEmpty) {
        url += "?id_user=$idUser";
      }
      var response = await http.get(Uri.parse(url));
      return jsonDecode(response.body);
    } catch (e) {
      print("Error getPesanan: $e");
      return [];
    }
  }

  // Proses Checkout pesanan
  static Future<Map<String, dynamic>> checkout(String idUser, int totalHarga, List<dynamic> items, String metode) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/api_pesanan.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": idUser,
          "total_harga": totalHarga,
          "metode_pembayaran": metode,
          "items": items, // List keranjang dikirim sekaligus
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }
}