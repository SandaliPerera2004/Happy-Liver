import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happy_liver/widgets/bottom_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/services/theme_controller.dart';
import 'package:happy_liver/services/assessment_firestore_service.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/daily_routine_screen.dart';
import 'scan_page.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({
    super.key,
  });

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  bool breakfastDone = false;
  bool lunchDone = false;
  bool dinnerDone = false;
  bool snackDone = false;

  int waterConsumed = 0;

  final int waterTarget = 2000;
  final int mealsTarget = 4;

  String riskLevel = 'Low';

  String? selectedBreakfast;
  String? selectedLunch;
  String? selectedSnack;
  String? selectedDinner;

  // ============================================================
  // SRI LANKAN FOOD OPTIONS
  // ============================================================

  final Map<String, Map<String, List<String>>> foodOptions = {
    'Low': {
      'Breakfast': [
        'Kola kanda + boiled egg',
        'String hoppers + dhal curry',
        'Kurakkan roti + egg',
        'Red rice + dhal + mallung',
      ],
      'Lunch': [
        'Red rice + fish + 2 vegetables',
        'Red rice + dhal + mallung + fish',
        'Brown rice + chicken + vegetables',
        'Rice + dhal + pumpkin + gotukola',
      ],
      'Snack': [
        'Fresh papaya',
        'Guava + small handful of nuts',
        'Low-fat curd + fruit',
        'Boiled green gram',
      ],
      'Dinner': [
        'Vegetable soup + boiled egg',
        'String hoppers + dhal + vegetables',
        'Kurakkan roti + vegetable curry',
        'Small portion red rice + fish + vegetables',
      ],
    },
    'Medium': {
      'Breakfast': [
        'Kola kenda + boiled egg',
        'String hoppers + dhal (less coconut)',
        'Kurakkan roti + egg + vegetables',
        'Green gram + fresh fruit',
      ],
      'Lunch': [
        'Small portion red rice + fish + vegetables',
        'Red rice + dhal + mallung',
        'Brown rice + skinless chicken + vegetables',
        'Rice + fish curry + 2 vegetable curries',
      ],
      'Snack': [
        'Guava',
        'Papaya',
        'Boiled green gram',
        'Low-fat curd without added sugar',
      ],
      'Dinner': [
        'Vegetable soup + egg',
        'String hoppers + dhal + mallung',
        'Kurakkan roti + vegetables',
        'Small red rice portion + fish + vegetables',
      ],
    },
    'High': {
      'Breakfast': [
        'Kola kenda + boiled egg',
        'Green gram + fresh fruit',
        'Kurakkan roti + egg + mallung',
        'Small portion string hoppers + dhal',
      ],
      'Lunch': [
        'Small red rice portion + fish + vegetables',
        'Red rice + dhal + mallung',
        'Brown rice + skinless chicken + vegetables',
        'Small rice portion + 2 vegetable curries + fish',
      ],
      'Snack': [
        'Guava',
        'Papaya',
        'Boiled green gram',
        'Low-fat plain curd',
      ],
      'Dinner': [
        'Vegetable soup + boiled egg',
        'Mallung + fish + small portion kurakkan roti',
        'String hoppers + dhal + vegetables',
        'Vegetable curry + grilled/steamed fish',
      ],
    },
  };

  // ============================================================
  // FOOD IMAGES
  // ============================================================

  final Map<String, String> foodImages = {
    // Breakfast
    'Kola kanda + boiled egg':
    'assets/food/kola_kanda.jpg.jpg',
    'Kola kenda + boiled egg':
    'assets/food/kola_kanda.jpg.jpg',

    'String hoppers + dhal curry':
    'assets/food/string_hoppers_with_coconut.jpg.jpg',
    'String hoppers + dhal (less coconut)':
    'assets/food/string_hoppers_with_coconut.jpg.jpg',
    'Small portion string hoppers + dhal':
    'assets/food/string_hoppers_with_coconut.jpg.jpg',

    'Kurakkan roti + egg':
    'assets/food/kurakkan_roti.jpg.jpg',
    'Kurakkan roti + egg + vegetables':
    'assets/food/kurakkan_roti.jpg.jpg',
    'Kurakkan roti + egg + mallung':
    'assets/food/kurakkan_roti.jpg.jpg',

    'Green gram + fresh fruit':
    'assets/food/green_gram.jpg.jpg',

    // Rice meals
    'Red rice + dhal + mallung':
    'assets/food/red_rice.jpg.jpg',
    'Red rice + fish + 2 vegetables':
    'assets/food/red_rice.jpg.jpg',
    'Red rice + dhal + mallung + fish':
    'assets/food/red_rice.jpg.jpg',
    'Small portion red rice + fish + vegetables':
    'assets/food/red_rice.jpg.jpg',

    'Brown rice + chicken + vegetables':
    'assets/food/brown_rice.jpg.jpg',
    'Brown rice + skinless chicken + vegetables':
    'assets/food/brown_rice.jpg.jpg',

    'Rice + dhal + pumpkin + gotukola':
    'assets/food/red_rice.jpg.jpg',
    'Rice + fish curry + 2 vegetable curries':
    'assets/food/red_rice.jpg.jpg',
    'Rice + dhal + mallung':
    'assets/food/red_rice.jpg.jpg',

    'Small rice portion + 2 vegetable curries + fish':
    'assets/food/red_rice.jpg.jpg',

    'Vegetable curry + grilled/steamed fish':
    'assets/food/fish_vegetables.jpg.jpg',

    // Snacks
    'Fresh papaya':
    'assets/food/papaya.jpg.jpg',
    'Papaya':
    'assets/food/papaya.jpg.jpg',

    'Guava':
    'assets/food/guava.jpg.jpg',
    'Guava + small handful of nuts':
    'assets/food/guava.jpg.jpg',

    'Low-fat curd + fruit':
    'assets/food/curd_fruit.jpg.jpg',
    'Low-fat curd without added sugar':
    'assets/food/curd_fruit.jpg.jpg',
    'Low-fat plain curd':
    'assets/food/curd_fruit.jpg.jpg',

    'Boiled green gram':
    'assets/food/green_gram.jpg.jpg',

    // Dinner
    'Vegetable soup + boiled egg':
    'assets/food/vegetable_soup.jpg.jpg',
    'Vegetable soup + egg':
    'assets/food/vegetable_soup.jpg.jpg',

    'String hoppers + dhal + vegetables':
    'assets/food/string_hoppers_with_coconut.jpg.jpg',
    'String hoppers + dhal + mallung':
    'assets/food/string_hoppers_with_coconut.jpg.jpg',

    'Kurakkan roti + vegetable curry':
    'assets/food/kurakkan_roti.jpg.jpg',
    'Kurakkan roti + vegetables':
    'assets/food/kurakkan_roti.jpg.jpg',

    'Mallung + fish + small portion kurakkan roti':
    'assets/food/kurakkan_roti.jpg.jpg',
  };

  @override
  void initState() {
    super.initState();
    loadRiskLevel();
  }

  // ============================================================
  // LOAD RISK LEVEL FROM FIRESTORE
  // ============================================================

  Future<void> loadRiskLevel() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final assessment =
      await AssessmentFirestoreService.getLatestAssessmentResult();

      if (assessment == null) {
        debugPrint('No assessment found for current user.');
        return;
      }

      String overallRisk;

      if (assessment.fattyLiverRisk.name == 'high' ||
          assessment.cholesterolRisk.name == 'high') {
        overallRisk = 'High';
      } else if (assessment.fattyLiverRisk.name == 'moderate' ||
          assessment.cholesterolRisk.name == 'moderate') {
        overallRisk = 'Moderate';
      } else {
        overallRisk = 'Low';
      }

      if (!mounted) return;

      setState(() {
        riskLevel = overallRisk;
      });

      debugPrint('====================================');
      debugPrint('DIET PLAN RISK LEVEL');
      debugPrint('Fatty Liver: ${assessment.fattyLiverRisk.name}');
      debugPrint('Cholesterol: ${assessment.cholesterolRisk.name}');
      debugPrint('Overall Risk: $overallRisk');
      debugPrint('====================================');

      await FirebaseFirestore.instance
          .collection('dietPlans')
          .doc(user.uid)
          .set(
        {
          'riskLevel': overallRisk,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Could not load assessment risk level: $e');
    }
  }

  // ============================================================
  // OPEN FOOD SELECTION POPUP
  // ============================================================

  void showFoodOptions(String mealType) {
    final isDarkMode = ThemeController.isDarkMode.value;

    final options = foodOptions[riskLevel]?[mealType] ??
        foodOptions['Low']![mealType]!;

    String? currentSelection;

    if (mealType == 'Breakfast') {
      currentSelection = selectedBreakfast;
    } else if (mealType == 'Lunch') {
      currentSelection = selectedLunch;
    } else if (mealType == 'Snack') {
      currentSelection = selectedSnack;
    } else if (mealType == 'Dinner') {
      currentSelection = selectedDinner;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                25,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF8F8F4),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBDBDBD),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFFE8F0D8),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color:
                            Color(0xFF6AA55A),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                mealType,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color(
                                    0xFF354238,
                                  ),
                                ),
                              ),

                              Text(
                                'Choose a meal suitable for your $riskLevel risk level',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : const Color(
                                    0xFF777777,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Recommended choices',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...options.map(
                          (food) => GestureDetector(
                        onTap: () {
                          setPopupState(() {
                            currentSelection = food;
                          });
                        },
                        child: Container(
                          margin:
                          const EdgeInsets.only(
                            bottom: 10,
                          ),
                          padding:
                          const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: currentSelection == food
                                ? const Color(0xFFE3F0D8)
                                : isDarkMode
                                ? const Color(
                              0xFF2A2A2A,
                            )
                                : Colors.white,
                            borderRadius:
                            BorderRadius.circular(15),
                            border: Border.all(
                              color:
                              currentSelection == food
                                  ? const Color(
                                0xFF6A9F59,
                              )
                                  : isDarkMode
                                  ? const Color(
                                0xFF444444,
                              )
                                  : const Color(
                                0xFFE0E0E0,
                              ),
                              width:
                              currentSelection == food
                                  ? 1.5
                                  : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                BorderRadius.circular(
                                  10,
                                ),
                                child:
                                foodImages.containsKey(
                                  food,
                                )
                                    ? Image.asset(
                                  foodImages[
                                  food]!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (
                                      context,
                                      error,
                                      stackTrace,
                                      ) {
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      decoration:
                                      BoxDecoration(
                                        color:
                                        const Color(
                                          0xFFE8F0D8,
                                        ),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          10,
                                        ),
                                      ),
                                      child:
                                      const Icon(
                                        Icons
                                            .image_not_supported_outlined,
                                        color:
                                        Color(
                                          0xFF6AA55A,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                    : Container(
                                  width: 70,
                                  height: 70,
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(
                                      0xFFE8F0D8,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      10,
                                    ),
                                  ),
                                  child: Icon(
                                    mealType ==
                                        'Snack'
                                        ? Icons.apple
                                        : Icons
                                        .restaurant,
                                    color:
                                    const Color(
                                      0xFF6AA55A,
                                    ),
                                    size: 25,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  food,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),

                              Icon(
                                currentSelection == food
                                    ? Icons.check_circle
                                    : Icons
                                    .radio_button_unchecked,
                                color:
                                currentSelection == food
                                    ? const Color(
                                  0xFF6A9F59,
                                )
                                    : const Color(
                                  0xFFAAAAAA,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                        currentSelection == null
                            ? null
                            : () {
                          setState(() {
                            if (mealType ==
                                'Breakfast') {
                              selectedBreakfast =
                                  currentSelection;
                            } else if (mealType ==
                                'Lunch') {
                              selectedLunch =
                                  currentSelection;
                            } else if (mealType ==
                                'Snack') {
                              selectedSnack =
                                  currentSelection;
                            } else if (mealType ==
                                'Dinner') {
                              selectedDinner =
                                  currentSelection;
                            }
                          });

                          Navigator.pop(context);
                        },
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF6A9F59),
                          foregroundColor:
                          Colors.white,
                          disabledBackgroundColor:
                          const Color(0xFFCCCCCC),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Choose this meal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SAVE TODAY'S PROGRESS
  // ============================================================

  Future<void> saveTodayProgress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first.'),
        ),
      );
      return;
    }

    final today = DateTime.now();

    final dateId =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final mealsCompleted = [
      breakfastDone,
      lunchDone,
      dinnerDone,
      snackDone,
    ].where((meal) => meal).length;

    try {
      await FirebaseFirestore.instance
          .collection('dietPlans')
          .doc(user.uid)
          .collection('dailyProgress')
          .doc(dateId)
          .set({
        'mealsCompleted': mealsCompleted,
        'mealsTarget': mealsTarget,
        'completed': mealsCompleted == mealsTarget,
        'healthyChoices': mealsCompleted,
        'breakfast': selectedBreakfast,
        'lunch': selectedLunch,
        'snack': selectedSnack,
        'dinner': selectedDinner,
        'calories': 0,
        'waterConsumed': waterConsumed,
        'waterTarget': waterTarget,
        'dailyGoalCompleted':
        mealsCompleted == mealsTarget &&
            waterConsumed >= waterTarget,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Today's progress saved!"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save progress: $e'),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (
          context,
          isDarkMode,
          child,
          ) {
        final mealsCompleted = [
          breakfastDone,
          lunchDone,
          dinnerDone,
          snackDone,
        ].where((meal) => meal).length;

        final mealProgress =
            mealsCompleted / mealsTarget;

        final waterProgress =
        (waterConsumed / waterTarget)
            .clamp(0.0, 1.0);

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

            // ========================================================
            // APP BAR + SEPARATED STATUS BAR
            // ========================================================

            body: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  // ================= APP BAR =================

                  Container(
                    width: double.infinity,
                    height: 48,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1B3B1F)
                          : const Color(0xFFC7DFAE),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DailyRoutineScreen(
                                      isDarkMode:
                                      isDarkMode,
                                      onThemeChanged:
                                          (value) async {
                                        ThemeController
                                            .isDarkMode
                                            .value = value;
                                      },
                                    ),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/icons/Arrow left-circle.svg',
                            width: 30,
                            height: 30,
                            colorFilter: isDarkMode
                                ? const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            )
                                : null,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Diet Plan',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(
                                0xFF354238,
                              ),
                              fontSize: 20,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // PAGE CONTENT
                  // ==================================================

                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                      const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          Text(
                            'Your Daily Diet Plan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                              FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(
                                0xFF354238,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Choose meals that suit your $riskLevel risk level.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : const Color(
                                0xFF666666,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ================= RISK LEVEL =================

                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF253526)
                                  : const Color(
                                0xFFE8F0D8,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                15,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons
                                      .health_and_safety_outlined,
                                  color:
                                  Color(0xFF5F9950),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    'Your Risk Level',
                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.w600,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),

                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: const Color(
                                      0xFF6A9F59,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(15),
                                  ),
                                  child: Text(
                                    riskLevel,
                                    style:
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ================= MEAL PROGRESS =================

                          _progressCard(
                            title: 'Meals Today',
                            value:
                            '$mealsCompleted / $mealsTarget',
                            progress: mealProgress,
                            icon:
                            Icons.restaurant_menu,
                            isDarkMode: isDarkMode,
                          ),

                          const SizedBox(height: 16),

                          // ================= BREAKFAST =================

                          _mealTile(
                            title: 'Breakfast',
                            selectedFood:
                            selectedBreakfast,
                            completed: breakfastDone,
                            onTap: () =>
                                showFoodOptions(
                                  'Breakfast',
                                ),
                            onChanged: (value) {
                              setState(() {
                                breakfastDone = value;
                              });
                            },
                            isDarkMode: isDarkMode,
                          ),

                          // ================= LUNCH =================

                          _mealTile(
                            title: 'Lunch',
                            selectedFood: selectedLunch,
                            completed: lunchDone,
                            onTap: () =>
                                showFoodOptions(
                                  'Lunch',
                                ),
                            onChanged: (value) {
                              setState(() {
                                lunchDone = value;
                              });
                            },
                            isDarkMode: isDarkMode,
                          ),

                          // ================= SNACK =================

                          _mealTile(
                            title: 'Healthy Snack',
                            selectedFood:
                            selectedSnack,
                            completed: snackDone,
                            onTap: () =>
                                showFoodOptions(
                                  'Snack',
                                ),
                            onChanged: (value) {
                              setState(() {
                                snackDone = value;
                              });
                            },
                            isDarkMode: isDarkMode,
                          ),

                          // ================= DINNER =================

                          _mealTile(
                            title: 'Dinner',
                            selectedFood:
                            selectedDinner,
                            completed: dinnerDone,
                            onTap: () =>
                                showFoodOptions(
                                  'Dinner',
                                ),
                            onChanged: (value) {
                              setState(() {
                                dinnerDone = value;
                              });
                            },
                            isDarkMode: isDarkMode,
                          ),

                          const SizedBox(height: 14),

                          // ================= WATER =================

                          _progressCard(
                            title: 'Water',
                            value:
                            '$waterConsumed / $waterTarget ml',
                            progress: waterProgress,
                            icon:
                            Icons.water_drop_outlined,
                            isDarkMode: isDarkMode,
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  waterConsumed =
                                      (waterConsumed + 250)
                                          .clamp(
                                        0,
                                        waterTarget,
                                      );
                                });
                              },
                              style:
                              OutlinedButton.styleFrom(
                                foregroundColor:
                                isDarkMode
                                    ? Colors.white
                                    : const Color(
                                  0xFF5F9950,
                                ),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF6A9F59,
                                  ),
                                ),
                              ),
                              child:
                              const Text('+ 250 ml'),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ================= GOALS =================

                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                              border: Border.all(
                                color: const Color(
                                  0xFFBFD8A8,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  'Daily Goal',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  'Complete all 4 planned meals and reach your water target.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors
                                        .grey.shade400
                                        : const Color(
                                      0xFF666666,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'Weekly Goal',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  'Complete your daily plan at least 6 out of 7 days.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors
                                        .grey.shade400
                                        : const Color(
                                      0xFF666666,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ================= SAVE =================

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await DietPlanService()
                                      .saveDietPlan(
                                    riskLevel: riskLevel,
                                    mealsPerDay: 4,
                                    waterTarget:
                                    waterTarget,
                                    dailyGoal:
                                    'Complete all planned meals',
                                    weeklyGoal:
                                    'Complete 6 out of 7 days',
                                  );

                                  await saveTodayProgress();

                                  if (!mounted) return;

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Today's progress saved successfully!",
                                      ),
                                      backgroundColor:
                                      Color(
                                        0xFF6A9F59,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to save progress: $e',
                                      ),
                                      backgroundColor:
                                      Colors.red,
                                    ),
                                  );
                                }
                              },
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(
                                  0xFF6A9F59,
                                ),
                                foregroundColor:
                                Colors.white,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    15,
                                  ),
                                ),
                              ),
                              child: const Text(
                                "Save Today's Progress",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ================= MY SCAN =================

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ScanPage(),
                                  ),
                                );
                              },
                              style:
                              OutlinedButton.styleFrom(
                                foregroundColor:
                                isDarkMode
                                    ? Colors.white
                                    : const Color(
                                  0xFF5F9950,
                                ),
                                side:
                                const BorderSide(
                                  color: Color(
                                    0xFF6A9F59,
                                  ),
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    15,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'My Scan',
                                style: TextStyle(
                                  color:
                                  Color(0xFF5F9950),
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // BOTTOM NAVIGATION
            // ========================================================

            bottomNavigationBar:
            HappyLiverBottomNavBar(
              selectedIndex: 1,
              isDarkMode: isDarkMode,
              onThemeChanged: (value) async {
                ThemeController
                    .isDarkMode.value = value;
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _progressCard({
    required String title,
    required String value,
    required double progress,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBFD8A8),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF6AA55A),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),

              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDarkMode
                  ? const Color(0xFF39423B)
                  : const Color(0xFFE8EDE3),
              valueColor:
              const AlwaysStoppedAnimation<
                  Color>(
                Color(0xFF70A45B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MEAL TILE
  // ============================================================

  Widget _mealTile({
    required String title,
    required String? selectedFood,
    required bool completed,
    required VoidCallback onTap,
    required Function(bool) onChanged,
    required bool isDarkMode,
  }) {
    final imagePath =
    selectedFood != null &&
        foodImages.containsKey(selectedFood)
        ? foodImages[selectedFood]
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
        const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: selectedFood != null
                ? const Color(0xFFBFD8A8)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
              BorderRadius.circular(12),
              child: imagePath != null
                  ? Image.asset(
                imagePath,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return Container(
                    width: 48,
                    height: 48,
                    decoration:
                    BoxDecoration(
                      color: const Color(
                        0xFFE8F0D8,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .image_not_supported_outlined,
                      color: Color(
                        0xFF6AA55A,
                      ),
                    ),
                  );
                },
              )
                  : Container(
                width: 48,
                height: 48,
                decoration:
                BoxDecoration(
                  color: const Color(
                    0xFFE8F0D8,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  title == 'Healthy Snack'
                      ? Icons.apple
                      : Icons.restaurant,
                  color: const Color(
                    0xFF6AA55A,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 15,
                      color: isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    selectedFood ??
                        'Tap to choose a meal',
                    style: TextStyle(
                      fontSize: 11,
                      color: selectedFood != null
                          ? const Color(
                        0xFF5F9950,
                      )
                          : isDarkMode
                          ? Colors.grey.shade400
                          : const Color(
                        0xFF888888,
                      ),
                      fontWeight:
                      selectedFood != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Checkbox(
              value: completed,
              activeColor:
              const Color(0xFF6A9F59),
              onChanged: selectedFood == null
                  ? null
                  : (value) {
                onChanged(
                  value ?? false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DIET PLAN SERVICE
// ============================================================

class DietPlanService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> saveDietPlan({
    required String riskLevel,
    required int mealsPerDay,
    required int waterTarget,
    required String dailyGoal,
    required String weeklyGoal,
  }) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    final planRef =
    _firestore.collection('dietPlans').doc(
      user.uid,
    );

    await planRef.set({
      'riskLevel': riskLevel,
      'mealsPerDay': mealsPerDay,
      'waterTarget': waterTarget,
      'dailyGoal': dailyGoal,
      'weeklyGoal': weeklyGoal,
      'updatedAt':
      FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}