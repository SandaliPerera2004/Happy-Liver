import 'package:flutter/material.dart';
import 'screens/settings/help_feedback_submitted_screen.dart';

class ReportProblem extends StatefulWidget {
  const ReportProblem({super.key});

  @override
  State<ReportProblem> createState() => _ReportProblemState();
}

class _ReportProblemState extends State<ReportProblem> {
  final TextEditingController problemController =
  TextEditingController();

  @override
  void dispose() {
    problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =========================
      // BODY
      // =========================
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 38),

                    // Report a problem title
                    Row(
                      children: const [
                        Icon(
                          Icons.help_outline,
                          size: 30,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Report a problem",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // What went wrong?
                    const Text(
                      "What went wrong?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Problem text box
                    Container(
                      width: double.infinity,
                      height: 116,
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFE0E0E0),
                      child: TextField(
                        controller: problemController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Describe the problem...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Submit Report button
                    Center(
                      child: SizedBox(
                        width: 137,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            if (problemController.text
                                .trim()
                                .isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please describe the problem.",
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const FeedbackSubmittedScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF16A000),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "Submit Report",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFE5F8D8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.black,
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

  // =========================
  // BOTTOM NAVIGATION BAR
  // =========================
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.06),
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
                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // BOTTOM NAV ITEM
  // =========================
  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
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
            color:
            selected ? Colors.green : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w700,
              color:
              selected ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}