import 'user.dart';

class Karyawan extends User {
  Karyawan(int id, String username, String password) 
      : super(id, username, password);

  @override
  void login() {
    print("LOG OOP: Karyawan ${getUsername()} berhasil login ke Dashboard Admin.");
  }
}