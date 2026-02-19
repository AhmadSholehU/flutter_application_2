import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/routes/app_pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'package:flutter_application_2/app/ui/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart';
import 'package:flutter_application_2/app/controllers/auth_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // Pastikan semua widget Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Inisialisasi env
  await dotenv.load(fileName: ".env");
  Get.put(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan GetMaterialApp agar bisa memakai semua fitur GetX
    return GetMaterialApp(
      title: 'Fitness Tracker',
      theme: AppTheme.darkTheme, // Menerapkan tema gelap yang akan kita buat
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // --- 2. TAMBAHKAN PROPERTI DI BAWAH INI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id'), // Mendukung Bahasa Indonesia
        Locale('en'), // Mendukung Bahasa Inggris (default)
      ],
      // ----------------------------------------
    );
  }
}
