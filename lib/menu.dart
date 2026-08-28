import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.68,

      child: Container(
        color: const Color(0xFF146B0B),

        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Back button
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  top: 10,
                ),

                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_circle_left_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              // White line
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),

                child: Container(
                  height: 3,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 28),

              // Daily Routine
              menuItem(
                icon: Icons.calendar_today,
                title: "Daily Routine",
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),

              // Recommendations
              menuItem(
                icon: Icons.thumb_up_alt_outlined,
                title: "Recommendations",
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),

              // Settings
              menuItem(
                icon: Icons.settings_outlined,
                title: "Settings",
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),

        child: Row(
          children: [

            Icon(
              icon,
              color: Colors.white,
              size: 27,
            ),

            const SizedBox(width: 18),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}