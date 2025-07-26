// =============================================================================
// 📁 lib/screens/how_it_works_screen.dart (NEW FILE)
// =============================================================================
// This file should be placed in a new folder, e.g., lib/screens/how_it_works_screen.dart
import 'package:flutter/material.dart';
// Assuming your theme is in a constants file as per the previous architecture.
// import 'package:lyfe_app/constants/app_constants.dart'; 

// --- THEME DEFINITION (Copied for context, import from your constants file) ---
class AppTheme {
  static const Color primaryBackground = Color(0xFF101010);
  static const Color cardBackground = Color(0xFF1B1B1B);
  static const Color primaryText = Color(0xFFEAEAEA);
  static const Color secondaryText = Color(0xFFAAAAAA);
  static const Color accentGothic = Color(0xFF9B1C1C);
  static const Color statusGreen = Color(0xFF10B981);
}

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // A list of maps, where each map represents a step in the workflow.
    final steps = [
      {
        'icon': Icons.edit_document,
        'title': '1. Create Your Profile',
        'description': 'Securely enter your vital health information, allergies, medications, and emergency contacts into the LYFE app.',
      },
      {
        'icon': Icons.cloud_upload,
        'title': '2. Secure Your Data',
        'description': 'Your data is encrypted and stored in our secure cloud, linked only to your account. We generate a unique, private URL for your profile.',
      },
      {
        'icon': Icons.nfc,
        'title': '3. Activate Your Tag',
        'description': 'Simply tap your LYFE wearable to your phone. The app will instantly and securely write your unique profile URL onto the tag’s NFC chip.',
      },
      {
        'icon': Icons.health_and_safety,
        'title': '4. Stay Emergency-Ready',
        'description': 'In an emergency, first responders can instantly tap or scan your LYFE wearable to access your life-saving information—no app, internet, or battery required.',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('How LYFE Works'),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return _buildStep(
            context,
            icon: steps[index]['icon'] as IconData,
            title: steps[index]['title'] as String,
            description: steps[index]['description'] as String,
            isFirst: index == 0,
            isLast: index == steps.length - 1,
          );
        },
      ),
    );
  }

  // A helper widget to build the timeline steps with connecting lines.
  Widget _buildStep(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- The Vertical Timeline Column (Icon and Lines) ---
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Top line (invisible for the first item)
              Container(
                width: 2,
                height: 20,
                color: isFirst ? Colors.transparent : AppTheme.secondaryText.withOpacity(0.3),
              ),
              // The Icon Circle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentGothic,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGothic.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              // Bottom line (invisible for the last item)
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : AppTheme.secondaryText.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // --- The Content Card Column ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Align with the top line
                Transform.translate(
                  offset: const Offset(0, 10), // Nudge the card down slightly
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    elevation: 0,
                    color: AppTheme.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.secondaryText,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
