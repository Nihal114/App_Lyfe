import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lyfe_app/main.dart'; // For AppTheme and HomeScreen
import 'package:lyfe_app/screens/nfc_writer_screen.dart';
// --- ACTION: Import the new update screen ---
import 'package:lyfe_app/screens/update_details_screen.dart';

class ProfileDisplayController extends GetxController {
  final user = Rx<Map<String, dynamic>?>(null);
  final isLoading = true.obs;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  final String publicProfileBaseUrl = "https://lyfewearables-app.web.app/index.html";
  String get publicProfileUrl => "$publicProfileBaseUrl?uid=$uid";

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    if (uid == null) {
      isLoading.value = false;
      Get.snackbar("Error", "User not logged in.");
      return;
    }
    try {
      isLoading.value = true;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        user.value = doc.data();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch profile data: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}

class ProfileDisplayScreen extends StatelessWidget {
  ProfileDisplayScreen({super.key});

  final ProfileDisplayController _controller = Get.put(ProfileDisplayController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Your LYFE Profile'),
        centerTitle: true,
        actions: [
          // --- *** MODIFIED CODE BLOCK *** ---
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () async {
              // Navigate to the edit screen and wait for a result
              final result = await Get.to(() => UpdateDetailsScreen());

              // If the result is 'updated', refresh the profile data
              if (result == 'updated') {
                _controller.fetchUserProfile();
              }
            },
          ),
          // --- *** END OF MODIFICATION *** ---
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => Get.offAll(() => HomeScreen()),
            tooltip: 'Go to Dashboard',
          )
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.user.value == null) {
          return Center(
            child: Text(
              'Profile data not found. Please complete your profile.',
              style: Get.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          );
        }

        final userData = _controller.user.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(userData),
              const SizedBox(height: 24),
              _buildUrlCard(context),
              const SizedBox(height: 24),
              _buildSectionCard("Personal Details", [
                _buildInfoRow("Age", userData['age']?.toString() ?? 'N/A'),
                _buildInfoRow("Blood Group", userData['bloodGroup'] ?? 'N/A'),
                _buildInfoRow("Height", "${userData['heightCm'] ?? 'N/A'} cm"),
                _buildInfoRow("Weight", "${userData['weightKg'] ?? 'N/A'} kg"),
              ]),
              const SizedBox(height: 20),
              _buildSectionCard("Medical Information", [
                  _buildInfoRow("Allergies", userData['allergies'] ?? 'N/A'),
                  _buildInfoRow("Medications", userData['medications'] ?? 'N/A'),
              ]),
            ],
          ),
        );
      }),
    );
  }

  // --- No changes to the helper widgets below this line ---
  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: AppTheme.accentGothic,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            userData['fullName'] ?? 'User Name',
            style: Get.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? 'user@email.com',
            style: Get.textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Public Profile URL", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            SelectableText(
              _controller.publicProfileUrl,
              style: Get.textTheme.bodyMedium?.copyWith(color: AppTheme.statusGreen),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text("Copy URL"),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _controller.publicProfileUrl));
                      Get.snackbar("Copied!", "Profile URL copied to clipboard.", snackPosition: SnackPosition.BOTTOM);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Get.textTheme.headlineMedium?.copyWith(fontSize: 18)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Get.textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryText)),
          Text(value, style: Get.textTheme.bodyLarge),
        ],
      ),
    );
  }
}