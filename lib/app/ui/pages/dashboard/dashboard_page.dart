import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/ui/pages/home/home_page.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/app/controllers/dashboard_controller.dart';
import 'package:flutter_application_2/app/ui/pages/data/data_page.dart';
import 'package:flutter_application_2/app/ui/pages/profile/profile_page.dart';

class DashboardPage extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai tab yang dipilih
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [HomePage(), DataPage(), ProfilePage()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          onTap: controller.changeTabIndex,
          currentIndex: controller.tabIndex.value,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF1C1C1E),
          selectedItemColor: Get.theme.colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Data'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
