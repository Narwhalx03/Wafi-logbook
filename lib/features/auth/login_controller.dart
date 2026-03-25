import 'dart:async';

class LoginController {
  final List<Map<String, dynamic>> _userDatabase = [
    {
      "username": "admin",
      "password": "123",
      "uid": "U001",
      "role": "Ketua",
      "teamId": "T01",
    },
    {
      "username": "wafi",
      "password": "polban2026",
      "uid": "U002",
      "role": "Anggota",
      "teamId": "T01",
    },
    {
      "username": "user1",
      "password": "password123",
      "uid": "U003",
      "role": "Anggota",
      "teamId": "T02",
    },
  ];

  int _loginAttempts = 0;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  Map<String, dynamic>? authenticate(String username, String password) {
    if (username.isEmpty || password.isEmpty) return null;

    if (_isLocked) return null;

    try {
      // Mencari user di database lokal
      final user = _userDatabase.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
      );
      _loginAttempts = 0;
      return user;
    } catch (e) {
      _loginAttempts++;
      return null;
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
