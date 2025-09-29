import 'package:flutter_application_2/app/ui/pages/auth/login_page.dart';
import 'package:flutter_application_2/app/ui/pages/auth/splash_page.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/ui/pages/dashboard/dashboard_binding.dart';
import 'package:flutter_application_2/app/ui/pages/dashboard/dashboard_page.dart';
import 'package:flutter_application_2/app/routes/app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH; // Rute awal adalah SplashPage

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashPage(), // Halaman Splash
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginPage(), // Halaman Login
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardPage(),
      binding: DashboardBinding(), // Penting! Kita kembalikan binding di sini
    ),
  ];
}
