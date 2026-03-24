import 'package:flutter/material.dart';

import 'package:react_agent/features/react_agent/presentation/react_agent_screen.dart';

/// Main entry point for the ReAct Agent Flutter app.
///
/// This is a single-screen app that demonstrates the ReAct
/// (Reasoning + Acting) AI agent pattern using OpenAI GPT models.
///
/// The OpenAI API key is read at runtime via `--dart-define`:
/// ```
/// flutter run --dart-define=OPENAI_API_KEY=sk-...
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReactAgentApp());
}

class _AppTheme {
  // Lighter grey theme with high contrast text for readability.
  static const Color _seed = Color(0xFF7C4DFF); // deep violet (kept as primary seed)

  // Light greys (not pure white) to reduce glare while staying readable.
  static const Color _bg = Color(0xFFF2F4F7); // app background
  static const Color _surface = Color(0xFFFFFFFF); // cards / surfaces
  static const Color _surface2 = Color(0xFFE9EDF3); // elevated containers / inputs

  static ThemeData lightGrey() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ).copyWith(
      // Material3 uses "surface" heavily; keep it clean and readable.
      surface: _surface,
      surfaceContainerHighest: _surface2,
      // Ensure onSurface is dark enough for text contrast.
      onSurface: const Color(0xFF111827),
      onSurfaceVariant: const Color(0xFF374151),
      outline: const Color(0xFFCBD5E1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _bg,

      // Keep the existing iOS-ish font choice.
      fontFamily: '.SF Pro Text',

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.25),
        bodyMedium: TextStyle(fontSize: 14, height: 1.25),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withAlpha(150)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withAlpha(200)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withAlpha(200)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withAlpha(230), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w700),
          ),
          // Ensure buttons remain readable on the primary color.
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
          backgroundColor: WidgetStatePropertyAll(scheme.primary),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outline.withAlpha(220)),
          ),
          foregroundColor: WidgetStatePropertyAll(scheme.onSurface),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),

      cardTheme: CardTheme(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline.withAlpha(160),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// PUBLIC_INTERFACE
/// Root widget of the ReAct Agent application.
///
/// Uses a Material 3 dark theme and renders a single screen ([ReactAgentScreen]).
class ReactAgentApp extends StatelessWidget {
  /// Creates the root app widget.
  const ReactAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReAct Agent',
      debugShowCheckedModeBanner: false,
      theme: _AppTheme.lightGrey(),
      home: const ReactAgentScreen(),
    );
  }
}
