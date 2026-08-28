import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

// =======================================================================
// GEMINI API CONFIGURATION
// =======================================================================
// Replace with your Google Gemini API Key:
const String geminiApiKey = 'Api_key_goes_here';

// Gemini model identifier (supports 3.1/2.5/2.0 flash-lite models)
const String geminiModel = 'gemini-3.1-flash-lite';

// Maximum response character length constraint
const int maxCharacterLimit = 1000;

// System prompt instructing the AI behavior & 3000 character limit
const String geminiSystemPrompt =
    'You are HappyLiver AI Health Assistant, an empathetic and knowledgeable '
    'health information assistant. '
    'Provide general, evidence-based guidance about fatty liver disease, '
    'cholesterol-friendly diets, nutrition, hydration, sleep, exercise, '
    'and healthy liver-supporting habits. '
    'You can also respond naturally to simple casual messages such as '
    '“Hi”, “Hello”, “How are you?”, “Good morning”, and “Thank you”. '
    'For casual messages, reply briefly, warmly, and naturally without '
    'unnecessary medical information. '
    'Do not claim to be a doctor or certified medical professional. '
    'Do not diagnose diseases or prescribe medication. '
    'For serious or urgent symptoms, recommend consulting a qualified healthcare professional. '
    'CRITICAL CONSTRAINT: Keep every response strictly within 1000 characters. '
    'Format responses clearly using short paragraphs or bullet points.';

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

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! 👋 I'm your HappyLiver AI Health Assistant powered by Gemini. How can I assist you with your liver health, diet, hydration, or daily routines today?",
      isUser: false,
    ),
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Call Gemini 3.1 / Flash-Lite API
    final String aiReply = await _fetchGeminiResponse(text);

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: aiReply, isUser: false));
    });

    _scrollToBottom();
  }

  Future<String> _fetchGeminiResponse(String prompt) async {
    if (geminiApiKey.isEmpty || geminiApiKey.contains('YOUR_GEMINI_API_KEY')) {
      return _generateLocalFallbackResponse(prompt);
    }

    // Try primary flash-lite model, fallback to alternative endpoint if necessary
    final List<String> modelsToTry = [
      geminiModel,
      'gemini-2.0-flash-lite',
      'gemini-1.5-flash',
    ];

    for (final model in modelsToTry) {
      try {
        final Uri url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey',
        );

        // Build recent conversation history (last 6 messages for context)
        final List<Map<String, dynamic>> contents = [];

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

        final body = jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': geminiSystemPrompt}
            ]
          },
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        });

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              String resultText = parts[0]['text'] ?? '';
              // Enforce maximum character limit of 3000
              if (resultText.length > maxCharacterLimit) {
                resultText = resultText.substring(0, maxCharacterLimit);
              }
              return resultText.trim();
            }
          }
        }
      } catch (_) {
        // Try next model fallback
      }
    }

    return _generateLocalFallbackResponse(prompt);
  }

  String _generateLocalFallbackResponse(String text) {
    final lower = text.toLowerCase();
    String reply;

    if (lower.contains("hi") || lower.contains("hello") || lower.contains("hey")) {
      reply =
          "Hello! 👋 I'm here to support your liver health journey. Feel free to ask about liver-friendly meals, hydration goals, cholesterol management, or daily healthy routines!";
    } else if (lower.contains("meal") || lower.contains("food") || lower.contains("eat") || lower.contains("diet")) {
      reply =
          "**Key Liver-Friendly Dietary Tips:**\n\n"
          "• **Green Leafy Vegetables:** Fill half your plate with spinach, broccoli, and kale.\n"
          "• **Lean Protein:** Choose fresh fish, skinless chicken breast, lentils, and chickpeas.\n"
          "• **Healthy Fats:** Incorporate extra virgin olive oil, walnuts, and avocados.\n"
          "• **Foods to Avoid:** Strictly eliminate deep-fried snacks, processed sugars, and trans fats.";
    } else if (lower.contains("water") || lower.contains("drink") || lower.contains("hydration")) {
      reply =
          "**Optimal Hydration for Liver Detoxification:**\n\n"
          "• Aim for **2.5 to 3 liters** of pure water throughout the day.\n"
          "• Warm lemon water in the morning stimulates bile flow.\n"
          "• Green tea provides valuable **antioxidant catechins**.\n"
          "• Completely avoid sugary sodas, packaged juices, and alcohol.";
    } else if (lower.contains("sleep") || lower.contains("rest") || lower.contains("night")) {
      reply =
          "**Rest & Circadian Balance:**\n\n"
          "• Get **7–9 hours** of uninterrupted sleep nightly.\n"
          "• Finish dinner at least **3 hours before bedtime** for optimal overnight liver repair.\n"
          "• Keep a consistent bedtime to maintain hormonal balance.";
    } else if (lower.contains("cholesterol") || lower.contains("fatty liver")) {
      reply =
          "**Managing Fatty Liver & Cholesterol:**\n\n"
          "• **Soluble Fiber:** Oats, chia seeds, and legumes help bind and excrete cholesterol.\n"
          "• **Cardio Movement:** 30 minutes of brisk walking 4–5 days per week reduces liver fat.\n"
          "• **Omega-3:** Helps lower high triglyceride levels and reduces hepatic inflammation.";
    } else {
      reply =
          "Staying consistent with **balanced nutrition**, **optimal hydration (2.5L+)**, and **7–9 hours of sleep** will significantly accelerate your liver health.\n\n"
          "What specific questions do you have about liver care or nutrition today?";
    }

    if (reply.length > maxCharacterLimit) {
      reply = reply.substring(0, maxCharacterLimit);
    }
    return reply;
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
      backgroundColor: const Color(0xFFF7FCF4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Colored header area ONLY - below safe area
            Container(
              color: const Color(0xFFE5F8D8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_circle_left_outlined,
                      color: Color(0xFF146B0B),
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF146B0B),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/chatbot.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.smart_toy,
                                color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Health Assistant",
                        style: TextStyle(
                          color: Color(0xFF18321F),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Gemini Flash • Online",
                        style: TextStyle(
                          color: Color(0xFF146B0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chat message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
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
                            hintText: "Type a message...",
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
                      onTap: _sendMessage,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainNavigationScreen(initialIndex: index),
              ),
              (route) => false,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF146B0B),
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: "Daily Routine",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: "Settings",
            ),
          ],
        ),
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
                    color: Colors.grey.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: msg.isUser
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: _MarkdownMessageText(
                text: msg.text,
                isUser: msg.isUser,
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
                  "AI is typing...",
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

// =======================================================================
// MARKDOWN TEXT RENDERER FOR CLEAN GEMINI AI FORMATTING
// =======================================================================
class _MarkdownMessageText extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MarkdownMessageText({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isUser ? Colors.white : const Color(0xFF1C2D1F);
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _buildLine(line, baseColor)).toList(),
    );
  }

  Widget _buildLine(String line, Color baseColor) {
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      return const SizedBox(height: 6);
    }

    // Header 1, 2, 3 (###)
    if (trimmed.startsWith('### ') ||
        trimmed.startsWith('## ') ||
        trimmed.startsWith('# ')) {
      final headerText = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          headerText,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF146B0B),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
      );
    }

    // Bullet points (*, -, •)
    if (trimmed.startsWith('* ') ||
        trimmed.startsWith('- ') ||
        trimmed.startsWith('• ')) {
      final content = trimmed.substring(2).trim();
      return Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ',
              style: TextStyle(
                color: isUser ? Colors.white70 : const Color(0xFF146B0B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: _buildRichInlineText(content, baseColor),
            ),
          ],
        ),
      );
    }

    // Numbered list (1., 2.)
    final numMatch = RegExp(r'^(\d+[\.\)])\s*(.*)').firstMatch(trimmed);
    if (numMatch != null) {
      final numberPrefix = numMatch.group(1)!;
      final content = numMatch.group(2)!;
      return Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$numberPrefix ',
              style: TextStyle(
                color: isUser ? Colors.white70 : const Color(0xFF146B0B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: _buildRichInlineText(content, baseColor),
            ),
          ],
        ),
      );
    }

    // Regular text line
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: _buildRichInlineText(trimmed, baseColor),
    );
  }

  Widget _buildRichInlineText(String text, Color baseColor) {
    final List<InlineSpan> spans = [];

    // Parse **bold**, *italic*, and `code`
    final RegExp exp = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|_[^_]+_|`[^`]+`)');
    int lastIndex = 0;

    for (final Match match in exp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: baseColor, fontSize: 14, height: 1.38),
        ));
      }

      final matchText = match.group(0)!;
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF18321F),
            fontWeight: FontWeight.bold,
            fontSize: 14,
            height: 1.38,
          ),
        ));
      } else if (matchText.startsWith('`') && matchText.endsWith('`')) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isUser ? Colors.white24 : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              matchText.substring(1, matchText.length - 1),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                color: isUser ? Colors.white : const Color(0xFF146B0B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
      } else if ((matchText.startsWith('*') && matchText.endsWith('*')) ||
          (matchText.startsWith('_') && matchText.endsWith('_'))) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: TextStyle(
            color: baseColor,
            fontStyle: FontStyle.italic,
            fontSize: 14,
            height: 1.38,
          ),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: baseColor, fontSize: 14, height: 1.38),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
