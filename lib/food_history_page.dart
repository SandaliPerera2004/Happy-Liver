import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      "image": "assets/food/avocado_salad.jpg",
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
      "image": "assets/food/berry_smoothie.jpg",
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
      "image": "assets/food/cheese_burger.jpg",
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

  Future<void> saveMealToFirebase(
      Map<String, dynamic> meal,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Food History",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // SUMMARY CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0D8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Color(0xFF6AA55A),
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Food Journey",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Keep making healthy choices!",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // TABS
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    _tabButton("Today"),
                    _tabButton("Yesterday"),
                    _tabButton("All"),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Scanned Meals",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              // MEAL CARDS
              ...meals.map(
                    (meal) => _mealCard(meal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String title) {
    final bool isSelected = selectedTab == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = title;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF9DC681)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mealCard(Map<String, dynamic> meal) {
    final String? imagePath =
    meal["image"] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // FOOD IMAGE
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0D8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: imagePath != null
                ? ClipRRect(
              borderRadius:
              BorderRadius.circular(14),
              child: Image.asset(
                imagePath,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
                  return Icon(
                    meal["icon"] ??
                        Icons.restaurant,
                    color:
                    const Color(0xFF6AA55A),
                    size: 30,
                  );
                },
              ),
            )
                : Icon(
              meal["icon"] ??
                  Icons.restaurant,
              color: const Color(0xFF6AA55A),
              size: 30,
            ),
          ),

          const SizedBox(width: 12),

          // MEAL DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  meal["name"]?.toString() ??
                      "Unknown Food",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  meal["time"]?.toString() ?? "",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF777777),
                  ),
                ),

                const SizedBox(height: 7),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      meal["calories"]?.toString() ??
                          "0 kcal",
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      meal["protein"]?.toString() ??
                          "0 g",
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      meal["carbs"]?.toString() ??
                          "0 g",
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      meal["fat"]?.toString() ??
                          "0 g",
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // SCORE
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0D8),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Text(
                  meal["score"]?.toString() ??
                      "0/100",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF527D45),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF6AA55A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}