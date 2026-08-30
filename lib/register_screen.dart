import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register() async {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword =
        confirmPasswordController.text;

    // ==========================================================
    // EMPTY FIELD CHECK
    // ==========================================================

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Please fill all fields.');
      return;
    }

    // ==========================================================
    // PASSWORD MATCH
    // ==========================================================

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');
      return;
    }

    // ==========================================================
    // PASSWORD LENGTH
    // ==========================================================

    if (password.length < 6) {
      showMessage(
        'Password must contain at least 6 characters.',
      );
      return;
    }

    // ==========================================================
    // START LOADING
    // ==========================================================

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // STEP 1
      // CREATE FIREBASE AUTH ACCOUNT
      // ========================================================

      final UserCredential userCredential =
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Firebase user was not created.',
        );
      }

      // ========================================================
      // STEP 2
      // SAVE USER DATA TO FIRESTORE
      // ========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ========================================================
      // STEP 3
      // SIGN OUT
      // ========================================================
      //
      // Firebase automatically logs the user in after
      // createUserWithEmailAndPassword().
      //
      // But our flow is:
      //
      // Register
      //     ↓
      // Login
      //     ↓
      // Home
      //
      // Therefore sign out here.
      // ========================================================

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // ========================================================
      // STEP 4
      // SHOW SUCCESS MESSAGE
      // ========================================================

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully! Please login.',
            ),
            duration: Duration(seconds: 2),
          ),
        );

      // ========================================================
      // STEP 5
      // GO TO LOGIN SCREEN
      // ========================================================

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }

    // ==========================================================
    // FIREBASE AUTH ERRORS
    // ==========================================================

    on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
          'This email is already registered.';
          break;

        case 'invalid-email':
          message =
          'Please enter a valid email address.';
          break;

        case 'weak-password':
          message =
          'Password is too weak. Use at least 6 characters.';
          break;

        case 'network-request-failed':
          message =
          'Network error. Check your internet connection.';
          break;

        case 'operation-not-allowed':
          message =
          'Email/Password sign-in is not enabled in Firebase.';
          break;

        default:
          message =
          'Registration failed: ${e.message ?? e.code}';
      }

      showMessage(message);
    }

    // ==========================================================
    // FIRESTORE ERRORS
    // ==========================================================

    on FirebaseException catch (e) {
      showMessage(
        'Firestore error: ${e.message ?? 'Could not save user data.'}',
      );
    }

    // ==========================================================
    // OTHER ERRORS
    // ==========================================================

    catch (e) {
      showMessage(
        'Something went wrong: $e',
      );
    }

    // ==========================================================
    // STOP LOADING
    // ==========================================================

    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ==================================================
                // ICON
                // ==================================================

                const Icon(
                  Icons.favorite,
                  size: 65,
                  color: Color(0xFF22C55E),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Join Happy Liver',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // USERNAME
                // ==================================================

                TextField(
                  controller: usernameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // EMAIL
                // ==================================================

                TextField(
                  controller: emailController,
                  keyboardType:
                  TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PASSWORD
                // ==================================================

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                          !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================

                TextField(
                  controller:
                  confirmPasswordController,
                  obscureText:
                  obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => register(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword =
                          !obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // CREATE ACCOUNT BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                    isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // LOGIN LINK
                // ==================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}