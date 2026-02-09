import 'package:flutter_application_2/app/ui/pages/auth/login_page.dart';
import 'package:flutter_application_2/app/ui/pages/auth/splash_page.dart';
import 'package:flutter_application_2/app/ui/pages/data/data_binding.dart';
import 'package:flutter_application_2/app/ui/pages/data/data_page.dart';
import 'package:flutter_application_2/app/ui/pages/exercise/exercise_list_binding.dart';
import 'package:flutter_application_2/app/ui/pages/exercise/exercise_list_page.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/ui/pages/dashboard/dashboard_binding.dart';
import 'package:flutter_application_2/app/ui/pages/dashboard/dashboard_page.dart';
import 'package:flutter_application_2/app/routes/app_routes.dart';
import 'package:flutter_application_2/app/ui/pages/home/detail/workout_detail_binding.dart';
import 'package:flutter_application_2/app/ui/pages/home/detail/workout_detail_page.dart';

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
    GetPage(
      // <-- TAMBAHKAN BLOK INI
      name: Routes.WORKOUT_DETAIL,
      page: () => WorkoutDetailPage(),
      binding: WorkoutDetailBinding(),
      transition: Transition.rightToLeftWithFade, // Transisi estetik
    ),

    GetPage(
      name: '/exercise-list', // Sesuaikan dengan nama route Anda
      page: () => ExerciseListPage(),
      binding: ExerciseListBinding(), // <--- PASANG BINDING DI SINI
    ),

    GetPage(
      name:
          '/data', // Sesuaikan nama route Anda (misal '/analytics' atau '/data')
      page: () => DataPage(),
      binding: DataBinding(), // <--- Tambahkan ini
    ),
  ];
}
