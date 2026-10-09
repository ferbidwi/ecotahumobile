import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Warna sesuai referensi gambar
  static const Color darkGreen = Color(0xFF1A3C34);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color creamBg = Color(0xFFF9F9F5);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textGrey = Color(0xFF7F8C8D);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: creamBg,
      primaryColor: darkGreen,
      colorScheme: ColorScheme.fromSeed(seedColor: darkGreen),
      textTheme: GoogleFonts.poppinsTextTheme(), // Menggunakan font Poppins
      appBarTheme: const AppBarTheme(
        backgroundColor: creamBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}