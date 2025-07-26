import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyfe_app/main.dart'; // For AppTheme

class UpdateDetailsController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final isSaving = false.obs;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // Controllers for each form field
  late TextEditingController fullNameController;
  late TextEditingController ageController;
  late TextEditingController bloodGroupController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController allergiesController;
  late TextEditingController medicationsController;

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    fullNameController = TextEditingController();
    ageController = TextEditingController();
    bloodGroupController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    allergiesController = TextEditingController();
    medicationsController = TextEditingController();
    // Load existing user data into the form
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        fullNameController.text = data['fullName'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        bloodGroupController.text = data['bloodGroup'] ?? '';
        heightController.text = data['heightCm']?.toString() ?? '';
        weightController.text = data['weightKg']?.toString() ?? '';
        allergiesController.text = data['allergies'] ?? '';
        medicationsController.text = data['medications'] ?? '';
      }
    } catch (e) {
      Get.snackbar("Error", "Could not load profile data.");
    }
  }

  Future<void> saveProfile() async {
    if (formKey.currentState?.validate() != true) {
      Get.snackbar("Input Error", "Please check your inputs.");
      return;
    }
    if (uid == null) {
      Get.snackbar("Error", "User not found.");
      return;
    }

    isSaving.value = true;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullName': fullNameController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'bloodGroup': bloodGroupController.text,
        'heightCm': int.tryParse(heightController.text) ?? 0,
        'weightKg': int.tryParse(weightController.text) ?? 0,
        'allergies': allergiesController.text,
        'medications': medicationsController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      Get.back(result: 'updated'); // Go back and signal an update
      Get.snackbar("Success", "Profile updated successfully!");

    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: ${e.toString()}");
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    fullNameController.dispose();
    ageController.dispose();
    bloodGroupController.dispose();
    heightController.dispose();
    weightController.dispose();
    allergiesController.dispose();
    medicationsController.dispose();
    super.onClose();
  }
}

class UpdateDetailsScreen extends StatelessWidget {
  UpdateDetailsScreen({super.key});

  final UpdateDetailsController _controller = Get.put(UpdateDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _controller.formKey,
          child: Column(
            children: [
              _buildTextField(controller: _controller.fullNameController, label: "Full Name"),
              _buildTextField(controller: _controller.ageController, label: "Age", keyboardType: TextInputType.number),
              _buildTextField(controller: _controller.bloodGroupController, label: "Blood Group"),
              _buildTextField(controller: _controller.heightController, label: "Height (cm)", keyboardType: TextInputType.number),
              _buildTextField(controller: _controller.weightController, label: "Weight (kg)", keyboardType: TextInputType.number),
              _buildTextField(controller: _controller.allergiesController, label: "Allergies (comma-separated)"),
              _buildTextField(controller: _controller.medicationsController, label: "Current Medications (comma-separated)"),
              const SizedBox(height: 30),
              Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGothic,
                      foregroundColor: AppTheme.primaryText,
                    ),
                    onPressed: _controller.isSaving.value ? null : () => _controller.saveProfile(),
                    child: _controller.isSaving.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Changes", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: AppTheme.primaryText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.secondaryText),
          filled: true,
          fillColor: AppTheme.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppTheme.accentGothic),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}