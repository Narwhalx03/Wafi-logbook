import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
// 1. Tambahkan import log_view agar bisa dikenali
import 'package:logbook_app_001/features/logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _loginController = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscureText = true;
  bool _isButtonDisabled = false;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final String user = _userController.text.trim();
    final String pass = _passController.text.trim();

    String? error = _loginController.validateLogin(user, pass);

    if (error == null) {
      if (!mounted) return;

      // 2. Ubah Navigasi ke LogPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LogPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _loginController.checkLockout(
        () => setState(() => _isButtonDisabled = true),
        () => setState(() => _isButtonDisabled = false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isButtonDisabled ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isButtonDisabled ? "TERKUNCI (10s)" : "MASUK",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
