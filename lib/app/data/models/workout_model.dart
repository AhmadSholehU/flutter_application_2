import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String? id;
  final String name;
  final String muscleGroup;
  final double totalVolume;
  final int sets;
  final Color indicatorColor;
  final Timestamp createdAt;

  Workout({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.totalVolume,
    required this.sets,
    required this.indicatorColor,
    required this.createdAt,
  });

  // Method untuk mengubah objek Workout menjadi Map (untuk dikirim ke Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'totalVolume': totalVolume,
      'sets': sets,
      // Kita simpan warna sebagai integer
      'indicatorColor': indicatorColor.value,
      'createdAt': createdAt,
    };
  }

  // Factory constructor untuk membuat objek Workout dari dokumen Firestore
  factory Workout.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Workout(
      id: snapshot.id, // Ambil ID dokumen
      name: data['name'],
      muscleGroup: data['muscleGroup'],
      totalVolume: data['totalVolume'],
      sets: data['sets'],
      // Ubah integer kembali menjadi Color
      indicatorColor: Color(data['indicatorColor']),
      createdAt: data['createdAt'],
    );
  }
}
