import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/app/controllers/auth_controller.dart';
import 'package:flutter_application_2/app/ui/pages/auth/login_page.dart';
import 'package:flutter_application_2/app/ui/pages/dashboard/dashboard_page.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Inisialisasi AuthController di sini agar bisa diakses di seluruh app
    final AuthController authController = Get.put(AuthController());

    return Obx(() {
      // Dengarkan perubahan pada user. Jika ada (tidak null), user sudah login.
      if (authController.user != null) {
        return DashboardPage();
      } else {
        return LoginPage();
      }
    });
  }
}
