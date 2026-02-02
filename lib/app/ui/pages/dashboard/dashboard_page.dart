import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/ui/pages/ai/ai_page.dart';
import 'package:flutter_application_2/app/ui/pages/exercise/exercise_list_page.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_2/app/ui/pages/home/home_page.dart';
import 'package:get/get.dart';

import 'package:flutter_application_2/app/controllers/dashboard_controller.dart';
import 'package:flutter_application_2/app/ui/pages/data/data_page.dart';
import 'package:flutter_application_2/app/ui/pages/profile/profile_page.dart';

class DashboardPage extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [HomePage(), DataPage(), AiPage(), ProfilePage()],
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        margin: const EdgeInsets.only(
          left: 60,
          right: 60,
          bottom: 30,
        ), // Membuat efek melayang dan pendek
        decoration: BoxDecoration(
          color: const Color(
            0xFF1C1C1E,
          ).withOpacity(0.9), // Warna gelap dengan sedikit transparansi
          borderRadius: BorderRadius.circular(30), // Membuat bentuk kapsul/pill
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                iconPath: 'assets/icons/ic_home.svg',
                isSelected: controller.tabIndex.value == 0,
              ),
              _buildNavItem(
                index: 1,
                iconPath: 'assets/icons/ic_data.svg',
                isSelected: controller.tabIndex.value == 1,
              ),

              _buildAddButton(),

              _buildNavItem(
                index: 2,
                iconPath: 'assets/icons/ic_ai.svg',
                isSelected: controller.tabIndex.value == 2,
              ),

              _buildNavItem(
                index: 3,
                iconPath: 'assets/icons/ic_user.svg',
                isSelected: controller.tabIndex.value == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        Get.to(() => ExerciseListPage());
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isSelected ? Get.theme.colorScheme.primary : Colors.grey,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
