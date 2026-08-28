import 'package:flutter/material.dart';

class OverallInsightData {
  final String title;
  final String message;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBgColor;
  final IconData icon;

  const OverallInsightData({
    required this.title,
    required this.message,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBgColor,
    required this.icon,
  });
}

class RecommendationCardData {
  final String tag;
  final String title;
  final String subtitle;
  final List<String> bulletPoints;
  final Color accentColor;
  final Color lightColor;
  final IconData icon;
  final String assetImagePath;

  const RecommendationCardData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.bulletPoints,
    required this.accentColor,
    required this.lightColor,
    required this.icon,
    required this.assetImagePath,
  });
}

class PersonalizedRecommendationService {
  static String _normalizeRisk(String? status) {
    final s = (status ?? '').toLowerCase().trim();
    if (s.contains('high')) return 'high';
    if (s.contains('mod')) return 'moderate';
    return 'low';
  }

  // =========================================================
  // OVERALL INSIGHT GENERATOR
  // =========================================================
  static OverallInsightData getOverallInsight({
    required String fattyLiverStatus,
    required String cholesterolStatus,
    required String overallRiskStatus,
    int? fattyLiverScore,
    int? cholesterolScore,
    int? overallScore,
  }) {
    final fl = _normalizeRisk(fattyLiverStatus);
    final ch = _normalizeRisk(cholesterolStatus);

    if (fl == 'high' && ch == 'high') {
      return const OverallInsightData(
        title: 'Critical Lifestyle Intervention Needed',
        message:
            'Your assessment indicates elevated risk for both fatty liver and cholesterol. Your liver and cardiovascular system are experiencing notable metabolic stress. Strictly limit saturated fats, fried foods, and refined sugars while adopting daily cardio and a high-fiber Mediterranean diet to help reverse liver fat buildup and restore lipid balance.',
        badgeText: 'High Priority',
        badgeColor: Color(0xFFC62828),
        badgeBgColor: Color(0xFFFFEBEE),
        icon: Icons.warning_amber_rounded,
      );
    } else if (fl == 'high' && ch == 'moderate') {
      return const OverallInsightData(
        title: 'Focus on Liver Fat Reduction',
        message:
            'Your fatty liver indicators are elevated, while cholesterol levels show moderate concern. Your primary focus should be reducing fructose, refined carbohydrates, and processed fats. Incorporating daily 30-minute brisk walks, antioxidant-rich greens, and optimal hydration will relieve hepatic fat accumulation.',
        badgeText: 'Liver Priority',
        badgeColor: Color(0xFFE65100),
        badgeBgColor: Color(0xFFFFF3E0),
        icon: Icons.priority_high_rounded,
      );
    } else if (fl == 'high' && ch == 'low') {
      return const OverallInsightData(
        title: 'Protect & Detoxify Your Liver',
        message:
            'While your cholesterol levels are well-managed, your fatty liver risk is elevated. This points to dietary or metabolic triggers specifically impacting your liver fat storage. Focus on cutting refined sugars, sweetened drinks, and late-night snacking while boosting cruciferous vegetables and daily physical activity.',
        badgeText: 'Hepatic Focus',
        badgeColor: Color(0xFFE65100),
        badgeBgColor: Color(0xFFFFF3E0),
        icon: Icons.health_and_safety_rounded,
      );
    } else if (fl == 'moderate' && ch == 'high') {
      return const OverallInsightData(
        title: 'Prioritize Lipid Management & Heart Health',
        message:
            'Your cholesterol risk is high, accompanied by moderate fatty liver risk. This profile places added stress on your arterial health and hepatic lipid clearance. Emphasize cholesterol-binding soluble fibers (oats, legumes), omega-3 rich foods, and eliminate trans/saturated fats to protect both heart and liver.',
        badgeText: 'Cardio & Liver Care',
        badgeColor: Color(0xFFD84315),
        badgeBgColor: Color(0xFFFBE9E7),
        icon: Icons.monitor_heart_rounded,
      );
    } else if (fl == 'moderate' && ch == 'moderate') {
      return const OverallInsightData(
        title: 'Proactive Steps Can Restore Optimal Health',
        message:
            'Your assessment reflects moderate risk for both fatty liver and cholesterol. With early, proactive adjustments, you can easily shift back into the optimal green zone. Emphasize home-cooked whole meals, reduce fried food intake, drink 2.5L of water daily, and aim for 30 minutes of daily physical activity.',
        badgeText: 'Proactive Action',
        badgeColor: Color(0xFFE65100),
        badgeBgColor: Color(0xFFFFF3E0),
        icon: Icons.lightbulb_outline_rounded,
      );
    } else if (fl == 'moderate' && ch == 'low') {
      return const OverallInsightData(
        title: 'Support Liver Wellness Early',
        message:
            'Your cholesterol is well-controlled, though your fatty liver indicators show moderate risk. Keep protecting your heart health while giving your liver extra care by moderating sugar intake, avoiding processed snacks, and staying active throughout the day.',
        badgeText: 'Mild Attention',
        badgeColor: Color(0xFF2E7D32),
        badgeBgColor: Color(0xFFE8F5E9),
        icon: Icons.eco_rounded,
      );
    } else if (fl == 'low' && ch == 'high') {
      return const OverallInsightData(
        title: 'Address Elevated Cholesterol Markers',
        message:
            'Your liver health indicators are strong, but your cholesterol risk is elevated. Protect your cardiovascular wellness by swapping saturated and trans fats for polyunsaturated fats, incorporating plant sterols, oats, and nuts, and maintaining a routine of regular aerobic workouts.',
        badgeText: 'Lipid Focus',
        badgeColor: Color(0xFFD84315),
        badgeBgColor: Color(0xFFFBE9E7),
        icon: Icons.favorite_border_rounded,
      );
    } else if (fl == 'low' && ch == 'moderate') {
      return const OverallInsightData(
        title: 'Maintain Liver Vitality & Balance Lipids',
        message:
            'Your liver is in great condition, with only slight moderate risk in your cholesterol profile. Maintaining balanced portion sizes, lean protein choices, and routine physical activity will help bring your cholesterol into the ideal range.',
        badgeText: 'Good Progress',
        badgeColor: Color(0xFF2E7D32),
        badgeBgColor: Color(0xFFE8F5E9),
        icon: Icons.thumb_up_alt_rounded,
      );
    } else {
      return const OverallInsightData(
        title: 'Excellent Liver & Cardiovascular Health!',
        message:
            'Fantastic work! Your assessment demonstrates low risk for both fatty liver and cholesterol. Your daily habits are effectively protecting your metabolic and liver vitality. Sustain your balanced whole-food diet, regular hydration, quality sleep, and active lifestyle to stay healthy.',
        badgeText: 'Optimal Health',
        badgeColor: Color(0xFF2E7D32),
        badgeBgColor: Color(0xFFE8F5E9),
        icon: Icons.verified_rounded,
      );
    }
  }

  // =========================================================
  // PERSONALIZED RECOMMENDATIONS (MEALS, HYDRATION, SLEEP, SUPPLEMENTS)
  // =========================================================
  static List<RecommendationCardData> getPersonalizedRecommendations({
    required String fattyLiverStatus,
    required String cholesterolStatus,
    required String overallRiskStatus,
    int? fattyLiverScore,
    int? cholesterolScore,
    int? overallScore,
  }) {
    final fl = _normalizeRisk(fattyLiverStatus);
    final ch = _normalizeRisk(cholesterolStatus);

    return [
      _buildMealsCard(fl, ch),
      _buildHydrationCard(fl, ch),
      _buildSleepCard(fl, ch),
      _buildSupplementsCard(fl, ch),
    ];
  }

  // ---------------------------------------------------------
  // 1. MEALS RECOMMENDATION
  // ---------------------------------------------------------
  static RecommendationCardData _buildMealsCard(String fl, String ch) {
    if (fl == 'high' && ch == 'high') {
      return const RecommendationCardData(
        tag: 'MEALS',
        title: 'Strict Anti-Inflammatory & Low-Lipid Diet',
        subtitle:
            'Targeted nutrition to aggressively reduce hepatic fat accumulation and clear circulating LDL cholesterol.',
        bulletPoints: [
          'Focus on cruciferous greens (broccoli, spinach), oats, lentils, and wild-caught fatty fish (salmon).',
          'Strictly eliminate deep-fried foods, palm oil, fatty red meat, and high-fructose corn syrup.',
          'Adopt gentle cooking methods: steam, bake, or boil instead of frying with heavy oils.',
        ],
        accentColor: Color(0xFFC62828),
        lightColor: Color(0xFFFFEBEE),
        icon: Icons.restaurant_menu_rounded,
        assetImagePath: 'assets/images/meal_image.png',
      );
    } else if (fl == 'high' || (fl == 'moderate' && ch != 'high')) {
      return const RecommendationCardData(
        tag: 'MEALS',
        title: 'Hepatic Fat-Reduction & Low-Glycemic Diet',
        subtitle:
            'A targeted meal plan designed to prevent excess carbohydrate conversion into liver triglycerides.',
        bulletPoints: [
          'Replace refined white carbs (white rice, white bread) with quinoa, oats, and whole grains.',
          'Eat bitter greens (kale, arugula, mustard greens) to stimulate healthy bile flow and liver cleansing.',
          'Strictly limit sugary desserts, sweetened sauces, and high-sugar fruit beverages.',
        ],
        accentColor: Color(0xFF2E7D32),
        lightColor: Color(0xFFE8F5E9),
        icon: Icons.restaurant_menu_rounded,
        assetImagePath: 'assets/images/meal_image.png',
      );
    } else if (ch == 'high') {
      return const RecommendationCardData(
        tag: 'MEALS',
        title: 'Cardio-Protective & Soluble-Fiber Diet',
        subtitle:
            'Formulated to bind and eliminate cholesterol while maintaining robust liver metabolic function.',
        bulletPoints: [
          'Consume 25–30g of soluble fiber daily from oatmeal, barley, chia seeds, and legumes.',
          'Swap butter and margarine with cold-pressed extra virgin olive oil and avocados.',
          'Snack on raw walnuts or almonds instead of processed packaged pastries.',
        ],
        accentColor: Color(0xFFD84315),
        lightColor: Color(0xFFFBE9E7),
        icon: Icons.restaurant_menu_rounded,
        assetImagePath: 'assets/images/meal_image.png',
      );
    } else if (fl == 'moderate' && ch == 'moderate') {
      return const RecommendationCardData(
        tag: 'MEALS',
        title: 'Balanced Clean Whole-Foods Diet',
        subtitle:
            'A nutrient-dense whole-foods approach to lower moderate risks before they progress.',
        bulletPoints: [
          'Fill half your plate with colorful vegetables and raw salads at both lunch and dinner.',
          'Choose lean protein sources such as skinless poultry, tofu, beans, and egg whites.',
          'Cut down takeaway and restaurant meals to at most 1 time per week.',
        ],
        accentColor: Color(0xFF2E7D32),
        lightColor: Color(0xFFE8F5E9),
        icon: Icons.restaurant_menu_rounded,
        assetImagePath: 'assets/images/meal_image.png',
      );
    } else {
      return const RecommendationCardData(
        tag: 'MEALS',
        title: 'Optimal Liver-Nourishing Maintenance Diet',
        subtitle:
            'Nutrient-rich, sustainable eating habits to preserve peak liver vitality and metabolic wellness.',
        bulletPoints: [
          'Maintain high dietary diversity with 5+ servings of colorful fruits and vegetables daily.',
          'Keep prioritizing home-cooked whole meals prepared with minimal healthy oils.',
          'Continue mindful portion control and consistent balanced meal timing.',
        ],
        accentColor: Color(0xFF2E7D32),
        lightColor: Color(0xFFE8F5E9),
        icon: Icons.restaurant_menu_rounded,
        assetImagePath: 'assets/images/meal_image.png',
      );
    }
  }

  // ---------------------------------------------------------
  // 2. HYDRATION RECOMMENDATION
  // ---------------------------------------------------------
  static RecommendationCardData _buildHydrationCard(String fl, String ch) {
    if (fl == 'high' || ch == 'high') {
      return const RecommendationCardData(
        tag: 'HYDRATION',
        title: 'Intensive Cellular Detox & Fluid Protocol',
        subtitle:
            'Critical fluid hydration to assist kidney filtration, stimulate bile flow, and reduce liver metabolic stress.',
        bulletPoints: [
          'Drink 2.5 to 3.5 Liters of pure filtered water evenly distributed throughout the day.',
          'Strictly eliminate alcohol, sweetened soda, energy drinks, and packaged juices.',
          'Enjoy 1–2 cups of unsweetened green tea or black coffee (proven liver enzyme protective benefits).',
        ],
        accentColor: Color(0xFF0288D1),
        lightColor: Color(0xFFE1F5FE),
        icon: Icons.water_drop_rounded,
        assetImagePath: 'assets/images/hydration_image.png',
      );
    } else if (fl == 'moderate' || ch == 'moderate') {
      return const RecommendationCardData(
        tag: 'HYDRATION',
        title: 'Metabolic Boost & Flush Regimen',
        subtitle:
            'Active hydration to stimulate bile secretion and flush dietary metabolic byproducts.',
        bulletPoints: [
          'Aim for 2.5 Liters of water daily; carry a reusable water bottle to monitor your intake.',
          'Start each morning with a warm glass of water with fresh lemon slices for natural antioxidant support.',
          'Replace afternoon sweetened drinks with herbal infusions (peppermint, dandelion, chamomile).',
        ],
        accentColor: Color(0xFF0288D1),
        lightColor: Color(0xFFE1F5FE),
        icon: Icons.water_drop_rounded,
        assetImagePath: 'assets/images/hydration_image.png',
      );
    } else {
      return const RecommendationCardData(
        tag: 'HYDRATION',
        title: 'Optimal Hydration & Balance',
        subtitle:
            'Sustain steady fluid equilibrium to support optimal cellular metabolism and natural liver filtration.',
        bulletPoints: [
          'Maintain 2.0 to 2.5 Liters of clean water per day based on thirst and physical activity levels.',
          'Sip water consistently across waking hours rather than drinking large quantities during meals.',
          'Infuse water with cucumber, mint, or citrus for natural electrolyte replenishment.',
        ],
        accentColor: Color(0xFF0288D1),
        lightColor: Color(0xFFE1F5FE),
        icon: Icons.water_drop_rounded,
        assetImagePath: 'assets/images/hydration_image.png',
      );
    }
  }

  // ---------------------------------------------------------
  // 3. SLEEP RECOMMENDATION
  // ---------------------------------------------------------
  static RecommendationCardData _buildSleepCard(String fl, String ch) {
    if (fl == 'high' || ch == 'high') {
      return const RecommendationCardData(
        tag: 'SLEEP',
        title: 'Circadian Repair & Deep Liver Regeneration',
        subtitle:
            'Quality nocturnal rest is vital for hepatic lipogenesis regulation and deep cellular repair.',
        bulletPoints: [
          'Ensure 7 to 9 hours of uninterrupted sleep; the liver conducts peak metabolic cleansing between 10 PM and 3 AM.',
          'Finish all heavy food intake at least 3 hours prior to sleep to prevent nocturnal metabolic overload.',
          'Avoid screens and blue light 30–45 minutes before bedtime to maximize natural melatonin release.',
        ],
        accentColor: Color(0xFF5E35B1),
        lightColor: Color(0xFFEDE7F6),
        icon: Icons.bedtime_rounded,
        assetImagePath: 'assets/images/sleep_image.png',
      );
    } else if (fl == 'moderate' || ch == 'moderate') {
      return const RecommendationCardData(
        tag: 'SLEEP',
        title: 'Restorative Sleep & Metabolic Reset',
        subtitle:
            'Consistent sleep architecture to reduce cortisol spikes that trigger insulin resistance and liver fat storage.',
        bulletPoints: [
          'Keep a strict, consistent sleep and wake schedule, including on weekends.',
          'Create an optimal sleep sanctuary: pitch dark, cool temperature (~18-20°C), and noise-free.',
          'Avoid caffeine and stimulating drinks after 2:00 PM.',
        ],
        accentColor: Color(0xFF5E35B1),
        lightColor: Color(0xFFEDE7F6),
        icon: Icons.bedtime_rounded,
        assetImagePath: 'assets/images/sleep_image.png',
      );
    } else {
      return const RecommendationCardData(
        tag: 'SLEEP',
        title: 'Consistent Sleep & Energy Preservation',
        subtitle:
            'Maintaining your healthy sleep schedule preserves balanced hormone levels and daytime metabolic stamina.',
        bulletPoints: [
          'Continue getting 7–8 hours of restful sleep every night.',
          'Spend 10–15 minutes in natural morning sunlight within 1 hour of waking to anchor your circadian rhythm.',
          'Practice light stretching or reading before bed for optimal nervous system relaxation.',
        ],
        accentColor: Color(0xFF5E35B1),
        lightColor: Color(0xFFEDE7F6),
        icon: Icons.bedtime_rounded,
        assetImagePath: 'assets/images/sleep_image.png',
      );
    }
  }

  // ---------------------------------------------------------
  // 4. SUPPLEMENTS RECOMMENDATION
  // ---------------------------------------------------------
  static RecommendationCardData _buildSupplementsCard(String fl, String ch) {
    if (fl == 'high' && ch == 'high') {
      return const RecommendationCardData(
        tag: 'SUPPLEMENTS',
        title: 'Targeted Hepato-Protective & Lipid Nutrients',
        subtitle:
            'Evidence-backed nutrients to protect liver hepatocytes and support cardiovascular lipid clearing.',
        bulletPoints: [
          'Omega-3 Fish Oil (1000–2000mg EPA/DHA): clinically shown to lower liver fat and reduce triglycerides.',
          'Milk Thistle (Silymarin): potent antioxidant support to protect liver cell membranes from oxidative stress.',
          'Consult your physician for personalized dosing of Vitamin E (d-alpha tocopherol) and Vitamin D3.',
        ],
        accentColor: Color(0xFFE65100),
        lightColor: Color(0xFFFFF3E0),
        icon: Icons.sanitizer_rounded,
        assetImagePath: 'assets/images/vitamin_image.png',
      );
    } else if (fl == 'high' || (fl == 'moderate' && ch != 'high')) {
      return const RecommendationCardData(
        tag: 'SUPPLEMENTS',
        title: 'Liver Cell Defense & Antioxidant Complex',
        subtitle:
            'Nutritional antioxidants to reduce hepatic inflammation and defend against oxidative stress.',
        bulletPoints: [
          'N-Acetyl Cysteine (NAC) or Glutathione precursors to boost your liver’s master antioxidant defenses.',
          'Vitamin D3 (1000–2000 IU) to support insulin sensitivity and liver metabolic health.',
          'Artichoke Extract or Choline to assist healthy bile production and fat emulsification.',
        ],
        accentColor: Color(0xFFE65100),
        lightColor: Color(0xFFFFF3E0),
        icon: Icons.sanitizer_rounded,
        assetImagePath: 'assets/images/vitamin_image.png',
      );
    } else if (ch == 'high') {
      return const RecommendationCardData(
        tag: 'SUPPLEMENTS',
        title: 'Plant Sterols, Soluble Fiber & CoQ10',
        subtitle:
            'Targeted compounds to help block intestinal cholesterol absorption and promote arterial health.',
        bulletPoints: [
          'Psyllium Husk Fiber (5–10g daily with water): binds cholesterol in the digestive tract for elimination.',
          'Plant Sterols and Stanols (2g daily): naturally competes with cholesterol absorption.',
          'CoQ10 (Ubiquinol 100mg) and Omega-3 for cardiovascular cellular vitality.',
        ],
        accentColor: Color(0xFFE65100),
        lightColor: Color(0xFFFFF3E0),
        icon: Icons.sanitizer_rounded,
        assetImagePath: 'assets/images/vitamin_image.png',
      );
    } else if (fl == 'moderate' && ch == 'moderate') {
      return const RecommendationCardData(
        tag: 'SUPPLEMENTS',
        title: 'Essential Metabolic Micronutrient Complex',
        subtitle:
            'Core supplements to support healthy enzymatic liver processes and steady metabolism.',
        bulletPoints: [
          'High-quality daily Multivitamin with active B-Complex vitamins (B6, B12, Folate) for liver methylation.',
          'Vitamin D3 + K2 to maintain optimal metabolic balance and vascular health.',
          'Omega-3 fatty acids (1000mg) from fish oil or algae for cellular membrane fluidity.',
        ],
        accentColor: Color(0xFFE65100),
        lightColor: Color(0xFFFFF3E0),
        icon: Icons.sanitizer_rounded,
        assetImagePath: 'assets/images/vitamin_image.png',
      );
    } else {
      return const RecommendationCardData(
        tag: 'SUPPLEMENTS',
        title: 'General Wellness & Food-First Nutrition',
        subtitle:
            'Maintain optimal micronutrient levels with whole foods, adding gentle support only as needed.',
        bulletPoints: [
          'Prioritize whole-food vitamins from diverse fruits, leafy greens, nuts, and seeds.',
          'Consider seasonal Vitamin D3 if working indoors or during low sun-exposure months.',
          'Periodic probiotic or fermented foods (kefir, yogurt, kimchi) for gut-liver axis support.',
        ],
        accentColor: Color(0xFFE65100),
        lightColor: Color(0xFFFFF3E0),
        icon: Icons.sanitizer_rounded,
        assetImagePath: 'assets/images/vitamin_image.png',
      );
    }
  }
}
