import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/controllers/add_workout_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_2/app/controllers/workout_detail_controller.dart';
import 'package:flutter_application_2/app/ui/pages/home/widgets/summary_card.dart'; // Kita pakai ulang

class WorkoutDetailPage extends GetView<WorkoutDetailController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bungkus dengan Container bergradien agar identik dengan DataPage
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2A3A), // Biru tua di atas
              Color(0xFF121212), // Hitam di bawah
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header: Nama & Grup Otot ---
                Text(
                  controller.workout.muscleGroup.capitalizeFirst ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  controller.workout.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat(
                    'EEEE, d MMMM y',
                  ).format(controller.workout.createdAt.toDate()),
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // --- Stat Rangkuman (Estetik) ---
                _buildStatCards(),

                const SizedBox(height: 24),
                Divider(color: Colors.grey[800]),
                const SizedBox(height: 16),

                // --- Bagian Detail Set (Dinamis) ---
                Text(
                  "SET DETAILS",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  // Tampilan berubah berdasarkan mode isEditing
                  if (controller.isEditing.value) {
                    return _buildEditView();
                  } else {
                    return _buildReadView();
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AppBar yang dinamis
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Obx(
        () => Text(
          controller.isEditing.value ? "Edit Workout" : "Workout Detail",
        ),
      ),
      actions: [
        Obx(() {
          if (controller.isEditing.value) {
            // Jika mode edit: Tampilkan tombol "Save"
            return IconButton(
              icon: const Icon(Icons.save, color: Color(0xFFD0FD3E)),
              onPressed: controller.saveChanges,
            );
          } else {
            // Jika mode baca: Tampilkan "Edit" dan "Delete"
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: controller.toggleEditMode,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: controller.confirmDeleteWorkout,
                ),
              ],
            );
          }
        }),
      ],
      // Tombol 'Back' juga akan menangani pembatalan mode edit
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (controller.isEditing.value) {
            controller.toggleEditMode(); // Batalkan edit
          } else {
            Get.back(); // Kembali
          }
        },
      ),
    );
  }

  // Tampilan set saat mode "Baca"
  Widget _buildReadView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.workout.setDetails.length,
      itemBuilder: (context, index) {
        final set = controller.workout.setDetails[index];
        return ListTile(
          leading: Text(
            "${index + 1}",
            style: GoogleFonts.poppins(
              color: Get.theme.colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          title: Text(
            "${set.weight} kg",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Text(
            "${set.reps} Reps",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),
          dense: true,
        );
      },
    );
  }

  // Tampilan set saat mode "Edit"
  Widget _buildEditView() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.setEntries.length,
          itemBuilder: (context, index) {
            final entry = controller.setEntries[index];
            // Kita pakai ulang UI dari 'AddWorkoutSheet'
            return _buildSetRow(entry, index);
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.addNewSet,
            icon: const Icon(Icons.add),
            label: const Text("Add Set"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.surface,
              side: BorderSide(color: Colors.grey[700]!),
            ),
          ),
        ),
      ],
    );
  }

  // Helper UI untuk baris set di mode Edit
  Widget _buildSetRow(SetEntryControllers entry, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Text(
            "${index + 1}",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: entry.reps,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Reps"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: entry.weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => controller.removeSet(index),
          ),
        ],
      ),
    );
  }

  // Helper UI untuk 3 kartu stat
  Widget _buildStatCards() {
    // 1. Ganti Obx dengan GetBuilder
    return GetBuilder<WorkoutDetailController>(
      builder: (controller) {
        // 2. Logika Avg Reps dipindahkan ke sini
        final totalReps = controller.workout.setDetails.fold(
          0,
          (sum, set) => sum + set.reps,
        );
        final totalSets = controller.workout.sets;
        // 3. Hindari error pembagian dengan nol
        final avgReps = (totalSets == 0) ? 0.0 : (totalReps / totalSets);

        return Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Volume',
                value: "${controller.workout.totalVolume.toStringAsFixed(0)}kg",
                icon: 'assets/icons/ic_wo.svg',
                backgroundColor: const Color(0xFF232D37).withOpacity(0.7),
                iconColor: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Total Sets',
                value: controller.workout.sets.toString(),
                icon: 'assets/icons/ic_set.svg',
                backgroundColor: const Color(0xFF232D37).withOpacity(0.7),
                iconColor: Colors.orangeAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Avg Reps',
                value: avgReps.toStringAsFixed(1),
                icon: 'assets/icons/ic_rep.svg',
                backgroundColor: const Color(0xFF232D37).withOpacity(0.7),
                iconColor: Colors.greenAccent,
              ),
            ),
          ],
        );
      },
    );
  }
}
