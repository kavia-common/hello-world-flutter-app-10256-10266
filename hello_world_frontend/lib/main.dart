import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

/// Root application widget for the migrated Kotlin login + calculator app.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Light theme palette (matches the Kotlin "Ocean Professional" notes).
    const Color primary = Color(0xFF2563EB);
    const Color background = Color(0xFFF9FAFB);
    const Color surface = Color(0xFFFFFFFF);

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
    );

    return MaterialApp(
      title: 'Calculator App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: background,
      ),
      home: const AppShell(),
    );
  }
}

/// App "shell" that mirrors the Kotlin single-activity approach:
/// - persistent header always visible
/// - one of Login / Sign Up / Dashboard visible at a time
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

enum AppScreen { login, signup, dashboard }

class _AppShellState extends State<AppShell> {
  // In-memory accounts store: email -> password
  final Map<String, String> _accounts = <String, String>{};

  // Tracks logged-in user email.
  String? _currentUserEmail;

  // Login form controllers.
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Sign up form controllers.
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _signupConfirmController = TextEditingController();

  // Calculator controllers.
  final TextEditingController _numberAController = TextEditingController();
  final TextEditingController _numberBController = TextEditingController();

  // UI state
  AppScreen _screen = AppScreen.login;

  // Error messages (empty means hidden).
  String _loginError = '';
  String _signupError = '';
  String _calcError = '';

  // Dashboard display
  String _resultText = 'Result: —';

  @override
  void initState() {
    super.initState();
    _seedDemoAccount();
    _showLogin();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmController.dispose();
    _numberAController.dispose();
    _numberBController.dispose();
    super.dispose();
  }

  void _seedDemoAccount() {
    // Seeded demo account per Kotlin behavior.
    _accounts['demo@example.com'] = 'password';
  }

  void _clearAuthErrors() {
    setState(() {
      _loginError = '';
      _signupError = '';
    });
  }

  void _showLogin() {
    setState(() {
      _clearAuthErrors();
      _screen = AppScreen.login;
    });
  }

  void _showSignUp() {
    setState(() {
      _clearAuthErrors();
      _screen = AppScreen.signup;
    });
  }

  void _showDashboardForEmail(String email) {
    setState(() {
      _currentUserEmail = email;
      _screen = AppScreen.dashboard;

      // Dashboard entry behavior.
      _resultText = 'Result: —';
      _calcError = '';
    });
  }

  bool _isEmailValid(String email) {
    // Kotlin email rule:
    // 1) not blank
    // 2) exactly one '@', not first char
    // 3) '.' after '@', dot index > atIndex+1 and not last char
    if (email.trim().isEmpty) return false;

    final int atIndex = email.indexOf('@');
    if (atIndex <= 0) return false;
    if (email.lastIndexOf('@') != atIndex) return false;

    final int dotIndex = email.indexOf('.', atIndex + 1);
    if (dotIndex <= atIndex + 1) return false;
    if (dotIndex >= email.length - 1) return false;

    return true;
  }

  void _onLoginPressed() {
    // 1) hide both auth errors
    setState(() {
      _loginError = '';
      _signupError = '';
    });

    // 2) read/normalize
    final String email = _loginEmailController.text.trim();
    final String password = _loginPasswordController.text;

    // 3) validation
    if (!_isEmailValid(email)) {
      setState(() {
        _loginError = 'Please enter a valid email.';
      });
      return;
    }

    if (password.trim().isEmpty) {
      setState(() {
        _loginError = 'Please enter your password.';
      });
      return;
    }

    final String? stored = _accounts[email];
    if (stored == null || stored != password) {
      setState(() {
        _loginError = 'Invalid email or password.';
      });
      return;
    }

    // 4) success: clear password field then navigate to dashboard
    setState(() {
      _loginPasswordController.text = '';
    });
    _showDashboardForEmail(email);
  }

  void _onCreateAccountPressed() {
    // 1) hide both auth errors
    setState(() {
      _loginError = '';
      _signupError = '';
    });

    // 2) read/normalize
    final String email = _signupEmailController.text.trim();
    final String password = _signupPasswordController.text;
    final String confirm = _signupConfirmController.text;

    // 3) validation (first failure wins)
    if (!_isEmailValid(email)) {
      setState(() {
        _signupError = 'Please enter a valid email.';
      });
      return;
    }

    if (_accounts.containsKey(email)) {
      setState(() {
        _signupError = 'An account with this email already exists.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _signupError = 'Password must be at least 6 characters.';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _signupError = 'Passwords do not match.';
      });
      return;
    }

    // 4) success: add account, clear password + confirm, navigate to dashboard
    _accounts[email] = password;
    setState(() {
      _signupPasswordController.text = '';
      _signupConfirmController.text = '';
    });
    _showDashboardForEmail(email);
  }

  double? _parseNumberOrNull(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  String _formatResult(double value) {
    // Kotlin formatting rule: avoid trailing .0 when integer.
    final int asLong = value.toInt();
    if (value == asLong.toDouble()) {
      return asLong.toString();
    }
    return value.toString();
  }

  void _runCalculation(String op) {
    // 1) hide calcError
    setState(() {
      _calcError = '';
    });

    // 2) parse A and B
    final double? a = _parseNumberOrNull(_numberAController.text);
    final double? b = _parseNumberOrNull(_numberBController.text);

    // 3) invalid numbers
    if (a == null || b == null) {
      setState(() {
        _calcError = 'Please enter valid numbers for A and B.';
      });
      return;
    }

    // 4) division-specific rule
    if (op == 'div' && b.abs() < 1e-12) {
      setState(() {
        _calcError = 'Cannot divide by zero.';
      });
      return;
    }

    // 5) compute
    final double result = switch (op) {
      'add' => a + b,
      'sub' => a - b,
      'mul' => a * b,
      'div' => a / b,
      _ => double.nan,
    };

    // 6) display
    setState(() {
      _resultText = 'Result: ${_formatResult(result)}';
    });
  }

  void _onLogoutPressed() {
    // Logout behavior: clear current user and calculator state, then go to login.
    setState(() {
      _currentUserEmail = null;

      _numberAController.text = '';
      _numberBController.text = '';
      _calcError = '';
      _resultText = 'Result: —';
    });
    _showLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const _PersistentHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: switch (_screen) {
                  AppScreen.login => _LoginCard(
                      emailController: _loginEmailController,
                      passwordController: _loginPasswordController,
                      errorText: _loginError,
                      onLogin: _onLoginPressed,
                      onGoToSignUp: _showSignUp,
                    ),
                  AppScreen.signup => _SignUpCard(
                      emailController: _signupEmailController,
                      passwordController: _signupPasswordController,
                      confirmController: _signupConfirmController,
                      errorText: _signupError,
                      onCreateAccount: _onCreateAccountPressed,
                      onBackToLogin: _showLogin,
                    ),
                  AppScreen.dashboard => _DashboardCard(
                      email: _currentUserEmail ?? '',
                      numberAController: _numberAController,
                      numberBController: _numberBController,
                      errorText: _calcError,
                      resultText: _resultText,
                      onAdd: () => _runCalculation('add'),
                      onSub: () => _runCalculation('sub'),
                      onMul: () => _runCalculation('mul'),
                      onDiv: () => _runCalculation('div'),
                      onLogout: _onLogoutPressed,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersistentHeader extends StatelessWidget {
  const _PersistentHeader();

  @override
  Widget build(BuildContext context) {
    // Header always shows app name for title and subtitle (per spec).
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color border = const Color(0xFFE5E7EB);
    final Color text = const Color(0xFF111827);
    final Color muted = const Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(color: border),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Calculator App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Calculator App',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({
    required this.child,
    this.title,
  });

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    const Color border = Color(0xFFE5E7EB);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFEF4444),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.errorText,
    required this.onLogin,
    required this.onGoToSignUp,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String errorText;
  final VoidCallback onLogin;
  final VoidCallback onGoToSignUp;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      title: 'Login',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            onSubmitted: (_) => onLogin(),
          ),
          _ErrorText(errorText),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onLogin,
              child: const Text('Login'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onGoToSignUp,
              child: const Text('Create an account'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpCard extends StatelessWidget {
  const _SignUpCard({
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.errorText,
    required this.onCreateAccount,
    required this.onBackToLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String errorText;
  final VoidCallback onCreateAccount;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      title: 'Sign Up',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password (min 6 chars)',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
            ),
            onSubmitted: (_) => onCreateAccount(),
          ),
          _ErrorText(errorText),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCreateAccount,
              child: const Text('Create account'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onBackToLogin,
              child: const Text('Back to login'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.email,
    required this.numberAController,
    required this.numberBController,
    required this.errorText,
    required this.resultText,
    required this.onAdd,
    required this.onSub,
    required this.onMul,
    required this.onDiv,
    required this.onLogout,
  });

  final String email;
  final TextEditingController numberAController;
  final TextEditingController numberBController;
  final String errorText;
  final String resultText;
  final VoidCallback onAdd;
  final VoidCallback onSub;
  final VoidCallback onMul;
  final VoidCallback onDiv;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    const Color text = Color(0xFF111827);
    const Color muted = Color(0xFF6B7280);

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Calculator Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome, $email',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: muted,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: numberAController,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Number A',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: numberBController,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Number B',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                onPressed: onAdd,
                child: const Text('+'),
              ),
              FilledButton(
                onPressed: onSub,
                child: const Text('−'),
              ),
              FilledButton(
                onPressed: onMul,
                child: const Text('×'),
              ),
              FilledButton(
                onPressed: onDiv,
                child: const Text('÷'),
              ),
            ],
          ),
          _ErrorText(errorText),
          const SizedBox(height: 16),
          Text(
            resultText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onLogout,
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}

