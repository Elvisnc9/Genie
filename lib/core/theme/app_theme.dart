import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'radii.dart';
import 'typography.dart';

abstract final class GenieTheme {
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: GenieColors.teal,
    onPrimary: GenieColors.onAccent,
    primaryContainer: GenieColors.tealSoft,
    onPrimaryContainer: GenieColors.tealDark,
    secondary: GenieColors.tealDark,
    onSecondary: GenieColors.onAccent,
    secondaryContainer: GenieColors.tealSoft,
    onSecondaryContainer: GenieColors.tealDark,
    tertiary: GenieColors.badgeFg,
    onTertiary: GenieColors.onAccent,
    tertiaryContainer: GenieColors.badgeBg,
    onTertiaryContainer: GenieColors.badgeFg,
    error: GenieColors.danger,
    onError: GenieColors.onAccent,
    errorContainer: GenieColors.dangerSoft,
    onErrorContainer: GenieColors.danger,
    surface: GenieColors.bg,
    onSurface: GenieColors.ink,
    onSurfaceVariant: GenieColors.ink2,
    surfaceContainerLowest: GenieColors.card,
    surfaceContainerLow: GenieColors.card,
    surfaceContainer: GenieColors.card,
    surfaceContainerHigh: GenieColors.tileBg,
    surfaceContainerHighest: GenieColors.track,
    outline: GenieColors.ink3,
    outlineVariant: GenieColors.line,
    shadow: GenieColors.shadow,
    scrim: GenieColors.scrim,
    inverseSurface: GenieColors.ink,
    onInverseSurface: GenieColors.bg,
    inversePrimary: GenieColors.tealSoft,
    surfaceTint: Colors.transparent, // no tonal tint: depth comes from neutral shadows
  );

  /// Light status and navigation bars with dark icons, drawn edge to edge.
  static const SystemUiOverlayStyle systemUi = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: GenieColors.bg,
    canvasColor: GenieColors.bg,
    fontFamily: GenieFonts.body,
    textTheme: GenieType.textTheme,
    primaryTextTheme: GenieType.textTheme,
    // Press feedback is a spring scale (see Pressable), not ink ripples.
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    iconTheme: const IconThemeData(color: GenieColors.ink, size: 22),
    dividerTheme: const DividerThemeData(color: GenieColors.line, thickness: 1, space: 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: systemUi,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: GenieColors.teal,
      selectionColor: GenieColors.teal.withValues(alpha: 0.22),
      selectionHandleColor: GenieColors.teal,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GenieColors.tileBg,
      hintStyle: GenieType.textTheme.bodyMedium!.copyWith(color: GenieColors.ink3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: const OutlineInputBorder(borderRadius: GenieRadii.chipAll, borderSide: BorderSide.none),
      enabledBorder: const OutlineInputBorder(borderRadius: GenieRadii.chipAll, borderSide: BorderSide.none),
      focusedBorder: const OutlineInputBorder(
        borderRadius: GenieRadii.chipAll,
        borderSide: BorderSide(color: GenieColors.teal, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: GenieColors.ink,
      contentTextStyle: GenieType.textTheme.bodyMedium!.copyWith(color: GenieColors.bg),
      actionTextColor: GenieColors.tealSoft,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: GenieRadii.chipAll),
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: GenieColors.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: GenieRadii.cardAll),
      titleTextStyle: GenieType.textTheme.headlineSmall,
      contentTextStyle: GenieType.textTheme.bodyLarge,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: GenieColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: GenieRadii.sheetTop),
      showDragHandle: false,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        // Supports Android's predictive back gesture.
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
