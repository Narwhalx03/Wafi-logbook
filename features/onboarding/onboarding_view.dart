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

  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(_onboardingData[_step - 1]["img"]!, height: 250),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.all(4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _step == (index + 1)
                          ? Colors.blueAccent
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _nextStep,
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
      ),
    );
  }
}
