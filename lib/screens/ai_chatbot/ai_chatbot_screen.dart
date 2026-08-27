import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

// ============================================================================
// 🔑 GEMINI API CONFIGURATION
// Paste your Google Gemini API key below:
// You can get an API key from Google AI Studio: https://aistudio.google.com/
// ============================================================================
const String geminiApiKey = 'API_KEY';

// Default model to use (gemini-1.5-flash is fast, accurate & cost-effective)
const String geminiModel = 'gemini-3.1-flash-lite';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final List<ChatMessage> _messages;
  bool _isTyping = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _messages = [
      ChatMessage(
        text:
            "Hello! 👋 I'm your HappyLiver AI Health Assistant powered by Gemini. Ask me any question about fatty liver, cholesterol management, daily meal plans, hydration, or healthy lifestyle routines!",
        isUser: false,
      ),
    ];
  }

  Future<void> _fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final name = data['username'] as String?;
          if (name != null && name.trim().isNotEmpty) {
            if (mounted) {
              setState(() {
                _username = name.trim();
              });
            }
            return;
          }
        }

        if (mounted) {
          setState(() {
            _username = user.displayName ?? 'there';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _username = FirebaseAuth.instance.currentUser?.displayName ?? 'there';
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================================
  // GEMINI API INTEGRATION METHOD
  // ============================================================================
  Future<String> _callGeminiApi(String userPrompt) async {
    // 1. Check if the user has provided a valid API key
    if (geminiApiKey.isEmpty || geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return _getLocalSmartFallback(userPrompt);
    }

    try {
      final Uri url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey',
      );

      // Construct conversation history for multi-turn context
      final List<Map<String, dynamic>> contents = [];

      // Include recent conversation context (last 6 messages)
      final recentMessages = _messages.length > 6
          ? _messages.sublist(_messages.length - 6)
          : _messages;

      for (final msg in recentMessages) {
        contents.add({
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.text}
          ],
        });
      }

      // Add the current prompt
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userPrompt}
        ],
      });

      final Map<String, dynamic> requestBody = {
        'contents': contents,
        'systemInstruction': {
          'parts': [
            {
              'text':
                  "You are HappyLiver AI Health Assistant, an expert, empathetic, and comprehensive liver wellness and clinical nutrition specialist for an educational mobile health app. "
                  "The user's name is ${_username.isNotEmpty ? _username : 'there'}. "
                  "Provide thorough, detailed, and structured answers. Give complete explanations rather than short summaries. "
                  "Structure your response clearly with helpful sections where applicable: "
                  "\n• 🩺 Clinical Context & Explanation: Explain why this matters for the liver and cholesterol in simple terms."
                  "\n• 📋 Actionable Steps & Multi-Option Recommendations: Provide multiple practical food choices, lifestyle adjustments, and routines."
                  "\n• 🚫 What to Avoid / Key Precautions: Highlight habits, ingredients, or foods to reduce or prevent."
                  "\n• 💡 Practical Daily Tip: A motivating, easy-to-follow tip for today."
                  "\n• ⚠️ Reminder: Brief note that this is educational advice and not a replacement for a personal medical prescription."
                  "\nUse bullet points, clear spacing, and bold titles to make the information structured, engaging, and easy to read on mobile screens."
            }
          ]
        },
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 2048,
        },
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
        return "I received your message, but couldn't generate a complete response. Please try asking again!";
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'API Error';
        return "⚠️ Gemini API Error (${response.statusCode}): $errorMessage.\n\nPlease verify your API key at the top of `ai_chatbot_screen.dart`.";
      }
    } catch (e) {
      return "⚠️ Network connection issue with Gemini AI ($e).\n\nHere is comprehensive offline guidance for your question:\n\n${_getLocalSmartFallback(userPrompt)}";
    }
  }

  // Comprehensive Smart fallback when offline or before API key is entered
  String _getLocalSmartFallback(String text) {
    final String lower = text.toLowerCase();
    final name = _username.isNotEmpty ? _username : 'there';

    if (lower.contains("hi") || lower.contains("hello") || lower.contains("hey")) {
      return "Hello $name! 👋 Welcome to HappyLiver AI Health Assistant.\n\n"
          "I can help you with:\n"
          "• 🥗 Liver-friendly meal plans and recipes\n"
          "• 💧 Daily hydration and natural detox strategies\n"
          "• 🥑 Evidence-based ways to reduce LDL cholesterol\n"
          "• 🏃 Safe workouts to reverse hepatic fat accumulation\n"
          "• 😴 Sleep schedules to support liver regeneration\n\n"
          "Feel free to ask any question or tap one of the suggestion chips above!\n\n"
          "💡 Tip: Add your Google Gemini API key at the top of `ai_chatbot_screen.dart` (`geminiApiKey`) for unlimited custom AI responses.";
    } else if (lower.contains("meal") || lower.contains("food") || lower.contains("diet") || lower.contains("eat")) {
      return "🥗 Comprehensive Guide: Liver-Friendly Nutrition & Meal Planning\n\n"
          "1. Foods to Prioritize (Support Liver Repair):\n"
          "• Leafy Greens & Cruciferous Veggies: Spinach, kale, broccoli, and Brussels sprouts contain indole and glucosinolates that help break down hepatic fat.\n"
          "• Healthy Monounsaturated Fats: Extra virgin olive oil, avocados, and walnuts provide antioxidants that reduce liver enzymes.\n"
          "• Lean Proteins & Omega-3: Wild salmon, mackerel, skinless chicken, tofu, lentils, and chickpeas provide essential amino acids.\n"
          "• High-Fiber Whole Grains: Oats, quinoa, barley, and brown rice bind excess bile acids and cholesterol.\n\n"
          "2. Foods to Avoid or Minimize:\n"
          "• High-Fructose Corn Syrup & Sugary Sodas: Directly converted into triglycerides in the liver.\n"
          "• Deep-Fried & Trans-Fat Foods: Increase inflammation and cellular oxidation.\n"
          "• Ultra-Processed Meats: Sausages, bacon, and canned deli meats high in saturated fats and sodium.\n\n"
          "3. Sample Daily Liver Meal Structure:\n"
          "• Breakfast: Oatmeal with chia seeds, blueberries, and unsweetened almond milk.\n"
          "• Lunch: Grilled salmon salad with mixed greens, avocado, and lemon-olive oil dressing.\n"
          "• Dinner: Stir-fried tofu or chicken breast with broccoli, bell peppers, and quinoa.\n\n"
          "⚠️ Educational reminder: Always consult your physician or registered dietitian for customized nutrition plans.";
    } else if (lower.contains("water") || lower.contains("drink") || lower.contains("hydration")) {
      return "💧 Comprehensive Guide: Hydration & Natural Liver Cleansing\n\n"
          "1. Optimal Daily Water Intake:\n"
          "• Target: 2.5 to 3.2 liters per day (approx. 8–10 large glasses).\n"
          "• Why it matters: Water helps the kidneys filter toxins that the liver has processed, preventing cellular strain and dehydration.\n\n"
          "2. Best Liver-Supporting Beverages:\n"
          "• Pure Filtered Water: Add lemon slices for vitamin C and natural citrus bioflavonoids.\n"
          "• Green Tea: Rich in EGCG catechins which clinical studies show improve liver enzyme levels and lipid markers.\n"
          "• Black Coffee (moderate): 1–2 cups of black coffee without added sugar has been shown to slow hepatic fibrosis progression.\n\n"
          "3. Beverages to Strictly Avoid:\n"
          "• Sugary carbonated soft drinks, energy drinks, packaged fruit juices, and alcohol.\n\n"
          "💡 Daily Habit Tip: Drink 1 full glass of water immediately upon waking to kickstart liver metabolism!";
    } else if (lower.contains("sleep") || lower.contains("rest") || lower.contains("fatigue")) {
      return "😴 Comprehensive Guide: Sleep Cycles & Liver Regeneration\n\n"
          "1. The Circadian Rhythm of the Liver:\n"
          "• The liver functions on an internal biological clock. Cellular detoxification, glycogen synthesis, and tissue repair peak between 11:00 PM and 3:30 AM during slow-wave deep sleep.\n\n"
          "2. Recommendations for Restorative Sleep:\n"
          "• Target Duration: 7 to 8.5 hours of uninterrupted sleep every night.\n"
          "• Consistent Schedule: Go to sleep and wake up at the same times daily to sync metabolic hormones.\n"
          "• Evening Routine: Avoid heavy meals, caffeine, and blue-light screens within 2 hours before bed.\n\n"
          "3. Impact of Poor Sleep on Fatty Liver:\n"
          "• Chronic sleep deprivation increases cortisol (stress hormone) and insulin resistance, leading to increased fat storage in hepatic cells.";
    } else if (lower.contains("workout") || lower.contains("exercise") || lower.contains("activity")) {
      return "🏃 Comprehensive Guide: Exercise & Reversing Fatty Liver\n\n"
          "1. Recommended Exercise Routine:\n"
          "• Aerobic Exercise (150 mins/week): Brisk walking, cycling, light jogging, or swimming for 30 minutes, 5 days per week.\n"
          "• Resistance Training (2–3 sessions/week): Bodyweight squats, push-ups, light resistance bands, or lunges.\n\n"
          "2. How Physical Activity Heals the Liver:\n"
          "• Muscle contraction stimulates GLUT-4 transporters, drawing glucose directly from the bloodstream and reducing the liver's need to convert glucose into fat.\n"
          "• Helps decrease intrahepatic lipid content by up to 20–30% even without massive weight loss!\n\n"
          "3. Safe Starting Checklist:\n"
          "• Start with a 15-minute daily brisk walk.\n"
          "• Stay hydrated before, during, and after workouts.\n"
          "• Listen to your body and avoid abrupt overexertion.";
    } else if (lower.contains("cholesterol") || lower.contains("lipid")) {
      return "🥑 Comprehensive Guide: Managing & Lowering Cholesterol\n\n"
          "1. Key Dietary Changes for Lowering LDL:\n"
          "• Soluble Fiber: Consume oatmeal, barley, kidney beans, apples, and psyllium husk. Soluble fiber binds to cholesterol in the digestive system and drags it out of the body.\n"
          "• Plant Phytosterols: Found in whole grains, seeds, and unrefined plant oils, which block cholesterol absorption.\n"
          "• Replace Saturated Fats: Switch from butter, palm oil, and fatty meats to extra virgin olive oil and avocado oil.\n\n"
          "2. Exercise & HDL ('Good') Cholesterol:\n"
          "• Moderate regular cardio elevates protective HDL particles, which carry cholesterol away from arteries back to the liver for excretion.\n\n"
          "3. What to Monitor:\n"
          "• Schedule routine lipid profile blood tests with your doctor every 3–6 months to track Total Cholesterol, LDL, HDL, and Triglycerides.";
    }

    return "Thank you for reaching out, $name! Here is a detailed health perspective on your question:\n\n"
        "1. 🩺 Health Perspective:\n"
        "Maintaining a healthy liver requires an integrated approach focusing on nutrition, movement, hydration, and restful sleep.\n\n"
        "2. 📋 Core Strategies for Success:\n"
        "• Prioritize whole, unprocessed plant-forward meals rich in fiber and antioxidants.\n"
        "• Eliminate added sugars, sugary drinks, and hydrogenated oils.\n"
        "• Maintain 30 minutes of daily physical activity and drink at least 2.5L of water.\n\n"
        "💡 To get live, detailed, AI-generated answers tailored specifically to any question, paste your Google Gemini API key into `geminiApiKey` at the top of `ai_chatbot_screen.dart`!";
  }

  void _sendMessage({String? predefinedText}) async {
    final String text = predefinedText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      if (predefinedText == null) {
        _messageController.clear();
      }
      _isTyping = true;
    });

    _scrollToBottom();

    // Call Gemini API
    final String aiReply = await _callGeminiApi(text);

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: aiReply, isUser: false));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F8D8),
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/Arrow left-circle.svg',
            width: 30,
            height: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF146B0B),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/chatbot.png',
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.smart_toy, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Health Assistant",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF18321F),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Gemini AI • HappyLiver",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5A665D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Suggestion Chips
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildQuickChip("🥗 Best Liver Foods"),
                  _buildQuickChip("💧 Hydration Guide"),
                  _buildQuickChip("🏃 15-min Exercise"),
                  _buildQuickChip("😴 Sleep & Liver"),
                  _buildQuickChip("🥑 Lower Cholesterol"),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE0E0E0)),

            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Message input bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4EF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: "Ask Gemini about liver care...",
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF146B0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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

  Widget _buildQuickChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFEAF7E7),
        side: const BorderSide(color: Color(0xFFA8D7A0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () =>
            _sendMessage(predefinedText: label.substring(label.indexOf(' ') + 1)),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF146B0B),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/chatbot.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.smart_toy, color: Colors.white, size: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser ? const Color(0xFF146B0B) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: msg.isUser
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: MarkdownBody(
                data: msg.text,
                selectable: true,
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: msg.isUser ? Colors.white : const Color(0xFF1F2922),
                    fontSize: 14,
                    height: 1.45,
                  ),
                  h1: TextStyle(
                    color: msg.isUser ? Colors.white : const Color(0xFF146B0B),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  h2: TextStyle(
                    color: msg.isUser ? Colors.white : const Color(0xFF146B0B),
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  h3: TextStyle(
                    color: msg.isUser ? Colors.white : const Color(0xFF18321F),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  strong: TextStyle(
                    color: msg.isUser ? Colors.white : const Color(0xFF18321F),
                    fontWeight: FontWeight.bold,
                  ),
                  em: TextStyle(
                    color: msg.isUser ? Colors.white : const Color(0xFF1F2922),
                    fontStyle: FontStyle.italic,
                  ),
                  listBullet: TextStyle(
                    color: msg.isUser ? Colors.white : const Color(0xFF146B0B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  listIndent: 16,
                  blockSpacing: 8,
                ),
              ),
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE5F8D8),
              child: Icon(Icons.person, size: 16, color: Color(0xFF146B0B)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF146B0B),
            child: ClipOval(
              child: Image.asset(
                'assets/images/chatbot.png',
                width: 20,
                height: 20,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.smart_toy, color: Colors.white, size: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Gemini is thinking...",
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
