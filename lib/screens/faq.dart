// =============================================================================
// 📁 lib/screens/faq_screen.dart (REVISED)
// =============================================================================
import 'package:flutter/material.dart';

// --- THEME DEFINITION (Copied for context, import from your constants file) ---
class AppTheme {
  static const Color primaryBackground = Color(0xFF101010);
  static const Color cardBackground = Color(0xFF1B1B1B);
  static const Color primaryText = Color(0xFFEAEAEA);
  static const Color secondaryText = Color(0xFFAAAAAA);
  static const Color accentGothic = Color(0xFF9B1C1C);
  static const Color iconColor = Color(0xFFAAAAAA);
}

// Data model for a single FAQ item
class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // The FAQs are now a static list, crafted from your project's core ideology.
  // This makes the screen self-contained and removes the need for a real-time backend for this feature.
  final List<FaqItem> _faqItems = [
    FaqItem(
      question: 'What is the core ideology behind LYFE?',
      answer: 'Emergencies don’t wait. Our ideology is built on "Always-On Readiness." We believe your safety should never depend on luck, battery, or an internet connection. LYFE transforms passive safety into an active, effortless daily habit, empowering individuals when they are most vulnerable.',
    ),
    FaqItem(
      question: 'How big is the problem you are solving?',
      answer: 'The problem is critical, especially in the Indian context where 85% of individuals lack accessible digital health records. This information gap during emergencies leads to treatment delays and preventable fatalities. LYFE addresses this by providing a reliable bridge between the patient and the first responder.',
    ),
    FaqItem(
      question: 'What makes LYFE special compared to other solutions?',
      answer: 'Our competitive edge is the "Zero Point of Failure" design. Unlike apps or other gadgets, LYFE wearables are battery-free, work offline, and have a dual-access system (NFC + QR code) for universal compatibility. It\'s not just a product; it\'s a reliable safety ecosystem.',
    ),
    FaqItem(
      question: 'What are the future plans for the LYFE ecosystem?',
      answer: 'Our vision extends beyond individual users. We are building an ecosystem through strategic partnerships with hospitals, schools, and corporate safety programs. Future implementations include AI-based alerts, integration with national health networks, and expanding our range of stylish, life-saving accessories.',
    ),
    FaqItem(
      question: 'Is there data to support the need for this?',
      answer: 'Yes. The statistic that 85% of people in India lack digital health records highlights a massive gap. Globally, studies show that delays in accessing patient information during the "golden hour" of an emergency dramatically impact outcomes. LYFE is designed to close this gap, directly addressing a well-documented and urgent problem.',
    ),
     FaqItem(
      question: 'How is my private data handled?',
      answer: 'Your privacy is paramount. The data is stored in an encrypted cloud database, and you have complete control over what information is shared on your public emergency profile. The NFC tag itself only contains a secure link to this profile, not your raw personal data.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          return FaqCard(item: _faqItems[index]);
        },
      ),
    );
  }
}

// Custom expandable card widget for a better UX (No change in this widget's logic)
class FaqCard extends StatefulWidget {
  final FaqItem item;
  const FaqCard({Key? key, required this.item}) : super(key: key);

  @override
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardBackground,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // --- Question Header ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: TextStyle(
                        color: _isExpanded ? Colors.white : AppTheme.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            ),
            // --- Animated Answer Section ---
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                padding: _isExpanded
                    ? const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0)
                    : const EdgeInsets.symmetric(horizontal: 20.0),
                child: _isExpanded
                    ? Text(
                        widget.item.answer,
                        style: const TextStyle(
                          color: AppTheme.secondaryText,
                          height: 1.6,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
