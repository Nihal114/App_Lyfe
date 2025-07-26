import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyfe_app/screens/nfc_writer_screen.dart'; // Ensure this path is correct for NfcScreen
import 'package:lyfe_app/screens/profile_display_screen.dart';

import 'package:lyfe_app/screens/profile_screen.dart';
import 'screens/faq.dart';
import 'screens/workflow.dart';
import 'screens/auth_screen.dart';
import 'dart:math';
import 'screens/about_screen.dart';
import 'firebase_options.dart';


// --- CORE MODELS ---
class HealthScore {
  final int score;
  final String statusLabel;
  final Color statusColor;
  final Map<String, int> breakdown;
  final DateTime lastUpdated;

  HealthScore({required this.score, required this.breakdown, required this.lastUpdated})
      : statusLabel = _getStatusLabel(score),
        statusColor = _getStatusColor(score);

  static String _getStatusLabel(int score) {
    if (score < 40) return 'Incomplete Identity';
    if (score < 70) return 'Basic Ready';
    if (score < 90) return 'Emergency Ready';
    return 'Certified Health Identity';
  }

  static Color _getStatusColor(int score) {
    if (score < 40) return AppTheme.statusRed;
    if (score < 70) return AppTheme.statusOrange;
    if (score < 90) return AppTheme.statusYellow;
    return AppTheme.statusGreen;
  }
}

// --- GETX CONTROLLER ---
class HealthScoreController extends GetxController {
  final healthScore = HealthScore(
    score: 82,
    breakdown: {
      'Emergency Readiness': 30,
      'Medical Profile': 32,
      'Verification Status': 10,
      'Live Data Sync': 10,
    },
    lastUpdated: DateTime.now().subtract(Duration(days: 3)),
  ).obs;
}


// --- MAIN APPLICATION ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LyfeApp());
}

class LyfeApp extends StatelessWidget {
  const LyfeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LYFE',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final docExists = profileSnapshot.data?.exists ?? false;
              
              if (docExists) {
                return HomeScreen();
              }
              
              return ProfileSetupScreen();
            },
          );
        }
        
        return AuthScreen();
      },
    );
  }
}

// --- *** NOTE: ActionBottomSheet widget has been removed as it is no longer used. *** ---


// --- UI/UX REVAMPED HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final HealthScoreController controller = Get.put(HealthScoreController());

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.primaryBackground,
      drawer: const CustomDrawer(),
      // --- *** MODIFIED CODE BLOCK *** ---
      floatingActionButton: FloatingActionButton(
        tooltip: 'Write Profile to Accessory',
        child: const Icon(Icons.nfc), // Changed icon for clarity
        onPressed: () {
          // 1. Get the current user's UID from Firebase Auth.
          final String? uid = FirebaseAuth.instance.currentUser?.uid;

          // 2. Define the base URL. This should match the one in your ProfileDisplayController.
          // For best practice, move this to a central config file.
          const String publicProfileBaseUrl = "https://lyfewearables-app.web.app/index.html";

          // 3. Check if the UID is valid before proceeding.
          if (uid != null && uid.isNotEmpty) {
            // 4. Construct the full URL to write to the NFC tag.
            final String urlToWrite = "$publicProfileBaseUrl?uid=$uid";

            // 5. Navigate directly to the simple screen.
            // Changed to SimpleScreen as requested, removing the dataToWrite parameter.
            Get.to(() => SimpleScreen());

            // 6. Give the user clear instructions.
            Get.snackbar(
              "Ready to Write",
              "Hold your accessory to the back of your phone.",
              backgroundColor: AppTheme.cardBackground,
              colorText: AppTheme.primaryText
            );
          } else {
            // Handle the rare case where the user isn't found.
            Get.snackbar(
              "Authentication Error",
              "Could not verify your profile. Please log in again.",
              backgroundColor: AppTheme.statusRed,
              colorText: AppTheme.primaryText
            );
          }
        },
      ),
      // --- *** END OF MODIFICATION *** ---
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            backgroundColor: AppTheme.primaryBackground,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Health Dashboard',
                style: TextStyle(color: AppTheme.primaryText, fontWeight: FontWeight.bold),
              ),
              background: const HeaderBackground(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScoreBreakdownCard(),
                    SizedBox(height: 20),
                    EducationalPromptCard(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// --- REVAMPED & NEW WIDGETS ---
class HeaderBackground extends StatelessWidget {
  const HeaderBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HealthScoreController controller = Get.find();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1584462295597-3a4d35a93d3c?q=80&w=2940&auto=format&fit=crop'), // Using a network image for reliability
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Obx(() => HealthScoreRing(
              healthScore: controller.healthScore.value,
            )),
      ),
    );
  }
}

class HealthScoreRing extends StatefulWidget {
  final HealthScore healthScore;
  const HealthScoreRing({Key? key, required this.healthScore}) : super(key: key);

  @override
  _HealthScoreRingState createState() => _HealthScoreRingState();
}

class _HealthScoreRingState extends State<HealthScoreRing> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: ProgressRingPainter(
              progress: widget.healthScore.score / 100.0 * _animationController.value,
              color: widget.healthScore.statusColor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(widget.healthScore.score * _animationController.value).toInt()}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 56, color: Colors.white),
                  ),
                  Text(
                    widget.healthScore.statusLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.healthScore.statusColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ScoreBreakdownCard extends StatelessWidget {
  const ScoreBreakdownCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HealthScoreController controller = Get.find();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Score Breakdown", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
              const SizedBox(height: 15),
              ...controller.healthScore.value.breakdown.entries.map((entry) {
                return _buildBreakdownRow(context, title: entry.key, value: entry.value);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(BuildContext context, {required String title, required int value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.statusGreen, size: 18),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Text("+$value pts", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryText)),
        ],
      ),
    );
  }
}

class EducationalPromptCard extends StatelessWidget {
  const EducationalPromptCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Why Your Score Matters", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              "A complete Health Identity ensures first responders have the critical information they need, when every second counts.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HealthScoreController controller = Get.find();
    // This is needed to sign out
    final AuthController authController = Get.put(AuthController());

    return Drawer(
      backgroundColor: AppTheme.cardBackground,
      child: Column(
        children: [
          Obx(() => _buildDrawerHeader(context, controller.healthScore.value)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, icon: Icons.dashboard_outlined, text: 'Dashboard', onTap: () => Navigator.pop(context)),
                _buildDrawerItem(context, icon: Icons.shield_outlined, text: 'About Us', onTap: ()=> Get.to(() => AboutScreen())),
                _buildDrawerItem(context, icon: Icons.work_outline, text: 'How it Works', onTap: ()=> Get.to(() => HowItWorksScreen())),
                _buildDrawerItem(context, icon: Icons.help_outline, text: 'Help & Support', onTap: ()=> Get.to(() => FaqScreen())),
                _buildDrawerItem(context, icon: Icons.settings_outlined, text: 'Profile', onTap: ()=> Get.to(() => ProfileDisplayScreen())),

              ],
            ),
          ),
          const Divider(color: Colors.white24, indent: 16, endIndent: 16),
          _buildDrawerItem(context, icon: Icons.logout, text: 'Logout', onTap: () {
            // Call the signOut method from the AuthController
            authController.signOut();
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, HealthScore healthScore) {
    // Get the current user to display their name
    final User? user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      color: AppTheme.primaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: healthScore.statusColor,
            child: Text('${healthScore.score}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
          ),
          const SizedBox(height: 15),
          // Display user's name or email if name is not available
          Text(user?.displayName ?? user?.email ?? 'User', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 5),
          Text(healthScore.statusLabel, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: healthScore.statusColor)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.iconColor),
      title: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AppTheme {
  static final Color primaryBackground = Color(0xFF101010);
  static final Color cardBackground = Color(0xFF1B1B1B);
  static final Color primaryText = Color(0xFFEAEAEA);
  static final Color secondaryText = Color(0xFFAAAAAA);
  static final Color accentColor = Color(0xFFFFFFFF);
  static final Color iconColor = Color(0xFFAAAAAA);
  static final Color accentGothic = Color(0xFF9B1C1C);
  static final Color statusRed = Color(0xFF9B1C1C);
  static final Color statusOrange = Color(0xFFD97706);
  static final Color statusYellow = Color(0xFFFBBF24);
  static final Color statusGreen = Color(0xFF10B981);

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: primaryBackground,
      primaryColor: primaryBackground,
      colorScheme: ColorScheme.dark(
        primary: accentColor, onPrimary: primaryBackground,
        secondary: cardBackground, onSecondary: primaryText,
        surface: cardBackground, onSurface: primaryText,
        background: primaryBackground, onBackground: primaryText,
        error: Colors.redAccent, onError: primaryText,
      ),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 34),
        headlineMedium: TextStyle(color: primaryText, fontWeight: FontWeight.w600, fontSize: 22),
        bodyLarge: TextStyle(color: primaryText, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: secondaryText, fontSize: 14, height: 1.5),
        labelLarge: TextStyle(color: primaryBackground, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: IconThemeData(color: accentColor, size: 28),
      ),
      cardTheme: CardThemeData(
        color: cardBackground, elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      iconTheme: IconThemeData(color: iconColor),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGothic, foregroundColor: primaryText,
      ),
    );
  }
}
