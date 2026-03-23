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
  static const Color _seed = Color(0xFF7C4DFF); // deep violet
  static const Color _bg = Color(0xFF0B0E14); // near-black blue
  static const Color _surface = Color(0xFF111827); // slate
  static const Color _surface2 = Color(0xFF0F172A); // darker slate

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ).copyWith(
      // Ensure a rich dark palette (Material3 uses "surface" a lot).
      surface: _surface,
      surfaceContainerHighest: _surface2,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,

      // Keep the existing iOS-ish feel, but make it look more premium in dark mode.
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
        hintStyle: TextStyle(color: scheme.onSurface.withAlpha(140)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withAlpha(110)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withAlpha(110)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withAlpha(210), width: 1.4),
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
            BorderSide(color: scheme.outline.withAlpha(120)),
          ),
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
        color: scheme.outline.withAlpha(90),
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
      theme: _AppTheme.dark(),
      home: const ReactAgentScreen(),
    );
  }
}
