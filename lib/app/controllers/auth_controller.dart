import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // .obs membuat user menjadi stream yang bisa didengarkan perubahannya
  final Rxn<User> firebaseUser = Rxn<User>();

  // Getter untuk mengakses user dari luar controller
  User? get user => firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    // Mendengarkan perubahan status autentikasi user secara real-time
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  // Method yang akan dipanggil oleh listener 'ever'
  _setInitialScreen(User? user) {
    // Beri sedikit jeda agar proses transisi lebih mulus
    Future.delayed(const Duration(milliseconds: 200), () {
      if (user == null) {
        // Jika user logout atau belum login, arahkan ke LoginPage
        Get.offAllNamed(Routes.LOGIN);
      } else {
        // Jika user berhasil login, arahkan ke Dashboard
        Get.offAllNamed(Routes.DASHBOARD);
      }
    });
  }

  // Method untuk membuat user baru (Register)
  Future<void> createUser(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error creating account",
        e.message ?? "Unknown error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method untuk login user
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error signing in",
        e.message ?? "Unknown error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method untuk logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
