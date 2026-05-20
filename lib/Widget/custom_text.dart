import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontStyle? fontStyle;
  final TextDecoration? decoration; // <-- INI YANG KELUPAAN TADI BRO
  final double? letterSpacing;      // <-- Sekalian gue tambahin buat jarak huruf
  final bool isOleo;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontStyle,
    this.decoration,
    this.letterSpacing,
    this.isOleo = false, // Default-nya false (jadi pake Signika)
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: isOleo ? 'Oleo Script' : 'Signika Negative', 
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontStyle: fontStyle,
        decoration: decoration, // <-- TERUS DIPANGGIL DI SINI
        letterSpacing: letterSpacing,
      ),
    );
  }
}