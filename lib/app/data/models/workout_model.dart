import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/data/models/workout_set_model.dart';

class Workout {
  final String? id;
  final String name;
  final String muscleGroup;
  final Timestamp createdAt;
  final Color indicatorColor;

  // --- PERUBAHAN INTI ---
  // Kita simpan detail dari setiap set
  final List<WorkoutSet> setDetails;
  // Kita juga simpan data agregat (yang sudah dihitung) agar mudah ditampilkan
  final double totalVolume;
  final int sets; // Ini adalah jumlah set (setDetails.length)
  // -----------------------

  Workout({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.createdAt,
    required this.indicatorColor,
    required this.setDetails,
    required this.totalVolume,
    required this.sets,
  });

  // Method untuk mengubah objek Workout menjadi Map (untuk dikirim ke Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'createdAt': createdAt,
      'indicatorColor': indicatorColor.value,
      'totalVolume': totalVolume, // Simpan total volume
      'sets': sets, // Simpan jumlah set
      // Simpan list of sets sebagai array of maps
      'setDetails': setDetails.map((s) => s.toJson()).toList(),
    };
  }

  // Factory constructor untuk membuat objek Workout dari dokumen Firestore
  factory Workout.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Workout(
      id: snapshot.id,
      name: data['name'],
      muscleGroup: data['muscleGroup'],
      createdAt: data['createdAt'],
      indicatorColor: Color(data['indicatorColor']),
      totalVolume: (data['totalVolume'] as num).toDouble(),
      sets: data['sets'] as int,
      // Ubah array of maps kembali menjadi List<WorkoutSet>
      setDetails: (data['setDetails'] as List)
          .map((item) => WorkoutSet.fromJson(item))
          .toList(),
    );
  }
}
