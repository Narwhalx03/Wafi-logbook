import 'dart:async';

class LoginController {
  final Map<String, String> _users = {
    "admin": "123",
    "wafi": "polban2026",
    "user1": "password123",
  };

  int _loginAttempts = 0;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  String? validateLogin(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return "Username dan Password tidak boleh kosong!";
    }

    if (_isLocked) return "Akun terkunci sementara. Tunggu 10 detik.";

    if (_users.containsKey(username) && _users[username] == password) {
      _loginAttempts = 0;
      return null;
    } else {
      _loginAttempts++;
      return "Username atau Password salah!";
    }
  }

  void checkLockout(Function onLock, Function onUnlock) {
    if (_loginAttempts >= 3) {
      _isLocked = true;
      onLock();

      Timer(const Duration(seconds: 10), () {
        _isLocked = false;
        _loginAttempts = 0;
        onUnlock();
      });
    }
  }
}
