import 'package:flutter/material.dart';

class AppTheme {
  // AWS 색상 팔레트
  static const Color awsOrange = Color(0xFFFF9900);
  static const Color awsDeepBlue = Color(0xFF232F3E);
  static const Color awsLightBlue = Color(0xFF146EB4);
  static const Color awsGray = Color(0xFF879196);
  static const Color awsLightGray = Color(0xFFF2F3F3);
  
  // 상태 색상
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningYellow = Color(0xFFFFC107);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: awsOrange,
      scaffoldBackgroundColor: awsLightGray,
      colorScheme: ColorScheme.fromSeed(
        seedColor: awsOrange,
        primary: awsOrange,
        secondary: awsLightBlue,
        surface: Colors.white,
        background: awsLightGray,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: awsDeepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: awsOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: awsGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: awsOrange, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  // 그라데이션 배경
  static BoxDecoration get gradientBackground {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8F5E9),  // 연한 녹색
          Color(0xFFF3E5F5),  // 연한 보라색
          Color(0xFFE3F2FD),  // 연한 파란색
        ],
      ),
    );
  }
  
  // 카드 그라데이션
  static BoxDecoration get cardGradient {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Color(0xFFFAFAFA),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}