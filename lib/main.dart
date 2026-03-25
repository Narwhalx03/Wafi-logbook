import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_029/features/logbook/models/log_model.dart';
import 'package:logbook_app_029/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_029/services/mongo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("Environment loaded successfully");

    await Hive.initFlutter();

    Hive.registerAdapter(LogModelAdapter());

    await Hive.openBox<LogModel>('offline_logs');
    print("Hive initialized & box opened");

    await MongoService().connect().timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          print("MongoDB connection timeout, entering offline mode."),
    );
    print("MongoDB connection established");
  } catch (e) {
    print("Gagal inisialisasi sistem: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogBook Collaborative 029',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const OnboardingView(),
    );
  }
}
