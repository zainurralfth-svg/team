import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Gunakan localhost jika di Web/Windows, gunakan 10.0.2.2 jika di Emulator Android
  static const String baseUrl = "http://192.168.0.107/api_puddingku";

  // 1. FUNGSI REGISTER
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

  // 2. FUNGSI LOGIN
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

  // 3. FUNGSI RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword(String phone, {String? newPassword}) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/reset_password.php"),
        body: {
          "phone": phone,
          "new_password": newPassword ?? "", // Kirim kosong jika hanya untuk cek nomor
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "pesan": "Gagal terhubung ke server: $e"};
    }
  }
}