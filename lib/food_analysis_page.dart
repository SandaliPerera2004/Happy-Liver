import 'dart:io';

import 'package:flutter/material.dart';

import 'ai_food_analyzer.dart';
import 'food_history_page.dart';

class FoodAnalysisPage extends StatefulWidget {
  final String imagePath;

  const FoodAnalysisPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<FoodAnalysisPage> createState() => _FoodAnalysisPageState();
}

class _FoodAnalysisPageState extends State<FoodAnalysisPage> {
  Map<String, dynamic>? analysis;

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _analyzeFood();
  }

  Future<void> _analyzeFood() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      analysis = null;
    });

    try {
      final result =
      await AiFoodAnalyzer().analyzeFood(widget.imagePath);

      if (!mounted) return;

      setState(() {
        analysis = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      debugPrint('GEMINI ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
        'Unable to analyze this food. Please try again.';
      });
    }
  }

  String _value(String key, String fallback) {
    final value = analysis?[key];

    if (value == null) {
      return fallback;
    }

    return value.toString();
  }

  int _score() {
    final value =
        int.tryParse(_value('score', '0')) ?? 0;

    return value.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF4),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================

            Container(
              height: 58,
              color: const Color(0xFFD9EFB8),
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF555555),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food Analysis',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF303030),
                        ),
                      ),
                      Text(
                        "here's what we found in your meal",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ================= IMAGE =================

                    Container(
                      height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7EDE0),
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(16),
                            child: widget.imagePath
                                .startsWith('assets/')
                                ? Image.asset(
                              widget.imagePath,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                                : Image.file(
                              File(widget.imagePath),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          if (!isLoading &&
                              analysis != null)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFF78A85B),
                                  borderRadius:
                                  BorderRadius.circular(
                                    15,
                                  ),
                                ),
                                child: const Text(
                                  '✓ AI scan complete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          if (analysis != null)
                            Positioned(
                              bottom: 10,
                              left: 12,
                              right: 12,
                              child: Container(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.92),
                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.eco,
                                      color:
                                      Color(0xFF70A45B),
                                      size: 20,
                                    ),

                                    const SizedBox(width: 8),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            _value(
                                              'foodName',
                                              'Food not identified',
                                            ),
                                            style:
                                            const TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                            ),
                                          ),

                                          const Text(
                                            'AI food analysis',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                              Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                      },
                                      style: OutlinedButton
                                          .styleFrom(
                                        padding:
                                        const EdgeInsets
                                            .symmetric(
                                          horizontal: 10,
                                        ),
                                        minimumSize:
                                        const Size(0, 30),
                                        side:
                                        const BorderSide(
                                          color: Color(
                                              0xFF75A95E),
                                        ),
                                      ),
                                      child: const Text(
                                        'Scan Again',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(
                                              0xFF5F944B),
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

                    const SizedBox(height: 18),

                    // ================= LOADING =================

                    if (isLoading)
                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                        child: const Column(
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF70A45B),
                            ),

                            SizedBox(height: 15),

                            Text(
                              'Analyzing your food with AI...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'Please wait a moment.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ================= ERROR =================

                    if (!isLoading &&
                        errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFFFEEEE),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 35,
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Unable to analyze this food',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              errorMessage!,
                              textAlign:
                              TextAlign.center,
                              style:
                              const TextStyle(
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 12),

                            ElevatedButton(
                              onPressed: _analyzeFood,
                              child:
                              const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),

                    // ================= RESULTS =================

                    if (!isLoading &&
                        analysis != null) ...[
                      const Text(
                        'Nutrition Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          _nutritionCard(
                            Icons
                                .local_fire_department_outlined,
                            _value(
                              'calories',
                              '--',
                            ),
                            'kcal\nCalories',
                          ),

                          _nutritionCard(
                            Icons.accessibility_new,
                            '${_value('protein', '--')} g',
                            'Protein',
                          ),

                          _nutritionCard(
                            Icons.grain,
                            '${_value('carbs', '--')} g',
                            'Carbs',
                          ),

                          _nutritionCard(
                            Icons.water_drop,
                            '${_value('fat', '--')} g',
                            'Fat',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ================= CHOLESTEROL =================

                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color:
                            const Color(0xFF9CC58A),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [
                            const Text(
                              'Estimated Cholesterol',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),

                            Text(
                              '${_value('cholesterol', '--')} mg',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                FontWeight.bold,
                                color:
                                Color(0xFF5F9950),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= SCORE =================

                      Container(
                        padding:
                        const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFEAF5DC),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                const Text(
                                  'Liver & Cholesterol Score',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),

                                Text(
                                  '${_score()}/100',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 7),

                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(
                                10,
                              ),
                              child:
                              LinearProgressIndicator(
                                value:
                                _score() / 100,
                                minHeight: 8,
                                backgroundColor:
                                Colors.white,
                                valueColor:
                                const AlwaysStoppedAnimation<
                                    Color>(
                                  Color(0xFF70B85A),
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              _value(
                                'healthRating',
                                'Moderate',
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color:
                                Color(0xFF559545),
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ================= AI TIP =================

                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFE5F4D5),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '✦',
                              style: TextStyle(
                                fontSize: 28,
                                color:
                                Color(0xFF5EA84E),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  const Text(
                                    'AI Tip',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    _value(
                                      'recommendation',
                                      'No recommendation available.',
                                    ),
                                    style:
                                    const TextStyle(
                                      fontSize: 11,
                                      height: 1.4,
                                      color:
                                      Color(0xFF555555),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= ADD TO HISTORY =================

                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FoodHistoryPage(
                                      newMeal: {
                                        "name": _value(
                                          'foodName',
                                          'Unknown Food',
                                        ),
                                        "time": "Just now",
                                        "calories":
                                        "${_value('calories', '--')} kcal",
                                        "protein":
                                        "${_value('protein', '--')} g",
                                        "carbs":
                                        "${_value('carbs', '--')} g",
                                        "fat":
                                        "${_value('fat', '--')} g",
                                        "score":
                                        "${_score()}/100",
                                        "icon":
                                        Icons.restaurant,
                                      },
                                    ),
                              ),
                            );
                          },
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF5F9950),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                          ),
                          child: const Text(
                            "Add to Today's Diet",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ================= HEALTH DETAILS =================

                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Health Details',
                                  ),
                                  content: Text(
                                    'Estimated cholesterol: '
                                        '${_value('cholesterol', '--')} mg\n\n'
                                        'Health rating: '
                                        '${_value('healthRating', 'Moderate')}\n\n'
                                        'This is an AI-generated estimate '
                                        'and should not be considered medical advice.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                      },
                                      child:
                                      const Text(
                                        'Close',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style:
                          OutlinedButton.styleFrom(
                            side:
                            const BorderSide(
                              color:
                              Color(0xFF70A45B),
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                          ),
                          child: const Text(
                            'View Health Details',
                            style: TextStyle(
                              color:
                              Color(0xFF5F9950),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ================= BOTTOM NAV =================

            Container(
              height: 62,
              decoration:
              const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: [
                  _BottomItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                  ),
                  _BottomItem(
                    icon:
                    Icons.calendar_today_outlined,
                    label: 'Daily Routine',
                  ),
                  _BottomItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                  ),
                  _BottomItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutritionCard(
      IconData icon,
      String value,
      String label,
      ) {
    return Expanded(
      child: Container(
        margin:
        const EdgeInsets.only(right: 6),
        padding:
        const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 3,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(10),
          border: Border.all(
            color:
            const Color(0xFF9CC58A),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
              const Color(0xFF6DA65A),
              size: 23,
            ),

            const SizedBox(height: 3),

            Text(
              value,
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
                fontSize: 12,
              ),
            ),

            Text(
              label,
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem
    extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(
      BuildContext context) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 21,
          color:
          const Color(0xFF6AA55A),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color:
            Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}