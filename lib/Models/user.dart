import '../Backend/API_Service.dart';
import 'karyawan.dart';
import 'customer.dart';

abstract class User {
  int _id;
  String _username;
  String _password;

  User(this._id, this._username, this._password);

  int getId() => _id;
  String getUsername() => _username;

  // Method abstrak wajib dari Class Diagram
  void login();

  // =========================================================
  // FUNGSI MURNI OOP: MENGGANTIKAN API_SERVICE DI LAYAR LOGIN
  // =========================================================
  static Future<Map<String, dynamic>> autentikasiOOP(String username, String password) async {
    // 1. Class User yang diam-diam memanggil XAMPP/API
    var hasil = await ApiService.loginUser(username, password);

    if (hasil['status'] == 'sukses') {
      String roleUser = hasil['role'] ?? 'user';
      int idUser = int.tryParse(hasil['id']?.toString() ?? '0') ?? 0;

      User penggunaAktif;

      // 2. Class User mencetak Class Anak secara otomatis (Instansiasi & Inheritance)
      if (roleUser == 'admin') {
        penggunaAktif = Karyawan(idUser, username, password);
      } else {
        penggunaAktif = Customer(idUser, username, password);
      }

      // 3. Menjalankan perilaku method sesuai wujud aslinya (Polymorphism)
      penggunaAktif.login();

      // 4. Mengembalikan data yang sudah rapi ke Layar UI
      return {
        'status': 'sukses',
        'pesan': hasil['pesan'],
        'role': roleUser,
        'id': idUser.toString(),
        'nama' : hasil['nama'],
        'phone' : hasil['phone']
      };
    } else {
      return hasil; // Kembalikan error ke layar UI
    }
  }
}