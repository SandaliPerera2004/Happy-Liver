import 'package:flutter/material.dart';
import 'screens/settings/help_feedback_submitted_screen.dart';


class SendFeedback extends StatefulWidget {
  const SendFeedback({super.key});

  @override
  State<SendFeedback> createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  int selectedRating = 4;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

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

              // Send Feedback title
              Row(
                children: const [

                  Icon(
                    Icons.chat_bubble_outline,
                    size: 29,
                    color: Colors.black,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Send Feedback",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Question
              const Text(
                "What do you think about this app?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              // Feedback text box
              Container(
                width: double.infinity,
                height: 115,
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(0),
                ),

                child: const TextField(
                  maxLines: 5,

                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Tell us what you think...",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 38),

              // Rating question
              const Text(
                "How would you rate your\nexperience?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 18),

              // Stars
              Row(
                children: List.generate(
                  5,
                      (index) {
                    final starNumber = index + 1;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = starNumber;
                        });
                      },

                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 3,
                        ),

                        child: Icon(
                          starNumber <= selectedRating
                              ? Icons.star
                              : Icons.star_border,

                          size: 32,

                          color: starNumber <= selectedRating
                              ? const Color(0xFFFFB800)
                              : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 65),

              // Submit button
              Center(
                child: SizedBox(
                  width: 203,
                  height: 30,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackSubmittedScreen(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A000),
                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),

                      padding: EdgeInsets.zero,
                    ),

                    child: const Text(
                      "Submit Feedback",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
          ],
            ),
        ),
          bottomNavigationBar: _buildBottomNavBar(context),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            color: selected ? Colors.green : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
              selected ? FontWeight.w800 : FontWeight.w700,
              color: selected ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}