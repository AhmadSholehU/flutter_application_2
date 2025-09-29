import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/app/controllers/home_controller.dart';

class AddWorkoutSheet extends StatefulWidget {
  @override
  _AddWorkoutSheetState createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  final HomeController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _muscleController = TextEditingController();
  final _volumeController = TextEditingController();
  final _setsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _muscleController.dispose();
    _volumeController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add New Workout",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name (e.g., Bench Press)',
                ),
                validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _muscleController,
                decoration: const InputDecoration(
                  labelText: 'Muscle Group (e.g., Chest)',
                ),
                validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _volumeController,
                decoration: const InputDecoration(
                  labelText: 'Total Volume (kg)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _setsController,
                decoration: const InputDecoration(labelText: 'Number of Sets'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.addWorkout(
                        name: _nameController.text,
                        muscleGroup: _muscleController.text,
                        totalVolume: double.parse(_volumeController.text),
                        sets: int.parse(_setsController.text),
                      );
                    }
                  },
                  child: Text(
                    'Save Workout',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
