import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/auth/otp_second_screen.dart';
import 'package:ride_karo/features/home/home_activity.dart';

/// Phone number entry and Google Sign-In screen.
///
/// Mirrors the Kotlin [OTPValidation] activity and its layout
/// `activity_otpvalidation.xml` — featuring a yellow header banner with
/// "Login or Register", social sign-in buttons (Google, Facebook, Apple),
/// an OR divider, phone input, and a dark "Continue" button with yellow text.
class OTPValidationScreen extends StatefulWidget {
  /// Creates the OTP validation screen.
  const OTPValidationScreen({super.key});

  @override
  State<OTPValidationScreen> createState() => _OTPValidationScreenState();
}

class _OTPValidationScreenState extends State<OTPValidationScreen> {
  final TextEditingController _phoneController = TextEditingController();

  /// Tracks rapid consecutive taps for triple-tap bypass detection.
  int _tapCount = 0;

  /// Timestamp of the last tap, used to reset the counter after a pause.
  DateTime _lastTapTime = DateTime.now();

  /// Whether the bypass navigation has already been triggered.
  bool _bypassTriggered = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Yellow header banner — matches rlWelcomeScreen in original
              // with ic_rectangle_button background (solid yellow)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 70,
                  bottom: 28,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryYellow,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title — matches tvWelcome
                    Text(
                      'Login or Register',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ProductSans',
                        color: AppTheme.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    // Subtitle (empty in original tvWelcomeChoose, but we keep
                    // a minimal hint for UX)
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'ProductSans',
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Social sign-in buttons — matches signInButton, btnFacebook,
              // btnPhoneNumber in original layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Google Sign-In — google_btn_bg background (white with border)
                    _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Continue with Google',
                      bgColor: AppTheme.white,
                      textColor: AppTheme.black,
                      borderColor: const Color(0xFFC1C1C1),
                      onTap: _onGoogleSignIn,
                    ),
                    const SizedBox(height: 16),
                    // Facebook — fb_btn_bg background (Facebook blue)
                    _buildSocialButton(
                      icon: Icons.facebook,
                      label: 'Continue with Facebook',
                      bgColor: AppTheme.facebookBlue,
                      textColor: AppTheme.white,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Facebook login coming soon'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Apple — rect_apple_bg background (black)
                    _buildSocialButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      bgColor: AppTheme.black,
                      textColor: AppTheme.white,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Apple login coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // OR divider — matches tvor
              const Center(
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'ProductSans',
                    color: AppTheme.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Phone number input — matches mobileNumber EditText
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Phone Number',
                    hintStyle: TextStyle(
                      fontFamily: 'ProductSans',
                      color: Colors.grey.shade500,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: const UnderlineInputBorder(),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.primaryYellow,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Continue button — matches button with rect_round_mob background
              // (dark rounded button with yellow text)
              Center(
                child: SizedBox(
                  width: 170,
                  height: 46,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onContinueTap,
                    onLongPress: _bypassLoginForTesting,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.bgDarkGray,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'ProductSans',
                          color: AppTheme.mainTheme,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Terms text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'By continuing you will agree to our terms and\nprivacy policy of Rapido',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'ProductSans',
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Visible Skip OTP button for testing/preview environments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _bypassLoginForTesting,
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    label: const Text(
                      'Skip OTP (Testing Only)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a social sign-in button matching the original app's style.
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor, size: 22),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontFamily: 'ProductSans',
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  /// Handles a single tap on the Continue button.
  void _onContinueTap() {
    final now = DateTime.now();
    if (now.difference(_lastTapTime).inMilliseconds > 1000) {
      _tapCount = 0;
    }
    _lastTapTime = now;
    _tapCount++;

    if (_tapCount >= 3) {
      _tapCount = 0;
      _bypassLoginForTesting();
    } else {
      _onContinueWithPhone();
    }
  }

  /// DEBUG/TESTING ONLY: Bypasses phone number + OTP flow.
  void _bypassLoginForTesting() async {
    if (_bypassTriggered) return;
    _bypassTriggered = true;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await PreferenceHelper.writeBool(AppConstants.userPhoneLogin, true);
    await PreferenceHelper.writeBool(AppConstants.keyUserLoggedIn, true);
    await PreferenceHelper.writeString(
      AppConstants.keyDisplayName,
      'Test User (OTP Bypass)',
    );

    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(
        content: Text('DEBUG: OTP bypass activated'),
        duration: Duration(seconds: 1),
      ),
    );

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeActivity()),
      (route) => false,
    );
  }

  void _onContinueWithPhone() {
    final phone = _phoneController.text.trim();
    if (phone.length == 10) {
      PreferenceHelper.writeBool(AppConstants.userPhoneLogin, true);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OTPSecondScreen(mobileNumber: phone),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter 10 digits mobile number')),
      );
    }
  }

  void _onGoogleSignIn() async {
    await PreferenceHelper.writeBool(AppConstants.keyLoginWithOAuth, true);
    await PreferenceHelper.writeBool(AppConstants.keyUserLoggedIn, true);
    await PreferenceHelper.writeString(AppConstants.keyDisplayName, 'User');
    await PreferenceHelper.writeString(
      AppConstants.keyUserGoogleGmail,
      'user@gmail.com',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome!')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeActivity(
          userName: 'User',
          userEmail: 'user@gmail.com',
        ),
      ),
      (route) => false,
    );
  }
}
