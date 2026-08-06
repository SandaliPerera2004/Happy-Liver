import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final TextEditingController currentPasswordController =
  TextEditingController();
  final TextEditingController newPasswordController =
  TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              color: const Color(0xFFE6F7DA),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  _CircleIconButton(
                    iconPath: 'assets/icons/Arrow left-circle.svg',
                    iconSize: 32,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Current Password",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              _passwordField(currentPasswordController),

              const SizedBox(height: 35),

              const Text(
                "New Password",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              _passwordField(newPasswordController),

              const SizedBox(height: 35),

              const Text(
                "Confirm New Password",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              _passwordField(confirmPasswordController),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {

                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text("Passwords do not match"),
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text("Password changed successfully"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController controller) {
    bool isVisible = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          height: 45,
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),

              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade400,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }   // End _passwordField

}   // 👈 ADD THIS! End _ChangePasswordScreenState


class _CircleIconButton extends StatelessWidget {
  final String iconPath;
  final double iconSize;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.iconPath,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        iconPath,
        width: iconSize,
        height: iconSize,
      ),
    );
  }
}