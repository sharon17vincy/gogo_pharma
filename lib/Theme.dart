import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme = ThemeData(
  primaryColor: Colors.orange,
  primaryColorDark: const Color(0xFF1a237e),
  brightness: Brightness.dark,
);

const borderColor = Color(0xFFF1F1F1);
const Color backgroundColor = Color(0xFFF0F2F9);



TextStyle titleNormalStyle = GoogleFonts.rubik(
  color: Colors.black,
  fontSize: 24,
  fontWeight: FontWeight.w300,
);

TextStyle titleNormalBoldStyle = GoogleFonts.rubik(
  color: Colors.black,
  fontSize: 20,
  fontWeight: FontWeight.w400,
);

TextStyle titleStyle = GoogleFonts.rubik(
  color: Colors.black,
  fontSize: 36,
  fontWeight: FontWeight.w400,
);

TextStyle titleSemiBoldStyle = GoogleFonts.rubik(
  color: Colors.black,
  fontSize: 36,
  fontWeight: FontWeight.w600,
);


TextStyle normalStyle = GoogleFonts.rubik(
  color: Colors.black,
  fontSize: 14,
);


TextStyle normalTextStyle = GoogleFonts.rubik(
  color: Colors.black,
  fontSize: 16,
);
