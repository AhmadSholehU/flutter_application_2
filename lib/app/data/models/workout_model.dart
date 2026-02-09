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
  List<WorkoutSet> setDetails;
  // Kita juga simpan data agregat (yang sudah dihitung) agar mudah ditampilkan
  double totalVolume;
  int sets; // Ini adalah jumlah set (setDetails.length)
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

  // 1. Convert Object -> Map (untuk Simpan ke Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'createdAt': createdAt,
      // Color disimpan sebagai integer (ARGB)
      'indicatorColor': indicatorColor.value,
      'totalVolume': totalVolume,
      'sets': sets,
      // List<WorkoutSet> harus diubah jadi List<Map>
      'setDetails': setDetails.map((s) => s.toMap()).toList(),
    };
  }

  // 2. Convert Map -> Object (untuk Baca dari Firebase)
  factory Workout.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Workout(
      id: docId ?? '',
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      // Ambil integer dan ubah jadi Color
      indicatorColor: Color(map['indicatorColor'] ?? 0xFF4AD0B2),
      totalVolume: (map['totalVolume'] ?? 0).toDouble(),
      sets: map['sets'] ?? 0,
      // Ubah List<Map> kembali jadi List<WorkoutSet>
      setDetails: (map['setDetails'] as List<dynamic>? ?? [])
          .map((item) => WorkoutSet.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
