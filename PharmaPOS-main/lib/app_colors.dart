import 'package:flutter/material.dart';

class AppColors {
  // Palette Neutre Globale
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray900 = Color(0xFF0F172A);

  // Palette Primaire (Bleu Teal/Profondeur Médicale)
  static const Color primary50 = Color(0xFFF0FDF4);
  static const Color primary100 = Color(0xFFDCFCE7);
  static const Color primary500 = Color(0xFF0D9488); // Teal primaire
  static const Color primary600 = Color(0xFF0F766E);
  static const Color primary700 = Color(0xFF0F5A53);
  
  // Palette Secondaire (Navy Blue - Contrastes, textes sombres)
  static const Color secondary500 = Color(0xFF1E3A8A); // Bleu profond
  static const Color secondary800 = Color(0xFF1E293B);

  // Success / Validation (Vert Emeraude Vibrante)
  static const Color success100 = Color(0xFFD1FAE5);
  static const Color success500 = Color(0xFF10B981);
  static const Color success600 = Color(0xFF059669);

  // Warning (Orange / Ambre chaud)
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning600 = Color(0xFFD97706);

  // Alert / Danger (Rouge Corail)
  static const Color alert100 = Color(0xFFFEE2E2);
  static const Color alert500 = Color(0xFFEF4444);
  static const Color alert600 = Color(0xFFDC2626);

  // Basics
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color shadowColor = Color(0x0C000000); // Pour ombres douces

  // Semantic Colors for Theme
  static const Color background = gray50;
  static const Color surface = white;
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray500;
  static const Color border = gray200;
  static const Color divider = gray100;

  // Compatibility Aliases (to be replaced progressively)
  static const Color blue50 = gray50;
  static const Color blue200 = gray200;
  static const Color blue600 = primary600;
  static const Color orange100 = warning100;
  static const Color orange500 = warning500;
  static const Color orange600 = warning600;
  static const Color red100 = alert100;
  static const Color red500 = alert500;
  static const Color red600 = alert600;
  static const Color green500 = success500;
  static const Color white70 = Color(0xB3FFFFFF);
}
