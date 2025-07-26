import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- Core App Imports ---
import 'package:lyfe_app/main.dart'; // To access AppTheme, HomeScreen
import 'package:lyfe_app/screens/profile_screen.dart'; // To access ProfileSetupScreen

/// Enum to manage the different views of the authentication screen.
enum AuthMode { login, signup, forgotPassword, phone, otp }

/// GetX Controller for handling all authentication logic and state.
class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  // --- State Variables ---
  final authMode = AuthMode.login.obs;
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final verificationId = ''.obs;

  // --- Text Editing Controllers ---
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;
  late TextEditingController otpController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();
    otpController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  // --- Core Methods ---

  void switchAuthMode(AuthMode mode) {
    authMode.value = mode;
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    otpController.clear();
    _formKey.currentState?.reset();
  }

  /// This method now ONLY handles the auth attempt. Navigation is handled by AuthWrapper.
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    isLoading.value = true;
    try {
      switch (authMode.value) {
        case AuthMode.login:
          await _signInWithEmail();
          break;
        case AuthMode.signup:
          await _signUpWithEmail();
          break;
        case AuthMode.otp:
          await _signInWithOtp();
          break;
        case AuthMode.forgotPassword:
          await _sendPasswordResetEmail();
          break;
        case AuthMode.phone:
          await _verifyPhoneNumber();
          break;
      }
      // SUCCESS: No navigation here. The AuthWrapper's stream will fire and handle it.
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Get.snackbar(
        'An Unexpected Error Occurred',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.statusRed,
        colorText: Colors.white,
      );
    } finally {
      if (authMode.value != AuthMode.phone) {
        isLoading.value = false;
      }
    }
  }

  // --- Authentication Logic ---

  Future<void> _signInWithEmail() async {
    await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  Future<void> _signUpWithEmail() async {
    await _auth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    await _auth.sendPasswordResetEmail(email: emailController.text.trim());
    Get.snackbar(
      'Password Reset',
      'A password reset link has been sent to your email.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.statusGreen,
      colorText: Colors.white,
    );
    switchAuthMode(AuthMode.login);
  }

  Future<void> _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${phoneController.text.trim()}',
      // This case handles auto-retrieval on Android.
      // AuthWrapper will handle navigation.
      verificationCompleted: (PhoneAuthCredential credential) async {
        isLoading.value = true;
        await _auth.signInWithCredential(credential);
        isLoading.value = false;
      },
      verificationFailed: (FirebaseAuthException e) {
        isLoading.value = false;
        _handleAuthError(e);
      },
      codeSent: (String verId, int? resendToken) {
        verificationId.value = verId;
        isLoading.value = false;
        authMode.value = AuthMode.otp;
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId.value = verId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _signInWithOtp() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId.value,
      smsCode: otpController.text.trim(),
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      // SUCCESS: No navigation here. AuthWrapper handles it.
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Get.snackbar(
        'Google Sign-In Failed',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.statusRed,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    // AuthWrapper will automatically navigate to AuthScreen.
  }

  // --- Helpers ---

  // REMOVED: _handleSuccessfulAuth is no longer needed.
  // AuthWrapper is the single source of truth for navigation.

  void _handleAuthError(FirebaseAuthException e) {
    String message = 'An error occurred. Please try again.';
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found for that email. Please sign up.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'This email is already registered. Please log in.';
        break;
      case 'invalid-credential':
         message = 'The credential provided is invalid. Please check your details.';
         break;
      case 'invalid-verification-code':
        message = 'The OTP you entered is incorrect.';
        break;
    }
    Get.snackbar(
      'Authentication Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.statusRed,
      colorText: Colors.white,
    );
  }
}


// --- UI WIDGETS (No changes needed) ---
// The AuthScreen widget itself remains unchanged as its behavior
// is entirely driven by the state within the AuthController.

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            color: AppTheme.cardBackground,
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _authController.formKey,
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      ..._buildFormFields(),
                      const SizedBox(height: 16),
                      if (_authController.authMode.value == AuthMode.login)
                        _buildForgotPasswordButton(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      const SizedBox(height: 16),
                      _buildToggleModeButton(),
                      if (_authController.authMode.value != AuthMode.phone &&
                          _authController.authMode.value != AuthMode.otp) ...[
                        _buildDivider(),
                        _buildSocialLogin(),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      String title;
      switch (_authController.authMode.value) {
        case AuthMode.login:
          title = 'Welcome Back';
          break;
        case AuthMode.signup:
          title = 'Create Account';
          break;
        case AuthMode.forgotPassword:
          title = 'Reset Password';
          break;
        case AuthMode.phone:
          title = 'Enter Phone Number';
          break;
        case AuthMode.otp:
          title = 'Enter OTP';
          break;
      }
      return Text(
        title,
        style: Get.textTheme.headlineMedium,
      );
    });
  }

  List<Widget> _buildFormFields() {
    switch (_authController.authMode.value) {
      case AuthMode.login:
      case AuthMode.signup:
        return [
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField()
        ];
      case AuthMode.forgotPassword:
        return [_buildEmailField()];
      case AuthMode.phone:
        return [_buildPhoneField()];
      case AuthMode.otp:
        return [_buildOtpField()];
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _authController.emailController,
      decoration: _inputDecoration('Email Address', Icons.email_outlined),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty || !GetUtils.isEmail(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => TextFormField(
          controller: _authController.passwordController,
          obscureText: _authController.obscurePassword.value,
          decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _authController.obscurePassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.iconColor,
              ),
              onPressed: () => _authController.obscurePassword.toggle(),
            ),
          ),
          validator: (value) {
            if (_authController.authMode.value == AuthMode.signup && (value == null || value.isEmpty || value.length < 6)) {
              return 'Password must be at least 6 characters';
            }
            if (_authController.authMode.value == AuthMode.login && (value == null || value.isEmpty)) {
              return 'Password is required';
            }
            return null;
          },
        ));
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _authController.phoneController,
      decoration:
          _inputDecoration('10-digit Mobile Number', Icons.phone_outlined)
              .copyWith(
        prefixText: '+91 ',
        prefixStyle:  TextStyle(color: AppTheme.primaryText, fontSize: 16),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10)
      ],
      validator: (value) {
        if (value == null || value.isEmpty || value.length != 10) {
          return 'Please enter a valid 10-digit number';
        }
        return null;
      },
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _authController.otpController,
      decoration: _inputDecoration('6-Digit OTP', Icons.sms_outlined),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6)
      ],
      validator: (value) {
        if (value == null || value.isEmpty || value.length != 6) {
          return 'Please enter the 6-digit OTP';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _authController.switchAuthMode(AuthMode.forgotPassword),
        child:  Text('Forgot Password?', style: TextStyle(color: AppTheme.statusGreen)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      String buttonText;
      switch (_authController.authMode.value) {
        case AuthMode.login:
          buttonText = 'Login';
          break;
        case AuthMode.signup:
          buttonText = 'Sign Up';
          break;
        case AuthMode.forgotPassword:
          buttonText = 'Send Reset Link';
          break;
        case AuthMode.phone:
          buttonText = 'Send OTP';
          break;
        case AuthMode.otp:
          buttonText = 'Verify & Login';
          break;
      }
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGothic,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed:
              _authController.isLoading.value ? null : _authController.submit,
          child: _authController.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3),
                )
              : Text(buttonText,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
    });
  }

  Widget _buildToggleModeButton() {
    return Obx(() {
      AuthMode currentMode = _authController.authMode.value;
      String promptText, buttonText;
      VoidCallback onPressed;

      if (currentMode == AuthMode.login ||
          currentMode == AuthMode.forgotPassword) {
        promptText = "Don't have an account?";
        buttonText = "Sign Up";
        onPressed = () => _authController.switchAuthMode(AuthMode.signup);
      } else if (currentMode == AuthMode.signup) {
        promptText = "Already have an account?";
        buttonText = "Login";
        onPressed = () => _authController.switchAuthMode(AuthMode.login);
      } else {
        promptText = "Want to use email instead?";
        buttonText = "Login with Email";
        onPressed = () => _authController.switchAuthMode(AuthMode.login);
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(promptText,
              style:  TextStyle(color: AppTheme.secondaryText)),
          TextButton(
            onPressed: onPressed,
            child: Text(buttonText,
                style:  TextStyle(
                    color: AppTheme.statusGreen,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      );
    });
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: AppTheme.secondaryText.withOpacity(0.5))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child:
                Text('OR', style:  TextStyle(color: AppTheme.secondaryText)),
          ),
          Expanded(
              child: Divider(color: AppTheme.secondaryText.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon:  FaIcon(FontAwesomeIcons.google,
                  color: AppTheme.primaryText),
              onPressed: _authController.isLoading.value
                  ? null
                  : _authController.signInWithGoogle,
              iconSize: 28,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon:  Icon(Icons.phone_android_outlined,
                  color: AppTheme.primaryText),
              onPressed: _authController.isLoading.value
                  ? null
                  : () => _authController.switchAuthMode(AuthMode.phone),
              iconSize: 32,
            ),
          ],
        ));
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle:  TextStyle(color: AppTheme.secondaryText),
      prefixIcon: Icon(icon, color: AppTheme.iconColor),
      filled: true,
      fillColor: AppTheme.primaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppTheme.accentGothic, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppTheme.statusRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: AppTheme.statusRed, width: 2),
      ),
    );
  }
}
