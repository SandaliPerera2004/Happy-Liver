import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'food_analysis_page.dart';
import 'diet_plan_screen.dart';
import 'package:happy_liver/widgets/bottom_navigation_bar.dart';
import 'package:happy_liver/services/theme_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (
          context,
          isDarkMode,
          child,
          ) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: isDarkMode
                ? const Color(0xFF121212)
                : Colors.white,
            statusBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: isDarkMode
                ? const Color(0xFF121212)
                : const Color(0xFFF8F8F4),
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 52,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC7DFAE),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF4E5D48),
                                width: 1.5,
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/arrow left-circle.svg',
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          'AI Scan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF354238),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        20,
                        22,
                        10,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Greeting
                          Text(
                            'Hello Shehani',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF354238),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'Scan your food, know what’s inside',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF454545),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Food image area
                          Container(
                            width: double.infinity,
                            height: 390,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFE5E8DF),
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/food/scan_food.jpg',
                                    width: double.infinity,
                                    height: 390,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                // Camera icon
                                Positioned(
                                  bottom: 20,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final XFile? image =
                                      await _picker.pickImage(
                                        source:
                                        ImageSource.camera,
                                      );

                                      if (image != null &&
                                          mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FoodAnalysisPage(
                                                  imagePath:
                                                  image.path,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        color:
                                        Colors.black.withValues(
                                          alpha: 0.65,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Scan button - Gallery
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () async {
                                final XFile? image =
                                await _picker.pickImage(
                                  source: ImageSource.gallery,
                                );

                                if (image != null) {
                                  setState(() {
                                    selectedImage = image;
                                  });

                                  if (!mounted) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FoodAnalysisPage(
                                            imagePath: image.path,
                                          ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF9DC681),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'scan',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Diet Plan button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const DietPlanScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF6A9F59),
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Diet Plan',
                                style: TextStyle(
                                  color: Color(0xFF5F9950),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Common Bottom Navigation
                  HappyLiverBottomNavBar(
                    selectedIndex: 1,
                    isDarkMode: isDarkMode,
                    onThemeChanged: (value) async {
                      ThemeController.isDarkMode.value =
                          value;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}