import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/home/home_activity.dart';

/// OTP code entry screen matching Kotlin [OTPSecondActivity].
///
/// Mirrors the layout `activity_otpsecond.xml` — yellow header banner
/// with "Enter verification pin" title and subtitle, OTP input field,
/// "Waiting for OTP" text, and dark Continue button with yellow text.
class OTPSecondScreen extends StatefulWidget {
  /// Creates the OTP second screen.
  const OTPSecondScreen({super.key, required this.mobileNumber});

  /// The phone number to verify.
  final String mobileNumber;

  @override
  State<OTPSecondScreen> createState() => _OTPSecondScreenState();
}

class _OTPSecondScreenState extends State<OTPSecondScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  /// Tracks rapid consecutive taps for triple-tap bypass detection.
  int _tapCount = 0;

  /// Timestamp of the last tap, used to reset the counter after a pause.
  DateTime _lastTapTime = DateTime.now();

  /// Whether the bypass navigation has already been triggered.
  bool _bypassTriggered = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Yellow header banner — matches rlWelcomeScreen with
            // ic_rectangle_button background (solid yellow)
            Container(
              width: double.infinity,
              height: 180,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 28),
              decoration: const BoxDecoration(
                color: AppTheme.primaryYellow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title — matches tvWelcome "Enter verification pin"
                  const Text(
                    'Enter verification pin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ProductSans',
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Subtitle — matches tvWelcomeChoose
                  const Text(
                    "Hold Tight! Rider is on it's way to your location",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'ProductSans',
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
            ),
            // OTP input area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // OTP input — matches otpTextField
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 8,
                        fontFamily: 'ProductSans',
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.primaryYellow,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // "Waiting for OTP" text — matches waiting_tv
                    const Text(
                      'Waiting for OTP',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'ProductSans',
                        color: AppTheme.gray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Continue button — matches verifyButton with rect_round_mob
            // background (dark rounded button with yellow text)
            Center(
              child: SizedBox(
                width: 170,
                height: 46,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _isVerifying ? null : _onContinueTap,
                  onLongPress: _isVerifying ? null : _bypassOTPForTesting,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: _isVerifying
                        ? BoxDecoration(
                            color: AppTheme.bgDarkGray.withAlpha(153),
                            borderRadius: BorderRadius.circular(24),
                          )
                        : const BoxDecoration(
                            color: AppTheme.bgDarkGray,
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.mainTheme,
                            ),
                          )
                        : const Text(
                            'CONTINUE',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'ProductSans',
                              color: AppTheme.mainTheme,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Visible Skip OTP button for testing/preview environments
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _isVerifying ? null : _bypassOTPForTesting,
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  label: const Text(
                    'Skip OTP (Debug)',
                    style: TextStyle(
                      fontSize: 13,
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
      _bypassOTPForTesting();
    } else {
      _verifyOTP();
    }
  }

  /// DEBUG/TESTING ONLY: Bypasses OTP verification.
  void _bypassOTPForTesting() async {
    if (_bypassTriggered) return;
    _bypassTriggered = true;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isVerifying = true;
    });

    await PreferenceHelper.writeBool(AppConstants.userPhoneLogin, true);
    await PreferenceHelper.writeBool(AppConstants.keyUserLoggedIn, true);
    await PreferenceHelper.writeString(
      AppConstants.keyDisplayName,
      'Test User (OTP Bypass)',
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

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

  void _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    await PreferenceHelper.writeBool(AppConstants.userPhoneLogin, true);
    await PreferenceHelper.writeBool(AppConstants.keyUserLoggedIn, true);
    await PreferenceHelper.writeString(
      AppConstants.keyDisplayName,
      'Phone User',
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeActivity()),
      (route) => false,
    );
  }
}
