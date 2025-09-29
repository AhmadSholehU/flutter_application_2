import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1C1C1E),
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD0FD3E), // Warna aksen utama (hijau terang)
      secondary: Colors.white,
      background: Color(0xFF1C1C1E),
      surface: Color(0xFF2C2C2E), // Warna untuk card
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
  );
}
