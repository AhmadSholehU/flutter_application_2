import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hanya menampilkan loading indicator. AuthController akan menangani navigasi.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
