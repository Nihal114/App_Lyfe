import 'package:flutter/material.dart';

// --- THEME DEFINITION (Copied from your main.dart for context) ---
// In your actual project, you would import this from your theme/constants file.
class AppTheme {
  static const Color primaryBackground = Color(0xFF101010);
  static const Color cardBackground = Color(0xFF1B1B1B);
  static const Color primaryText = Color(0xFFEAEAEA);
  static const Color secondaryText = Color(0xFFAAAAAA);
  static const Color accentGothic = Color(0xFF9B1C1C);
  static const Color iconColor = Color(0xFFAAAAAA);
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('About LYFE'),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Card ---
            Card(
              elevation: 0,
              color: AppTheme.accentGothic.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.accentGothic.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'LYFE',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Loving Yourself For Eternity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.secondaryText,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Our Mission Section ---
            _buildSection(
              context,
              icon: Icons.shield_outlined,
              title: 'Our Mission',
              content:
                  "To solve the critical gap in emergency response by making vital medical and identity information instantly accessible. We believe your safety should never depend on luck, battery, or connectivity.",
            ),

            // --- The Crisis Section ---
            _buildSection(
              context,
              icon: Icons.warning_amber_rounded,
              title: 'The Healthcare Identity Crisis',
              content:
                  "In India, a staggering 85% of individuals lack digital health records. In an emergency, this forces doctors to work in the dark, risking misdiagnosis and losing precious time when every second is critical.",
            ),

            // --- Our Solution Section ---
            _buildSection(
              context,
              icon: Icons.widgets_outlined,
              title: 'The LYFE Solution',
              content:
                  "A stylish, low-cost wearable that uses NFC and QR technology to store your vital health profile. It works offline, requires no battery, and is universally compatible, ensuring first responders get the information they need to save your life.",
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent sections, now with the overflow fix.
  Widget _buildSection(BuildContext context,
      {required IconData icon, required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.accentGothic, size: 28),
              const SizedBox(width: 16),
              // --- FIX APPLIED HERE ---
              // Expanded forces the Text to wrap if it's too long, preventing overflow.
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.secondaryText,
                  height: 1.6, // Improves readability
                ),
          ),
        ],
      ),
    );
  }
}
