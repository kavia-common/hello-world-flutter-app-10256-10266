import 'package:flutter/material.dart';

void main() {
  runApp(const HelloWorldApp());
}

/// Root application widget.
class HelloWorldApp extends StatelessWidget {
  const HelloWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Modern light theme (Material 3) matching the project style guide.
    const Color primary = Color(0xFF3B82F6);
    const Color secondary = Color(0xFF64748B);
    const Color background = Color(0xFFF9FAFB);
    const Color surface = Color(0xFFFFFFFF);
    const Color text = Color(0xFF111827);

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: surface,
    );

    return MaterialApp(
      title: 'Hello World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: background,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: text,
          ),
        ),
      ),
      home: const HelloWorldScreen(),
    );
  }
}

/// Single-screen layout with centered "Hello World".
class HelloWorldScreen extends StatelessWidget {
  const HelloWorldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Hello World'),
      ),
    );
  }
}
