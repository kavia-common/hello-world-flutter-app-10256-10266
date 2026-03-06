import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// COVID-19 information screen matching the Kotlin [Covid19Fragment].
///
/// Displays vaccination safety information and a "Book Vaccine" button
/// that opens the CoWIN portal. In the original app this used a WebView;
/// here we launch the URL externally since webview_flutter is not required.
class Covid19Fragment extends StatelessWidget {
  /// Creates the COVID-19 fragment widget.
  const Covid19Fragment({super.key});

  static const String _cowinUrl = 'https://www.cowin.gov.in/home/';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Safety header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 60,
                  color: Colors.teal.shade700,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your Safety Matters',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '#GetVaccine',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Safety tips
          _buildSafetyTip(
            Icons.masks,
            'Wear a mask during your ride',
          ),
          _buildSafetyTip(
            Icons.clean_hands,
            'Sanitize your hands before and after rides',
          ),
          _buildSafetyTip(
            Icons.social_distance,
            'Maintain social distancing at pickup points',
          ),
          _buildSafetyTip(
            Icons.vaccines,
            'Get vaccinated to protect yourself and others',
          ),
          const SizedBox(height: 32),
          // Book Vaccine button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _openCowin(context),
              icon: const Icon(Icons.vaccines, color: Colors.white),
              label: const Text(
                'Book Vaccine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Info text
          Text(
            'Tap above to visit the CoWIN portal and book your vaccination slot.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCowin(BuildContext context) async {
    final uri = Uri.parse(_cowinUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open CoWIN portal')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open CoWIN portal')),
        );
      }
    }
  }
}
