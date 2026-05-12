import 'package:flutter/material.dart';

class app_temas {
  // Tema Escuro (O que você já tem)
  static final escuro = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B0B0B),
    cardColor: const Color(0xFF2B2B2B),
    primaryColor: const Color(0xFF00CC44), // Verde
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
    ),
  );

  // Tema Claro (Sugestão)
  static final claro = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Cinza bem clarinho
    cardColor: Colors.white,
    primaryColor: const Color(0xFF00CC44),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0B0B0B)), // Texto quase preto
      bodyMedium: TextStyle(color: Color(0xFF616161)), // Cinza médio
    ),
  );
}