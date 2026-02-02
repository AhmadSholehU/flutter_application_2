import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart';
import 'package:flutter_application_2/app/data/models/exercise_model.dart';
import 'package:flutter_application_2/app/data/models/workout_set_model.dart';
import 'package:flutter_application_2/app/ui/widgets/exercise_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NewAddWorkoutSheet extends StatefulWidget {
  final Exercise? exercise; // Data dari ExerciseDB
  final bool isCustom;
  const NewAddWorkoutSheet({Key? key, this.exercise, this.isCustom = false})
    : super(key: key);

  @override
  State<NewAddWorkoutSheet> createState() => _NewAddWorkoutSheetState();
}

class _NewAddWorkoutSheetState extends State<NewAddWorkoutSheet> {
  final HomeController _homeController = Get.find<HomeController>();
  // Controller baru untuk input nama custom exercise
  final TextEditingController _customNameController = TextEditingController();
  // State UI
  int selectedReps = 10;
  double currentVolume = 50.0;
  List<WorkoutSet> addedSets = [];

  // Controller untuk Horizontal Scroll Reps
  late PageController _repsController;
  String _selectedMuscleGroup = "Chest"; // Nilai default

  final List<String> _muscleGroups = [
    "Chest",
    "Back",
    "Shoulders",
    "Biceps",
    "Triceps",
    "Legs",
    "Abs",
    "Forearms",
    "Calves",
  ];
  @override
  void initState() {
    super.initState();
    // Inisialisasi ke index 10 (reps 10)
    _repsController = PageController(viewportFraction: 0.2, initialPage: 10);
  }

  void _addSet() {
    setState(() {
      addedSets.add(WorkoutSet(reps: selectedReps, weight: currentVolume));
    });
  }

  Future<void> _saveToFirebase() async {
    if (addedSets.isEmpty) return;

    // Validasi nama untuk custom exercise
    if (widget.isCustom && _customNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter exercise name");
      return;
    }

    try {
      // Tentukan nama latihan berdasarkan mode
      final String exerciseName = widget.isCustom
          ? _customNameController.text.trim()
          : widget.exercise!.name.capitalizeFirst!;

      // Tentukan muscle group (default 'Custom' jika mode custom)
      final String muscleGroup = widget.isCustom
          ? _selectedMuscleGroup.toUpperCase()
          : (widget.exercise!.targetMuscles.isNotEmpty
                ? widget.exercise!.targetMuscles.first
                : 'General');

      await _homeController.addWorkout(
        name: exerciseName,
        muscleGroup: muscleGroup,
        sets: addedSets,
      );
      Get.close(1);
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Langkah 1: Tambahkan padding dinamis agar konten terdorong ke atas saat keyboard muncul
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        // Langkah 2: Gunakan SingleChildScrollView agar area bisa digulir jika space sempit
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle/Garis atas sheet
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Add New Workout",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (widget.isCustom)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.grey,
                    size: 40,
                  ), // Placeholder icon
                )
              else
                ExerciseImage(imageUrl: widget.exercise!.imageUrl, size: 100),
              const SizedBox(height: 10),
              if (widget.isCustom)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _customNameController,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter exercise name",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                )
              else
                Text(
                  widget.exercise!.name.capitalizeFirst!,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
              const SizedBox(height: 30),
              if (widget.isCustom) ...[
                const SizedBox(height: 15),
                Text(
                  "Select Target Muscle",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _muscleGroups.length,
                    itemBuilder: (context, index) {
                      final muscle = _muscleGroups[index];
                      final isSelected = _selectedMuscleGroup == muscle;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(muscle),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedMuscleGroup = muscle);
                          },
                          selectedColor: const Color(0xFF4AD0B2), // Warna teal
                          backgroundColor: const Color(0xFF2C2C2E),
                          labelStyle: GoogleFonts.poppins(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
              // 2. Reps Picker (Horizontal Scroll)
              Text(
                "Reps",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(
                height: 80,
                child: PageView.builder(
                  controller: _repsController,
                  onPageChanged: (index) =>
                      setState(() => selectedReps = index),
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedReps == index;
                    return Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: GoogleFonts.poppins(
                          fontSize: isSelected ? 32 : 24,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Get.theme.colorScheme.primary
                              : Colors.grey.withOpacity(0.5),
                        ),
                        child: Text("$index"),
                      ),
                    );
                  },
                ),
              ),

              // 3. Volume Slider
              Text(
                "Volume",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "${currentVolume.toInt()}",
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Kg",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    // Tombol Minus
                    IconButton(
                      onPressed: () {
                        if (currentVolume > 0) {
                          setState(() => currentVolume--);
                        }
                      },
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.white70,
                        size: 28,
                      ),
                    ),
                    // Slider di tengah
                    Expanded(
                      child: Slider(
                        value: currentVolume,
                        min: 0,
                        max: 300,
                        activeColor: Get.theme.colorScheme.primary,
                        inactiveColor: Colors.grey[800],
                        onChanged: (val) => setState(() => currentVolume = val),
                      ),
                    ),
                    // Tombol Plus
                    IconButton(
                      onPressed: () {
                        if (currentVolume < 300) {
                          setState(() => currentVolume++);
                        }
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white70,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Sets",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),

              // 4. Sets List (Muncul jika ada set yang ditambahkan)
              if (addedSets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: addedSets
                          .map(
                            (set) => Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                border: Border.all(
                                  color: Get.theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${set.weight.toInt()}kg x ${set.reps}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // 5. Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addSet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Add Set",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: addedSets.isEmpty
                            ? null
                            : () {
                                _saveToFirebase(); // Tutup sheet dan list page
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Save",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customNameController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }
}
