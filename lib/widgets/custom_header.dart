import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack; // control whether back arrow is shown

  const CustomHeader({
    super.key,
    required this.title,
    this.showBack = false, // default: no back arrow
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // White status bar
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).padding.top,
          ),
        ),

        // Green title bar
        Container(
          color: Colors.green[100],
          height: kToolbarHeight,
          child: Row(
            children: [
              if (showBack) // only show back arrow when needed
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
