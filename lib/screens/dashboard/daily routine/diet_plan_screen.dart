import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';


class DietPlanScreen extends StatelessWidget {
  const DietPlanScreen({super.key});

  static const Color kHeaderGreen = Color(0xFFDDF2DD);
  static const Color kGradientStart = Color(0xFF8FCB8F);
  static const Color kGradientEnd = Color(0xFF3E8E3E);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Green header bar
              Container(
                width: double.infinity,
                color: kHeaderGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                      Navigator.pop(context);
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/Arrow left-circle.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Diet Plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting + wave
                      Row(
                        children: [
                          const Text(
                            'Hello Shehani, ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Image.asset(
                            'assets/images/wave.png',
                            width: 22,
                            height: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Guided meals to match your lifestyle..!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 26),

                      _buildTipCard(
                        imagePath: 'assets/images/grilled 1.png',
                        text:
                        'Replace fried foods with boiled, grilled, or steamed options.',
                        imageOnLeft: false,
                      ),
                      const SizedBox(height: 20),

                      _buildTipCard(
                        imagePath: 'assets/images/rice.png',
                        text:
                        'Use coconut sambol sparingly; switch to dhal curry, leafy greens, and jackfruit curry.',
                        imageOnLeft: true,
                      ),
                      const SizedBox(height: 20),

                      _buildTipCard(
                        imagePath: 'assets/images/rice 2.png',
                        text:
                        'Eat oats, kurakkan (finger millet), or whole wheat bread for breakfast.',
                        imageOnLeft: false,
                      ),
                      const SizedBox(height: 20),

                      _buildTipCard(
                        imagePath: 'assets/images/food.png',
                        text: 'Reduce red meat; choose chicken or fish.',
                        imageOnLeft: true,
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

  Widget _buildTipCard({
    required String imagePath,
    required String text,
    required bool imageOnLeft,
  }) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: Image.asset(
        imagePath,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
    );

    final textWidget = Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
          ),
        ),
      ),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60),
        gradient: const LinearGradient(
          colors: [kGradientStart, kGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: imageOnLeft
            ? [image, textWidget]
            : [textWidget, image],
      ),
    );
  }
}