import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _step = 1;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Selamat Datang!",
      "desc": "Pantau aktivitas harianmu dengan sistem Logbook digital.",
      "img": "https://cdn-icons-png.flaticon.com/512/2666/2666469.png",
    },
    {
      "title": "Aman & Personal",
      "desc": "Setiap user memiliki catatan history yang tersimpan rapi.",
      "img": "https://cdn-icons-png.flaticon.com/512/1160/1160358.png",
    },
    {
      "title": "Mulai Sekarang",
      "desc": "Siap untuk mengelola progress kamu hari ini?",
      "img": "https://cdn-icons-png.flaticon.com/512/1533/1533913.png",
    },
  ];

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          // Gunakan Stack agar bisa menaruh tombol Skip di atas
          children: [
            if (_step < 3)
              Positioned(
                top: 20,
                right: 20,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    "Lewati",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gunakan AnimatedSwitcher agar transisi gambar lebih halus
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Image.network(
                      _onboardingData[_step - 1]["img"]!,
                      key: ValueKey<int>(_step),
                      height: 250,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _onboardingData[_step - 1]["title"]!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _onboardingData[_step - 1]["desc"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 50),
                  // Indikator Titik
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(4),
                        width: _step == (index + 1)
                            ? 20
                            : 10, // Titik aktif lebih panjang
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _step == (index + 1)
                              ? Colors.blueAccent
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_step < 3) {
                        setState(() => _step++);
                      } else {
                        _finishOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(_step == 3 ? "MULAI LOGIN" : "LANJUT"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
