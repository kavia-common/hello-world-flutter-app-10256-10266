import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const CalculatorApp());
}

/// Root Flutter application for the calculator flow.
///
/// Replaces the hello-world app with:
/// - Login screen
/// - Sign Up screen
/// - Dashboard calculator screen
///
/// Navigation/backstack parity:
/// - Entering Dashboard clears auth screens (pushNamedAndRemoveUntil).
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  static const Color _primary = Color(0xFF3B82F6);
  static const Color _secondary = Color(0xFF64748B);
  static const Color _background = Color(0xFFF9FAFB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _text = Color(0xFF111827);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _error = Color(0xFFEF4444);

  static const double _screenPadding = 20;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      error: _error,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
    );

    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: base.textTheme.copyWith(
          titleLarge: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: _text,
          ),
          bodySmall: const TextStyle(
            fontSize: 13,
            color: _mutedText,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      routes: <String, WidgetBuilder>{
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        DashboardScreen.routeName: (_) => const DashboardScreen(),
      },
      initialRoute: LoginScreen.routeName,
    );
  }
}

/// Shared parity strings with the Kotlin implementation.
final class AppStrings {
  AppStrings._();

  // Auth
  static const String loginTitle = 'Login';
  static const String signUpTitle = 'Sign Up';

  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';

  static const String loginButton = 'Login';
  static const String goToSignUpButton = 'Go to Sign Up';

  static const String signUpButton = 'Sign Up';
  static const String backToLoginButton = 'Back to Login';

  // General validation / errors (must match Kotlin)
  static const String fixHighlightedFields = 'Please fix the highlighted fields.';

  // Field validation (must match Kotlin)
  static const String emailRequired = 'Email is required.';
  static const String emailInvalid = 'Enter a valid email.';
  static const String passwordRequired = 'Password is required.';
  static const String passwordTooShort = 'Password must be at least 6 characters.';
  static const String confirmPasswordRequired = 'Please confirm your password.';
  static const String passwordsDontMatch = 'Passwords do not match.';

  // Dashboard
  static const String dashboardTitle = 'Dashboard';
  static const String operandALabel = 'Operand A';
  static const String operandBLabel = 'Operand B';
  static const String resultLabel = 'Result';
  static const String dash = '—';

  // Calculator validation / errors (must match Kotlin)
  static const String validNumberError = 'Enter a valid number.';
  static const String cannotDivideByZero = 'Cannot divide by zero.';

  static const String clear = 'Clear';
}

/// Validation parity with Kotlin `Validation.kt`.
final class Validation {
  Validation._();

  static final RegExp _emailRegex = RegExp(r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$');

  // PUBLIC_INTERFACE
  static String? emailError(String email) {
    /// Returns an error message if email is invalid; otherwise null.
    if (email.trim().isEmpty) return AppStrings.emailRequired;
    if (!_emailRegex.hasMatch(email.trim())) return AppStrings.emailInvalid;
    return null;
  }

  // PUBLIC_INTERFACE
  static String? passwordError(String password) {
    /// Returns an error message if password is invalid; otherwise null.
    if (password.isEmpty) return AppStrings.passwordRequired;
    if (password.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  // PUBLIC_INTERFACE
  static String? confirmPasswordError(String password, String confirmPassword) {
    /// Returns an error message if confirm password is invalid; otherwise null.
    if (confirmPassword.isEmpty) return AppStrings.confirmPasswordRequired;
    if (password != confirmPassword) return AppStrings.passwordsDontMatch;
    return null;
  }
}

/// Calculator operation parity with Kotlin `Operation` enum.
enum Operation {
  add,
  subtract,
  multiply,
  divide,
}

/// Reusable error banner that mirrors Kotlin's "visible only when msg not blank".
class GeneralErrorBanner extends StatelessWidget {
  const GeneralErrorBanner({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String msg = message?.trim() ?? '';
    if (msg.isEmpty) return const SizedBox.shrink();

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.error.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error.withAlpha(80)),
      ),
      child: Text(
        msg,
        style: TextStyle(
          color: scheme.error,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Simple card container to match spacing/surface usage.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(18)),
      ),
      child: child,
    );
  }
}

/// Login screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  bool _shouldNavigateToDashboard = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _validateAndLogin() {
    // Kotlin parity: clear general error before validation.
    final String email = _emailCtrl.text;
    final String password = _passwordCtrl.text;

    final String? emailMsg = Validation.emailError(email);
    final String? pwdMsg = Validation.passwordError(password);

    final bool hasError = (emailMsg?.trim().isNotEmpty ?? false) || (pwdMsg?.trim().isNotEmpty ?? false);

    setState(() {
      _generalError = null;
      _emailError = emailMsg;
      _passwordError = pwdMsg;

      if (hasError) {
        _generalError = AppStrings.fixHighlightedFields;
        _shouldNavigateToDashboard = false;
      } else {
        // No backend/auth in scope: treat valid input as successful login.
        _shouldNavigateToDashboard = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Navigation must happen from build() based on primitive state flag (async-gap safe pattern).
    if (_shouldNavigateToDashboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(DashboardScreen.routeName, (Route<dynamic> route) => false);
      });

      // Reset immediately to avoid repeated navigation on rebuilds.
      _shouldNavigateToDashboard = false;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CalculatorApp._screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 18),
              Text(AppStrings.loginTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GeneralErrorBanner(message: _generalError),
                    if ((_generalError?.trim().isNotEmpty ?? false)) const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppStrings.emailLabel,
                        errorText: _emailError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _validateAndLogin(),
                      decoration: InputDecoration(
                        labelText: AppStrings.passwordLabel,
                        errorText: _passwordError,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: _validateAndLogin,
                      child: const Text(AppStrings.loginButton),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(SignUpScreen.routeName);
                      },
                      child: const Text(AppStrings.goToSignUpButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sign Up screen.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = '/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  bool _shouldNavigateToDashboard = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _validateAndSignUp() {
    // Kotlin parity: clear general error before validation.
    final String email = _emailCtrl.text;
    final String password = _passwordCtrl.text;
    final String confirm = _confirmPasswordCtrl.text;

    final String? emailMsg = Validation.emailError(email);
    final String? pwdMsg = Validation.passwordError(password);
    final String? confirmMsg = Validation.confirmPasswordError(password, confirm);

    final bool hasError = (emailMsg?.trim().isNotEmpty ?? false) ||
        (pwdMsg?.trim().isNotEmpty ?? false) ||
        (confirmMsg?.trim().isNotEmpty ?? false);

    setState(() {
      _generalError = null;
      _emailError = emailMsg;
      _passwordError = pwdMsg;
      _confirmPasswordError = confirmMsg;

      if (hasError) {
        _generalError = AppStrings.fixHighlightedFields;
        _shouldNavigateToDashboard = false;
      } else {
        // No backend/signup in scope: treat valid input as successful sign-up.
        _shouldNavigateToDashboard = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Navigation must happen from build() based on primitive state flag (async-gap safe pattern).
    if (_shouldNavigateToDashboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(DashboardScreen.routeName, (Route<dynamic> route) => false);
      });

      // Reset immediately to avoid repeated navigation on rebuilds.
      _shouldNavigateToDashboard = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.signUpTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CalculatorApp._screenPadding),
          child: SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GeneralErrorBanner(message: _generalError),
                if ((_generalError?.trim().isNotEmpty ?? false)) const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppStrings.emailLabel,
                    errorText: _emailError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppStrings.passwordLabel,
                    errorText: _passwordError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _validateAndSignUp(),
                  decoration: InputDecoration(
                    labelText: AppStrings.confirmPasswordLabel,
                    errorText: _confirmPasswordError,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _validateAndSignUp,
                  child: const Text(AppStrings.signUpButton),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // parity with Kotlin popBackStack()
                  },
                  child: const Text(AppStrings.backToLoginButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashboard calculator screen.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _aCtrl = TextEditingController();
  final TextEditingController _bCtrl = TextEditingController();

  String? _operandAError;
  String? _operandBError;
  String? _generalError;

  // Kotlin parity: initial result "—"
  String _resultText = AppStrings.dash;

  // Kotlin parity: DecimalFormat("#.##########")
  final NumberFormat _df = NumberFormat('#.##########');

  @override
  void dispose() {
    _aCtrl.dispose();
    _bCtrl.dispose();
    super.dispose();
  }

  void _onClear() {
    setState(() {
      _aCtrl.text = '';
      _bCtrl.text = '';
      _operandAError = null;
      _operandBError = null;
      _generalError = null;
      _resultText = AppStrings.dash;
    });
  }

  void _onOperation(Operation op) {
    // Kotlin parity: clear general error before validation
    final String rawA = _aCtrl.text;
    final String rawB = _bCtrl.text;

    final double? a = double.tryParse(rawA);
    final double? b = double.tryParse(rawB);

    final String? aErr = (a == null) ? AppStrings.validNumberError : null;
    final String? bErr = (b == null) ? AppStrings.validNumberError : null;

    if (a == null || b == null) {
      setState(() {
        _generalError = AppStrings.fixHighlightedFields;
        _operandAError = aErr;
        _operandBError = bErr;
      });
      return;
    }

    if (op == Operation.divide && b == 0.0) {
      setState(() {
        _generalError = AppStrings.cannotDivideByZero;
        _operandAError = null;
        _operandBError = null;
        _resultText = AppStrings.dash;
      });
      return;
    }

    final double result = switch (op) {
      Operation.add => a + b,
      Operation.subtract => a - b,
      Operation.multiply => a * b,
      Operation.divide => a / b,
    };

    setState(() {
      _generalError = null;
      _operandAError = null;
      _operandBError = null;
      _resultText = _df.format(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.bodySmall;
    final TextStyle? resultStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CalculatorApp._screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GeneralErrorBanner(message: _generalError),
                    if ((_generalError?.trim().isNotEmpty ?? false)) const SizedBox(height: 12),
                    TextField(
                      controller: _aCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppStrings.operandALabel,
                        errorText: _operandAError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: AppStrings.operandBLabel,
                        errorText: _operandBError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.resultLabel, style: labelStyle),
                    const SizedBox(height: 6),
                    Text(_resultText, style: resultStyle),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _onOperation(Operation.add),
                      child: const Text('+'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _onOperation(Operation.subtract),
                      // Parity checklist requirement: minus must be U+2212, not hyphen-minus.
                      child: const Text('−'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _onOperation(Operation.multiply),
                      child: const Text('×'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _onOperation(Operation.divide),
                      child: const Text('÷'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _onClear,
                child: const Text(AppStrings.clear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
