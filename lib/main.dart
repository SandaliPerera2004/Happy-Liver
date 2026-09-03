import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HappyLiverApp());
}

class HappyLiverApp extends StatelessWidget {
  const HappyLiverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happy Liver',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8DBB72),
        ),
      ),
      home: const ScanPage(),
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
final ImagePicker _picker = ImagePicker();
XFile? selectedImage;

@override
Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F4),

      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 52,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFC7DFAE),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4E5D48),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: Color(0xFF4E5D48),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Diet Plan',
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
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    const Text(
                      'Hello Shehani',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF354238),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Scan your food, know what’s inside',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF454545),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Food image area
                    Container(
                      width: double.infinity,
                      height: 390,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E8DF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Temporary food image placeholder
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 80,
                                color: Colors.green.shade300,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Food scan image',
                                style: TextStyle(
                                  color: Color(0xFF777777),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          // Camera icon
                          Positioned(
                            bottom: 20,
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Scan button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () async {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.camera,
                          );

                          if (image != null) {
                            setState(() {
                              selectedImage = image;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodAnalysisPage(
                                  imagePath: image.path,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9DC681),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DietPlanScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF6A9F59),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
            // Bottom navigation
            Container(
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    selected: true,
                  ),
                  _NavItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'Daily Routine',
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                  ),
                  _NavItem(
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
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 23,
          color: selected
              ? const Color(0xFF68A85B)
              : const Color(0xFF555555),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: selected
                ? const Color(0xFF68A85B)
                : const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
class FoodAnalysisPage extends StatelessWidget {
  final String imagePath;

  const FoodAnalysisPage({
    super.key,
    required this.imagePath,
  });

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
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [

                  // Back button
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

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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

            // ================= PAGE CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ================= FOOD IMAGE =================
                    Container(
                      height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7EDE0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [

                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(imagePath),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // AI scan complete
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF78A85B),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                '✓ AI scan complete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Food name
                          Positioned(
                            bottom: 10,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [

                                  const Icon(
                                    Icons.eco,
                                    color: Color(0xFF70A45B),
                                    size: 20,
                                  ),

                                  const SizedBox(width: 8),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Chicken Rice Bowl',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Confidence: 94%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      minimumSize: const Size(0, 30),
                                      side: const BorderSide(
                                        color: Color(0xFF75A95E),
                                      ),
                                    ),
                                    child: const Text(
                                      'Scan Again',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF5F944B),
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

                    const SizedBox(height: 14),

                    // ================= NUTRITION =================
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
                          Icons.water_drop_outlined,
                          '520',
                          'kcal\nCalories',
                        ),
                        _nutritionCard(
                          Icons.accessibility_new,
                          '28 g',
                          'Protein',
                        ),
                        _nutritionCard(
                          Icons.grain,
                          '62 g',
                          'Carbs',
                        ),
                        _nutritionCard(
                          Icons.water_drop,
                          '18 g',
                          'Fat',
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ================= SCORE =================
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5DC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Liver & Cholesterol Score',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '72/100',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.72,
                              minHeight: 8,
                              backgroundColor: Colors.white,
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                Color(0xFF70B85A),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Good Choice',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF559545),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ================= AI TIP =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F4D5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            '✦',
                            style: TextStyle(
                              fontSize: 28,
                              color: Color(0xFF5EA84E),
                            ),
                          ),

                          const SizedBox(width: 10),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Tip',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'This meal is a good source of protein, but reducing the rice and adding more vegetables would make it more liver-friendly.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.4,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ================= BUTTONS =================
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FoodHistoryPage(
                                newMeal: {
                                  "name": "Chicken Rice Bowl",
                                  "time": "Just now",
                                  "calories": "520 kcal",
                                  "protein": "28 g",
                                  "carbs": "62 g",
                                  "fat": "18 g",
                                  "score": "72/100",
                                  "icon": Icons.restaurant,
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F9950),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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

                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF70A45B),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'View Health Details',
                          style: TextStyle(
                            color: Color(0xFF5F9950),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= BOTTOM NAVIGATION =================
            Container(
              height: 62,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: const [

                  _BottomItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                  ),

                  _BottomItem(
                    icon: Icons.calendar_today_outlined,
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

  static Widget _nutritionCard(
      IconData icon,
      String value,
      String label,
      ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 3,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF9CC58A),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF6DA65A),
              size: 23,
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
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

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 21,
          color: const Color(0xFF6AA55A),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
// ================= FOOD HISTORY PAGE =================

class FoodHistoryPage extends StatefulWidget {
  final Map<String, dynamic>? newMeal;

  const FoodHistoryPage({
    super.key,
    this.newMeal,
  });

  @override
  State<FoodHistoryPage> createState() => _FoodHistoryPageState();
}


class _FoodHistoryPageState extends State<FoodHistoryPage> {
  String selectedTab = "Today";

  final List<Map<String, dynamic>> meals = [

    {
      "name": "Avocado Salad",
      "time": "Today, 11:30 AM",
      "calories": "320 kcal",
      "protein": "10 g",
      "carbs": "24 g",
      "fat": "22 g",
      "score": "91/100",
      "icon": Icons.eco,
    },
    {
      "name": "Berry Smoothie",
      "time": "Yesterday, 4:00 PM",
      "calories": "280 kcal",
      "protein": "6 g",
      "carbs": "34 g",
      "fat": "3 g",
      "score": "85/100",
      "icon": Icons.local_drink,
    },
    {
      "name": "Cheese Burger",
      "time": "Yesterday, 1:10 PM",
      "calories": "640 kcal",
      "protein": "32 g",
      "carbs": "45 g",
      "fat": "35 g",
      "score": "45/100",
      "icon": Icons.lunch_dining,
    },
  ];
  @override
  void initState() {
    super.initState();

    if (widget.newMeal != null) {
      meals.insert(0, widget.newMeal!);
      saveMealToFirebase(widget.newMeal!);
    }
  }
  Future<void> saveMealToFirebase(Map<String, dynamic> meal) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('foodHistory')
          .doc(user.uid)
          .collection('scans')
          .add({
        'foodName': meal['name'],
        'calories': meal['calories'],
        'protein': meal['protein'],
        'carbs': meal['carbs'],
        'fat': meal['fat'],
        'score': meal['score'],
        'time': meal['time'],
        'scannedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food saved to history!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save food: $e'),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F4),

      body: SafeArea(
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0D8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(width: 5),

                  const Text(
                    "Food History",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Your scanned meals and nutrition\ninsights at a glance",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= TABS =================
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _tabButton("Today"),
                          _tabButton("This Week"),
                          _tabButton("This Month"),
                          _tabButton("All Time"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= SUMMARY TITLE =================
                    const Text(
                      "Today's Summary",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ================= NUTRITION CARDS =================
                    Row(
                      children: [
                        Expanded(
                          child: _nutritionCard(
                            Icons.local_fire_department,
                            _totalCalories(),
                            "kcal",
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _nutritionCard(
                            Icons.fitness_center,
                            _totalProtein(),
                            "Protein",
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _nutritionCard(
                            Icons.grain,
                            _totalCarbs(),
                            "Carbs",
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _nutritionCard(
                            Icons.water_drop,
                            _totalFat(),
                            "Fat",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // ================= MEALS TITLE =================
                    const Text(
                      "Your scanned meals",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ================= MEAL LIST =================
                    ...meals.map((meal) => _mealCard(meal)),
                  ],
                ),
              ),
            ),

            // ================= BOTTOM NAVIGATION =================
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _HistoryNavItem(
                    icon: Icons.home_outlined,
                    label: "Home",
                  ),
                  _HistoryNavItem(
                    icon: Icons.calendar_today_outlined,
                    label: "Daily Routine",
                  ),
                  _HistoryNavItem(
                    icon: Icons.person_outline,
                    label: "Profile",
                  ),
                  _HistoryNavItem(
                    icon: Icons.settings_outlined,
                    label: "Settings",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _totalCalories() {
    int total = 0;

    for (final meal in meals) {
      final value = int.tryParse(
        meal["calories"]
            .toString()
            .replaceAll(RegExp(r'[^0-9]'), ''),
      ) ??
          0;

      total += value;
    }

    return total.toString();
  }

  String _totalProtein() {
    int total = 0;

    for (final meal in meals) {
      final value = int.tryParse(
        meal["protein"]
            .toString()
            .replaceAll(RegExp(r'[^0-9]'), ''),
      ) ??
          0;

      total += value;
    }

    return "$total g";
  }

  String _totalCarbs() {
    int total = 0;

    for (final meal in meals) {
      final value = int.tryParse(
        meal["carbs"]
            .toString()
            .replaceAll(RegExp(r'[^0-9]'), ''),
      ) ??
          0;

      total += value;
    }

    return "$total g";
  }

  String _totalFat() {
    int total = 0;

    for (final meal in meals) {
      final value = int.tryParse(
        meal["fat"]
            .toString()
            .replaceAll(RegExp(r'[^0-9]'), ''),
      ) ??
          0;

      total += value;
    }

    return "$total g";
  }
  // ================= TAB BUTTON =================

  Widget _tabButton(String title) {
    final bool isSelected = selectedTab == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF9DC681)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : const Color(0xFF555555),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================= NUTRITION CARD =================

  Widget _nutritionCard(
      IconData icon,
      String value,
      String label,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFBFD8A8),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6AA55A),
            size: 25,
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MEAL CARD =================

  Widget _mealCard(Map<String, dynamic> meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [

          // Food icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0D8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              meal["icon"],
              color: const Color(0xFF6AA55A),
              size: 30,
            ),
          ),

          const SizedBox(width: 12),

          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  meal["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  meal["time"],
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF777777),
                  ),
                ),

                const SizedBox(height: 7),

                Wrap(
                  spacing: 8,
                  children: [
                    Text(
                      meal["calories"],
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      meal["protein"],
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      meal["carbs"],
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      meal["fat"],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0D8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  meal["score"],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Color(0xFF6AA55A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ================= BOTTOM NAV ITEM =================

class _HistoryNavItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HistoryNavItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFF555555),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
// ================= DIET PLAN PAGE =================

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});


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

  Future<void> testFirebaseLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'sithukavindya2218@gmail.com',
        password: 'sithu2218',
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in first.'),
          ),
        );
        return;
      }

      final userId = user.uid;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase login successful!'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firebase login failed: ${e.message}',
          ),
        ),
      );
    }
  }
  Future<void> createUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .set({
        'email': user.email ?? '',
        'name': 'Sithumini',
        'age': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile created successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create profile: $e'),
        ),
      );
    }
  }
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

    final userId = user.uid;

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
          .doc(userId)
          .collection('dailyProgress')
          .doc(dateId)
          .set({
        'mealsCompleted': mealsCompleted,
        'mealsTarget': mealsTarget,
        'completed': mealsCompleted == mealsTarget,
        'healthyChoices': mealsCompleted,
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
          content: Text('Today\'s progress saved!'),
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
  @override
  Widget build(BuildContext context) {
    final mealsCompleted = [
      breakfastDone,
      lunchDone,
      dinnerDone,
      snackDone,
    ].where((meal) => meal).length;

    final mealProgress = mealsCompleted / mealsTarget;

    final waterProgress =
    (waterConsumed / waterTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFC7DFAE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF354238),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Diet Plan',
          style: TextStyle(
            color: Color(0xFF354238),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 12),

            const Text(
              'Your Daily Diet Plan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF354238),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Follow your plan and keep your liver healthy.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 20),

            // ================= MEAL PROGRESS =================

            _progressCard(
              title: 'Meals Today',
              value: '$mealsCompleted / $mealsTarget',
              progress: mealProgress,
              icon: Icons.restaurant_menu,
            ),

            const SizedBox(height: 14),

            // ================= BREAKFAST =================

            _mealTile(
              title: 'Breakfast',
              subtitle: 'Oats, fruit & low-fat yogurt',
              completed: breakfastDone,
              onChanged: (value) {
                setState(() {
                  breakfastDone = value;
                });
              },
            ),

            // ================= LUNCH =================

            _mealTile(
              title: 'Lunch',
              subtitle: 'Brown rice, vegetables & grilled chicken',
              completed: lunchDone,
              onChanged: (value) {
                setState(() {
                  lunchDone = value;
                });
              },
            ),

            // ================= SNACK =================

            _mealTile(
              title: 'Healthy Snack',
              subtitle: 'Fresh fruit & a handful of nuts',
              completed: snackDone,
              onChanged: (value) {
                setState(() {
                  snackDone = value;
                });
              },
            ),

            // ================= DINNER =================

            _mealTile(
              title: 'Dinner',
              subtitle: 'Vegetables, whole grains & lean protein',
              completed: dinnerDone,
              onChanged: (value) {
                setState(() {
                  dinnerDone = value;
                });
              },
            ),

            const SizedBox(height: 14),

            // ================= WATER =================

            _progressCard(
              title: 'Water',
              value: '$waterConsumed / $waterTarget ml',
              progress: waterProgress,
              icon: Icons.water_drop_outlined,
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        waterConsumed =
                            (waterConsumed + 250)
                                .clamp(0, waterTarget);
                      });
                    },
                    child: const Text('+ 250 ml'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= SAVE PROGRESS =================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await DietPlanService().saveDietPlan(
                      riskLevel: 'Low',
                      mealsPerDay: 4,
                      waterTarget: 2000,
                      dailyGoal: 'Complete all planned meals',
                      weeklyGoal: 'Complete 6 out of 7 days',
                    );

                    await saveTodayProgress();
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save diet plan: $e'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A9F59),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Save Today\'s Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF6A9F59),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'My Scan',
                  style: TextStyle(
                    color: Color(0xFF5F9950),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _progressCard({
    required String title,
    required String value,
    required double progress,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EDE3),
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                Color(0xFF70A45B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealTile({
    required String title,
    required String subtitle,
    required bool completed,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF6AA55A),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),

          Checkbox(
            value: completed,
            activeColor: const Color(0xFF6A9F59),
            onChanged: (value) {
              onChanged(value ?? false);
            },
          ),
        ],
      ),
    );
  }
}
// ================= FIREBASE DIET PLAN SERVICE =================

class DietPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveDietPlan({
    required String riskLevel,
    required int mealsPerDay,
    required int waterTarget,
    required String dailyGoal,
    required String weeklyGoal,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    final planRef = _firestore
        .collection('dietPlans')
        .doc(user.uid);

    await planRef.set({
      'riskLevel': riskLevel,
      'mealsPerDay': mealsPerDay,
      'waterTarget': waterTarget,
      'dailyGoal': dailyGoal,
      'weeklyGoal': weeklyGoal,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final today = DateTime.now();

    final dateId =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await planRef
        .collection('dailyProgress')
        .doc(dateId)
        .set({
      'mealsCompleted': 0,
      'mealsTarget': mealsPerDay,
      'completed': false,
      'healthyChoices': 0,
      'calories': 0,
      'waterConsumed': 0,
      'waterTarget': waterTarget,
      'dailyGoalCompleted': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}