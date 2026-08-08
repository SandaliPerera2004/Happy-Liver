import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/screens/profile/change_password_screen.dart';
import 'package:happy_liver/screens/profile/edit_profile_screen.dart';
// import 'package:happy_liver/screens/auth/login_screen.dart';


// TEMPORARY placeholder
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login screen placeholder')),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- Green gradient header ----------
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0B3D0B),
                      Color(0xFF136319),
                      Color(0xFF10A518),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    left: 16,
                    right: 16,
                    bottom: 40,
                  ),
                  child: Column(
                    children: [
                      // Top row: back button + logout icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircleIconButton(
                            iconPath: 'assets/icons/Arrow left-circle.svg',
                            iconSize: 10,

                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          GestureDetector(
                            onTap: () {

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                    (route) => false,
                              );
                            },
                            child: Image.asset(
                              'assets/images/logout.png',
                              width: 45,
                              height: 45,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: const ClipOval(
                          child: Image(
                            image: AssetImage('assets/images/profile_image.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Name + edit icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Shehani Liyanage',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              );
                            },
                            child: SvgPicture.asset(
                              'assets/icons/Edit.svg',
                              width: 26,
                              height: 26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- White rounded content area ----------
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- Two feature cards ----------
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:27),
                            child: SizedBox(
                              width: 145,
                              height: 135,
                              child: _FeatureCard(
                                iconPath: 'assets/images/image 19.png',
                                label: 'Weekly\nReport',
                                gradientColors: const [
                                  Color(0xFF4A6D7C),
                                  Color(0xFF96AEAE),
                                ],
                                onTap: () {},
                              ),
                            ),
                          ),

                          const SizedBox(width: 30),
                          SizedBox(
                            width: 145,
                            height: 135,
                            child: _FeatureCard(
                              iconPath: 'assets/images/image 20.png',
                              label: 'Achieved\nGoals',
                              gradientColors: const [
                                Color(0xFF9C9A0A),
                                Color(0xFFCAE650),
                              ],
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ---------- List items ----------
                      _ProfileListTile(
                        icon: Icons.sync_alt,
                        label: 'Change Password',
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      _ProfileListTile(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Premium Features',
                        onTap: () {},
                      ),
                      _ProfileListTile(
                        icon: Icons.logout,
                        label: 'Log Out',
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                                (route) => false,
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _CircleIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;
  final double iconSize;

  const _CircleIconButton({
    required this.iconPath,
    required this.onTap,
    this.iconSize = 36,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 36,
        height: 36,
        child: SvgPicture.asset(
          iconPath,
          width: 36,
          height: 36,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}


class _FeatureCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.iconPath,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 37,
                height: 37,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 8),

              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _ProfileListTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black87, size: 32),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (showDivider) ...[
              const SizedBox(height: 14),
              const Divider(height: 3
                  , color: Color(0xFFDDDDDD)),
            ],
          ],
        ),
      ),
    );
  }
}