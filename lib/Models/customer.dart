import 'user.dart';

class Customer extends User {
  Customer(int id, String username, String password) 
      : super(id, username, password);

  @override
  void login() {
    print("LOG OOP: Customer ${getUsername()} berhasil masuk ke Menu Puddingku.");
  }
}