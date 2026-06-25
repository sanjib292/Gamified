import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Centralised theme factory for MindQuest.
///
/// Both [lightTheme] and [darkTheme] use Material 3 and share the same
/// component overrides — only colours differ.
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.surfaceVariant,
          onPrimaryContainer: AppColors.primary,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.surfaceVariant,
          onSecondaryContainer: AppColors.secondary,
          tertiary: AppColors.accent,
          onTertiary: Colors.white,
          tertiaryContainer: AppColors.surfaceVariant,
          onTertiaryContainer: AppColors.primary,
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF93000A),
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceVariant,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.divider,
          outlineVariant: AppColors.divider,
          shadow: Colors.black,
          scrim: AppColors.scrim,
          inverseSurface: AppColors.darkSurface,
          onInverseSurface: AppColors.darkTextPrimary,
          inversePrimary: AppColors.accent,
        ),
        scaffoldBackground: AppColors.background,
        systemUiStyle: SystemUiOverlayStyle.dark,
      );

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.accent,
          onPrimary: AppColors.darkSurface,
          primaryContainer: Color(0xFF3D2F9E),
          onPrimaryContainer: AppColors.accent,
          secondary: AppColors.secondary,
          onSecondary: AppColors.darkSurface,
          secondaryContainer: Color(0xFF2E2265),
          onSecondaryContainer: AppColors.secondary,
          tertiary: AppColors.primary,
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFF1E1550),
          onTertiaryContainer: AppColors.accent,
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          onSurfaceVariant: AppColors.darkTextSecondary,
          outline: AppColors.darkDivider,
          outlineVariant: AppColors.darkDivider,
          shadow: Colors.black,
          scrim: AppColors.scrim,
          inverseSurface: AppColors.surface,
          onInverseSurface: AppColors.textPrimary,
          inversePrimary: AppColors.primary,
        ),
        scaffoldBackground: AppColors.darkBackground,
        systemUiStyle: SystemUiOverlayStyle.light,
      );

  // ---------------------------------------------------------------------------
  // Internal builder
  // ---------------------------------------------------------------------------

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required SystemUiOverlayStyle systemUiStyle,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,

      // -----------------------------------------------------------------------
      // Typography
      // -----------------------------------------------------------------------
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: colorScheme.onSurface,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // -----------------------------------------------------------------------
      // AppBar
      // -----------------------------------------------------------------------
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: systemUiStyle,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: AppSpacing.iconMd),
      ),

      // -----------------------------------------------------------------------
      // Elevated button
      // -----------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          elevation: 2,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // -----------------------------------------------------------------------
      // Outlined button
      // -----------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: const StadiumBorder(),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // -----------------------------------------------------------------------
      // Text button
      // -----------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Input decoration
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.darkTextHint : AppColors.textHint,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // -----------------------------------------------------------------------
      // Card
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        elevation: AppSpacing.cardElevation,
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom navigation bar
      // -----------------------------------------------------------------------
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // -----------------------------------------------------------------------
      // Navigation bar (Material 3)
      // -----------------------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),

      // -----------------------------------------------------------------------
      // Divider
      // -----------------------------------------------------------------------
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkDivider : AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // -----------------------------------------------------------------------
      // Chip
      // -----------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: const StadiumBorder(),
      ),

      // -----------------------------------------------------------------------
      // Dialog
      // -----------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom sheet
      // -----------------------------------------------------------------------
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        elevation: 8,
      ),

      // -----------------------------------------------------------------------
      // Snack bar
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.darkSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        actionTextColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // -----------------------------------------------------------------------
      // Progress indicator
      // -----------------------------------------------------------------------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
        linearMinHeight: 8,
        borderRadius: AppSpacing.borderRadiusFull,
      ),

      // -----------------------------------------------------------------------
      // Floating action button
      // -----------------------------------------------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),
    );
  }
}
