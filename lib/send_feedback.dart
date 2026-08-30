import 'package:flutter/material.dart';
import 'screens/settings/help_feedback_submitted_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SendFeedback extends StatefulWidget {
  const SendFeedback({super.key});

  @override
  State<SendFeedback> createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  int selectedRating = 4;

  static const Color _green = Color(0xFF16A000);
  static const Color _lightGreenHeader = Color(0xFFE5F8D8);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);
  static const Color _darkInput = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? _darkBackground
          : Colors.white,

      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 38),

                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 29,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "Send Feedback",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Text(
                        "What do you think about this app?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        height: 115,
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? _darkInput
                              : const Color(0xFFE0E0E0),
                        ),

                        child: TextField(
                          maxLines: 5,

                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                          ),

                          cursorColor: _green,

                          decoration: InputDecoration(
                            border: InputBorder.none,

                            hintText:
                            "Tell us what you think...",

                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 38),

                      Text(
                        "How would you rate your\nexperience?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: List.generate(
                          5,
                              (index) {
                            final int starNumber =
                                index + 1;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedRating =
                                      starNumber;
                                });
                              },

                              child: Padding(
                                padding:
                                const EdgeInsets.only(
                                  right: 3,
                                ),

                                child: Icon(
                                  starNumber <=
                                      selectedRating
                                      ? Icons.star
                                      : Icons.star_border,

                                  size: 32,

                                  color: starNumber <=
                                      selectedRating
                                      ? const Color(0xFFFFB800)
                                      : isDarkMode
                                      ? Colors.white70
                                      : Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 65),

                      Center(
                        child: SizedBox(
                          width: 203,
                          height: 30,

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const FeedbackSubmittedScreen(),
                                ),
                              );
                            },

                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(6),
                              ),

                              padding: EdgeInsets.zero,
                            ),

                            child: const Text(
                              "Submit Feedback",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      _buildBottomNavBar(
        context,
        isDarkMode,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: const BoxDecoration(
        color: _lightGreenHeader,
      ),

      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            "Help & Feedback",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : Colors.white,

        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white12
                : Colors.black.withOpacity(0.06),
          ),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,

            children: [
              _bottomItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: false,
                isDarkMode: isDarkMode,

                onTap: () {
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                },
              ),

              _bottomItem(
                icon: Icons.calendar_today_outlined,
                label: 'Daily Routine',
                selected: false,
                isDarkMode: isDarkMode,

                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
                isDarkMode: isDarkMode,

                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: true,
                isDarkMode: isDarkMode,

                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 22,

            color: selected
                ? Colors.green
                : isDarkMode
                ? Colors.white60
                : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(
            label,

            style: TextStyle(
              fontSize: 10,

              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w700,

              color: selected
                  ? Colors.green
                  : isDarkMode
                  ? Colors.white60
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}