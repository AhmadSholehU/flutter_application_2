import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart';

class DateScroller extends GetView<HomeController> {
  const DateScroller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Buat daftar 7 hari terakhir
    final List<DateTime> days = List.generate(
      7,
      (index) => DateTime.now().subtract(Duration(days: index)),
    ).reversed.toList();

    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        // 1. Kita ubah menjadi Row
        children: [
          // 2. TAMBAHKAN TOMBOL KALENDER BARU
          _buildCalendarButton(context),

          // 3. DAFTAR TANGGAL (SEPERTI SEBELUMNYA)
          Expanded(
            // Pastikan ListView mengambil sisa ruang
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              reverse: true,
              itemBuilder: (context, index) {
                final day = days[index];
                return _buildDateItem(day); // Kita pindah ke method terpisah
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol kalender
  Widget _buildCalendarButton(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          _showCalendar(context), // Panggil method untuk menampilkan kalender
      child: Container(
        width: 55, // Lebar tombol
        height: double.infinity,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF232d37).withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.calendar_month_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // Logika untuk menampilkan kalender
  void _showCalendar(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          controller.selectedDate.value, // Mulai dari tanggal yg dipilih
      firstDate: DateTime(2020), // Tanggal paling awal
      lastDate: DateTime.now(), // Tanggal paling akhir (hari ini)
      builder: (context, child) {
        // Opsi: Memberi tema pada kalender agar sesuai tema gelap kita
        return Theme(
          data: Get.theme.copyWith(
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: Get.theme.colorScheme.primary, // Warna highlight
              onPrimary: Colors.black, // Teks pada warna highlight
            ),
            dialogBackgroundColor: Get.theme.colorScheme.surface,
          ),
          child: child!,
        );
      },
    );

    // Jika pengguna memilih tanggal (tidak menekan 'Cancel')
    if (pickedDate != null && pickedDate != controller.selectedDate.value) {
      // Panggil method di HomeController untuk mengubah tanggal
      controller.changeSelectedDate(pickedDate);
    }
  }

  // Widget untuk item tanggal (logika yang ada sebelumnya)
  Widget _buildDateItem(DateTime day) {
    final String dayName = DateFormat('E').format(day); // "Sel"
    final String dayNum = DateFormat('d').format(day); // "29"

    return Obx(() {
      bool isSelected =
          controller.selectedDate.value.day == day.day &&
          controller.selectedDate.value.month == day.month &&
          controller.selectedDate.value.year == day.year;

      return GestureDetector(
        onTap: () => controller.changeSelectedDate(day),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Get.theme.colorScheme.primary
                : const Color(0xFF232d37).withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dayNum,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
