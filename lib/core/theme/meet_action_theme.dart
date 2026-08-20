import 'package:flutter/material.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';

class MeetActionTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF5B4DFF);
  static const Color primaryLight = Color(0xFF7C70FF);
  static const Color primaryDark = Color(0xFF3F32D9);
  static const Color secondaryColor = Color(0xFF06B6D4);
  static const Color accentColor = Color(0xFFF43F5E);

  // Neutral Colors (Dark Mode First / Modern Aesthetic)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFFF8FAFC);

  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981); // Emerald
  static const Color priorityMedium = Color(0xFF3B82F6); // Blue
  static const Color priorityHigh = Color(0xFFF59E0B); // Amber
  static const Color priorityUrgent = Color(0xFFEF4444); // Red

  // Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFF94A3B8);

  static Color getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return priorityLow;
      case PriorityLevel.medium:
        return priorityMedium;
      case PriorityLevel.high:
        return priorityHigh;
      case PriorityLevel.urgent:
        return priorityUrgent;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceDark,
        error: accentColor,
        onPrimary: Colors.white,
        onSurface: Color(0xFFF1F5F9),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
