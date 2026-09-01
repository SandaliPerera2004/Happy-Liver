import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  static const Color darkGreen = Color(0xFF155D1B);
  static const Color backgroundGreen = Color(0xFFFFFFFF);

  bool obscurePassword = true;
  bool isLoading = false;

  // Google Sign-In initialization
  late Future<void> googleSignInInitialization;

  @override
  void initState() {
    super.initState();

    googleSignInInitialization =
        GoogleSignIn.instance.initialize(
          serverClientId:
          '208141816996-1p3u0kvmbapksqndr1qhgcj218rtpr7c.apps.googleusercontent.com',
        );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // ROUTE USER AFTER LOGIN
  // ============================================================

  Future<void> routeUserAfterLogin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    debugPrint('====================================');
    debugPrint('CHECKING USER AFTER LOGIN');
    debugPrint('UID: ${user.uid}');
    debugPrint('EMAIL: ${user.email}');
    debugPrint('====================================');

    try {
      // ----------------------------------------------------------
      // GET USER DOCUMENT
      // ----------------------------------------------------------

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      debugPrint('USER DOCUMENT EXISTS: ${userDoc.exists}');
      debugPrint('USER DATA: ${userDoc.data()}');

      // ----------------------------------------------------------
      // USER DOCUMENT EXISTS
      // ----------------------------------------------------------

      if (userDoc.exists) {
        final data = userDoc.data();

        final assessmentCompleted =
        data?['assessmentCompleted'];

        debugPrint(
          'assessmentCompleted: $assessmentCompleted',
        );

        // --------------------------------------------------------
        // CASE 1:
        // ASSESSMENT COMPLETED
        // --------------------------------------------------------

        if (assessmentCompleted == true) {
          debugPrint(
            'EXISTING USER - ASSESSMENT COMPLETED',
          );

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const DashboardScreen(),
            ),
                (route) => false,
          );

          return;
        }

        // --------------------------------------------------------
        // CASE 2:
        // ASSESSMENT NOT COMPLETED
        // --------------------------------------------------------

        if (assessmentCompleted == false) {
          debugPrint(
            'USER HAS NOT COMPLETED ASSESSMENT',
          );

          if (!mounted) return;

          // TODO:
          // Replace DashboardScreen with your actual
          // assessment intro/start screen when ready.

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const DashboardScreen(),
            ),
                (route) => false,
          );

          return;
        }

        // --------------------------------------------------------
        // CASE 3:
        // FIELD DOES NOT EXIST
        // --------------------------------------------------------

        debugPrint(
          'assessmentCompleted FIELD NOT FOUND',
        );
      }

      // ----------------------------------------------------------
      // FALLBACK FOR EXISTING USERS
      // ----------------------------------------------------------
      //
      // This handles users who already completed an assessment
      // before the assessmentCompleted field was introduced.
      //
      // We check:
      //
      // users/{uid}/assessments
      //
      // ----------------------------------------------------------

      debugPrint(
        'CHECKING ASSESSMENT SUBCOLLECTION...',
      );

      final assessmentSnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .limit(1)
          .get();

      debugPrint(
        'ASSESSMENT COUNT FOUND: '
            '${assessmentSnapshot.docs.length}',
      );

      // --------------------------------------------------------
      // ASSESSMENT EXISTS
      // --------------------------------------------------------

      if (assessmentSnapshot.docs.isNotEmpty) {
        debugPrint(
          'EXISTING USER - ASSESSMENT FOUND',
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const DashboardScreen(),
          ),
              (route) => false,
        );

        return;
      }

      // --------------------------------------------------------
      // NO ASSESSMENT FOUND
      // --------------------------------------------------------

      debugPrint(
        'NO ASSESSMENT FOUND FOR THIS USER',
      );

      if (!mounted) return;

      // TODO:
      // Replace DashboardScreen with your actual
      // assessment intro/start screen when ready.

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const DashboardScreen(),
        ),
            (route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '====================================',
      );
      debugPrint(
        'ERROR WHILE CHECKING USER',
      );
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint(
        '====================================',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load your account. Please try again.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EMAIL / PASSWORD LOGIN
  // ============================================================

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email and password',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // SIGN IN
      // ----------------------------------------------------------

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      debugPrint(
        'LOGIN USER: '
            '${FirebaseAuth.instance.currentUser}',
      );

      debugPrint(
        'LOGIN UID: '
            '${FirebaseAuth.instance.currentUser?.uid}',
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // CHECK USER STATUS AND ROUTE
      // ----------------------------------------------------------

      await routeUserAfterLogin();
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message =
          'Please enter a valid email address.';
          break;

        case 'invalid-credential':
          message =
          'Incorrect email or password.';
          break;

        case 'user-not-found':
          message =
          'No account found with this email.';
          break;

        case 'wrong-password':
          message =
          'Incorrect password.';
          break;

        case 'user-disabled':
          message =
          'This account has been disabled.';
          break;

        default:
          message =
              e.message ??
                  'Login failed. Please try again.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      debugPrint(
        'EMAIL LOGIN ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================

  Future<void> signInWithGoogle() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // 1. Initialize Google Sign-In
      // ----------------------------------------------------------

      await googleSignInInitialization;

      // ----------------------------------------------------------
      // 2. Start Google account selection
      // ----------------------------------------------------------

      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      // ----------------------------------------------------------
      // 3. Get Google authentication information
      // ----------------------------------------------------------

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // ----------------------------------------------------------
      // 4. Check ID token
      // ----------------------------------------------------------

      final String? idToken =
          googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message:
          'Google did not return an ID token.',
        );
      }

      // ----------------------------------------------------------
      // 5. Create Firebase credential
      // ----------------------------------------------------------

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // ----------------------------------------------------------
      // 6. Sign in to Firebase
      // ----------------------------------------------------------

      await FirebaseAuth.instance
          .signInWithCredential(
        credential,
      );

      debugPrint(
        'GOOGLE SIGN-IN SUCCESS: '
            '${googleUser.email}',
      );

      debugPrint(
        'GOOGLE FIREBASE UID: '
            '${FirebaseAuth.instance.currentUser?.uid}',
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // 7. CHECK USER STATUS AND ROUTE
      // ----------------------------------------------------------

      await routeUserAfterLogin();
    }

    // ==========================================================
    // GOOGLE SIGN-IN ERROR
    // ==========================================================

    on GoogleSignInException catch (e) {
      debugPrint(
        '====================================',
      );
      debugPrint(
        'GOOGLE SIGN-IN ERROR',
      );
      debugPrint('Code: ${e.code}');
      debugPrint(
        'Description: ${e.description}',
      );
      debugPrint('Exception: $e');
      debugPrint(
        '====================================',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Error Code: ${e.code}\n'
                'Description: '
                '${e.description ?? "No description"}',
          ),
          duration:
          const Duration(seconds: 8),
        ),
      );
    }

    // ==========================================================
    // FIREBASE AUTH ERROR
    // ==========================================================

    on FirebaseAuthException catch (e) {
      debugPrint(
        'FIREBASE GOOGLE AUTH ERROR',
      );

      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');

      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          message =
          'An account already exists with a '
              'different sign-in method.';
          break;

        case 'invalid-credential':
          message =
          'The Google account credentials are invalid.';
          break;

        case 'operation-not-allowed':
          message =
          'Google Sign-In is not enabled in Firebase.';
          break;

        case 'invalid-verification-code':
          message =
          'The Google verification code is invalid.';
          break;

        case 'network-request-failed':
          message =
          'Network error. Please check your '
              'internet connection.';
          break;

        default:
          message =
              e.message ??
                  'Firebase Google Sign-In failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration:
          const Duration(seconds: 5),
        ),
      );
    }

    // ==========================================================
    // OTHER ERROR
    // ==========================================================

    catch (e, stackTrace) {
      debugPrint(
        'UNKNOWN GOOGLE SIGN-IN ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In error: $e',
          ),
          duration:
          const Duration(seconds: 5),
        ),
      );
    }

    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: 0.50,
            ),
            blurRadius: 6,
            offset:
            const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText:
        isPassword
            ? obscurePassword
            : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color:
            Colors.grey.shade600,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color:
            Colors.grey.shade700,
          ),
          suffixIcon:
          isPassword
              ? IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons
                  .visibility_off_outlined
                  : Icons
                  .visibility_outlined,
              size: 18,
              color:
              Colors.grey.shade700,
            ),
            onPressed: () {
              setState(() {
                obscurePassword =
                !obscurePassword;
              });
            },
          )
              : null,
          filled: true,
          fillColor:
          Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              10,
            ),
            borderSide:
            BorderSide(
              color:
              Colors.grey.shade400,
            ),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              10,
            ),
            borderSide:
            BorderSide(
              color:
              Colors.grey.shade400,
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              10,
            ),
            borderSide:
            const BorderSide(
              color: darkGreen,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SOCIAL BUTTON
  // ============================================================

  Widget buildSocialButton({
    required String text,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: Material(
        color:
        Colors.grey.shade300,
        borderRadius:
        BorderRadius.circular(
          24,
        ),
        elevation: 1,
        shadowColor:
        Colors.black.withValues(
          alpha: 1,
        ),
        child: InkWell(
          borderRadius:
          BorderRadius.circular(
            24,
          ),
          onTap:
          isLoading
              ? null
              : onTap,
          child: Container(
            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                24,
              ),
              border:
              Border.all(
                color:
                Colors.grey.shade400,
              ),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(
                  width: 9,
                ),
                Text(
                  text,
                  style:
                  const TextStyle(
                    fontSize: 14,
                    color:
                    Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      backgroundGreen,
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 80,
              ),

              const Center(
                child: Text(
                  'Welcome!',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF000000),
                  ),
                ),
              ),

              const SizedBox(
                height: 35,
              ),

              buildTextField(
                controller:
                emailController,
                hintText: 'Email',
                icon:
                Icons.email_outlined,
              ),

              const SizedBox(
                height: 20,
              ),

              buildTextField(
                controller:
                passwordController,
                hintText:
                'Password',
                icon:
                Icons.lock_outline,
                isPassword:
                true,
              ),

              Align(
                alignment:
                Alignment.centerRight,
                child: TextButton(
                  style:
                  TextButton.styleFrom(
                    padding:
                    const EdgeInsets.only(
                      top: 5,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                        const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child:
                  const Text(
                    'Forgot Password?',
                    style:
                    TextStyle(
                      color:
                      darkGreen,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Container(
                width:
                double.infinity,
                height: 48,
                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withValues(
                        alpha: 1,
                      ),
                      blurRadius: 8,
                      offset:
                      const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child:
                ElevatedButton(
                  onPressed:
                  isLoading
                      ? null
                      : login,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    darkGreen,
                    foregroundColor:
                    Colors.white,
                    disabledBackgroundColor:
                    darkGreen,
                    disabledForegroundColor:
                    Colors.white,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        7,
                      ),
                    ),
                  ),
                  child:
                  isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Text(
                    'Login',
                    style:
                    TextStyle(
                      fontSize:
                      18,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 17,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                    Divider(
                      color:
                      Colors.grey.shade400,
                    ),
                  ),
                  const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child:
                    Text(
                      'OR',
                      style:
                      TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                    Divider(
                      color:
                      Colors.grey.shade400,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              // GOOGLE BUTTON
              buildSocialButton(
                text:
                'Continue with Google',
                iconPath:
                'assets/icons/google.svg',
                onTap:
                signInWithGoogle,
              ),

              const SizedBox(
                height: 15,
              ),

              // APPLE BUTTON
              buildSocialButton(
                text:
                'Continue with Apple',
                iconPath:
                'assets/icons/apple.svg',
                onTap: () {
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                      Text(
                        'Apple Sign-In is not available yet.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 220,
              ),

              Center(
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style:
                      TextStyle(
                        fontSize: 16,
                        color:
                        Colors.black54,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                            const RegisterScreen(),
                          ),
                        );
                      },
                      child:
                      const Text(
                        'Register Now',
                        style:
                        TextStyle(
                          fontSize: 16,
                          color:
                          darkGreen,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}