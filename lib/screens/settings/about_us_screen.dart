import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 2),

                    Image.asset(
                      'assets/images/liver_logo.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 2),

                    _buildBullet(
                      child: const Text(
                        'Evaluate potential fatty liver and cholesterol risk based on your responses.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.35,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildBullet(
                      child: const Text(
                        'Receive lifestyle suggestions based on your assessment results.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.35,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildBullet(
                      child: const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text:
                              'HappyLiver is an educational risk assessment tool and ',
                            ),
                            TextSpan(
                              text:
                              'does not provide medical diagnosis or treatment.',
                              style: TextStyle(
                                color: Color(0xFFEA4335),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Version Section
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    '© 2026 HappyLiver',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFDFF3DF),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),

          const Text(
            'About us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet({required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 2,
            right: 12,
          ),
          child: SvgPicture.asset(
            'assets/icons/Book.svg',
            width: 18,
            height: 18,
          ),
        ),

        Expanded(
          child: child,
        ),
      ],
    );
  }
}