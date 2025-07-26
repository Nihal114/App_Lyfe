import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lyfe_app/main.dart'; // For AppTheme and HomeScreen

// =============================================================================
// 📁 MODEL: Defines the data structure for the user's profile.
// =============================================================================
class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final int age;
  final String bloodGroup;
  final double height;
  final double weight;
  final String allergies;
  final String medications;
  final String mobileNumber;
  final String emergencyContact1Number;
  final String emergencyContact1Relation;
  final String emergencyContact2Number;
  final String emergencyContact2Relation;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.age,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.allergies,
    required this.medications,
    required this.mobileNumber,
    required this.emergencyContact1Number,
    required this.emergencyContact1Relation,
    required this.emergencyContact2Number,
    required this.emergencyContact2Relation,
  });

  // Method to convert a UserModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'age': age,
      'bloodGroup': bloodGroup,
      'heightCm': height,
      'weightKg': weight,
      'allergies': allergies,
      'medications': medications,
      'mobileNumber': mobileNumber,
      'emergencyContact1': {
        'number': emergencyContact1Number,
        'relation': emergencyContact1Relation,
      },
      'emergencyContact2': {
        'number': emergencyContact2Number,
        'relation': emergencyContact2Relation,
      },
      'profileCreatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// =============================================================================
// 📁 CONTROLLER: Handles the logic for saving the profile to Firebase.
// =============================================================================
class ProfileSetupController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;

  Future<void> saveNewProfile(UserModel userProfile) async {
    isLoading.value = true;
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in.");
      }

      // Create the final user model with the correct UID and email
      final completeProfile = UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? 'N/A',
        fullName: userProfile.fullName,
        age: userProfile.age,
        bloodGroup: userProfile.bloodGroup,
        height: userProfile.height,
        weight: userProfile.weight,
        allergies: userProfile.allergies,
        medications: userProfile.medications,
        mobileNumber: userProfile.mobileNumber,
        emergencyContact1Number: userProfile.emergencyContact1Number,
        emergencyContact1Relation: userProfile.emergencyContact1Relation,
        emergencyContact2Number: userProfile.emergencyContact2Number,
        emergencyContact2Relation: userProfile.emergencyContact2Relation,
      );

      // Save the complete data to Firestore
      await _firestore.collection('users').doc(currentUser.uid).set(completeProfile.toMap());

      // Navigate to the main app screen after successful save
      Get.offAll(() => HomeScreen());
      Get.snackbar('Success!', 'Your health profile has been created.',
          backgroundColor: AppTheme.statusGreen, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile. Please try again.',
          backgroundColor: AppTheme.statusRed, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}

// =============================================================================
// 📁 VIEW: The UI for the profile creation form.
// =============================================================================
class ProfileSetupScreen extends StatelessWidget {
  ProfileSetupScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final ProfileSetupController _profileController = Get.put(ProfileSetupController());

  // Text Editing Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyNum1Controller = TextEditingController();
  final _emergencyRel1Controller = TextEditingController();
  final _emergencyNum2Controller = TextEditingController();
  final _emergencyRel2Controller = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create a temporary user model with form data
      final userProfile = UserModel(
        uid: '', // Controller will add the real UID
        email: '', // Controller will add the real email
        fullName: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        bloodGroup: _bloodGroupController.text.trim(),
        height: double.tryParse(_heightController.text.trim()) ?? 0.0,
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
        allergies: _allergiesController.text.trim(),
        medications: _medsController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
        emergencyContact1Number: _emergencyNum1Controller.text.trim(),
        emergencyContact1Relation: _emergencyRel1Controller.text.trim(),
        emergencyContact2Number: _emergencyNum2Controller.text.trim(),
        emergencyContact2Relation: _emergencyRel2Controller.text.trim(),
      );
      // Call the controller to save the data
      _profileController.saveNewProfile(userProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pre-fill phone number if available from Firebase Auth
    _phoneController.text = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Setup Your Health Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false, // User cannot go back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to LYFE. This information is critical in an emergency. Please fill it out accurately.",
                style: Get.textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Personal Details"),
              _buildTextField(_nameController, 'Full Name', validator: _requiredValidator),
              _buildTextField(_ageController, 'Age', keyboardType: TextInputType.number, validator: _requiredValidator),
              _buildTextField(_bloodGroupController, 'Blood Group (e.g., O+)', validator: _requiredValidator),
              _buildTextField(_heightController, 'Height (cm)', keyboardType: TextInputType.number, validator: _requiredValidator),
              _buildTextField(_weightController, 'Weight (kg)', keyboardType: TextInputType.number, validator: _requiredValidator),
              _buildTextField(_phoneController, 'Your Mobile Number', keyboardType: TextInputType.phone, validator: _requiredValidator),
              const SizedBox(height: 24),
              _buildSectionTitle("Medical Information"),
              _buildTextField(_allergiesController, 'Allergies (e.g., Penicillin, Peanuts)'),
              _buildTextField(_medsController, 'Current Medications (e.g., Aspirin 75mg)'),
              const SizedBox(height: 24),
              _buildSectionTitle("Emergency Contacts"),
              _buildTextField(_emergencyNum1Controller, 'Contact 1 - Number', keyboardType: TextInputType.phone, validator: _requiredValidator),
              _buildTextField(_emergencyRel1Controller, 'Contact 1 - Relation (e.g., Father)', validator: _requiredValidator),
              const SizedBox(height: 16),
              _buildTextField(_emergencyNum2Controller, 'Contact 2 - Number', keyboardType: TextInputType.phone),
              _buildTextField(_emergencyRel2Controller, 'Contact 2 - Relation (e.g., Spouse)'),
              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.accentGothic,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _profileController.isLoading.value ? null : _submitForm,
                  child: _profileController.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Save and Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Get.textTheme.headlineMedium?.copyWith(fontSize: 18)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:  TextStyle(color: AppTheme.secondaryText),
          filled: true,
          fillColor: AppTheme.cardBackground,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:  BorderSide(color: AppTheme.accentGothic, width: 2),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator ?? (value) => null, // Optional validator
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
