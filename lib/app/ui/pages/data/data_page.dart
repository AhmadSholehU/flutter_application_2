import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Text(
          'Halaman untuk progress yang lalu',
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
