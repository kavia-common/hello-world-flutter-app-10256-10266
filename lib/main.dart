import 'package:flutter/material.dart';

import 'package:react_agent/features/react_agent/presentation/react_agent_screen.dart';

/// Main entry point for the ReAct Agent Flutter app.
///
/// This is a single-screen iOS app that demonstrates the ReAct
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

// PUBLIC_INTERFACE
/// Root widget of the ReAct Agent application.
///
/// Uses a Material theme tuned for iOS look-and-feel with a single
/// screen ([ReactAgentScreen]) and no navigation routes.
class ReactAgentApp extends StatelessWidget {
  /// Creates the root app widget.
  const ReactAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReAct Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: '.SF Pro Text',
      ),
      home: const ReactAgentScreen(),
    );
  }
}
