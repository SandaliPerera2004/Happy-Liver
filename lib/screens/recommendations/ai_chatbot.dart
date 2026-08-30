import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/custom_header.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

// =========================================================
// GEMINI API CONFIGURATION
// =========================================================

const String geminiApiKey = 'AQ.Ab8RN6K4sghCJtEDXdDBwC1HJnrR3bTo8TxsUtuyD7etSOcULA';

const String geminiModel = 'gemini-2.5-flash';

const int maxCharacterLimit = 1000;

// =========================================================
// GEMINI SYSTEM PROMPT
// =========================================================

const String geminiSystemPrompt =
    'You are HappyLiver AI Health Assistant, an empathetic and '
    'knowledgeable health information assistant. '
    'Provide general, evidence-based guidance about fatty liver '
    'disease, cholesterol-friendly diets, nutrition, hydration, '
    'sleep, exercise, and healthy liver-supporting habits. '
    'You can also respond naturally to simple casual messages such '
    'as Hi, Hello, How are you?, Good morning, and Thank you. '
    'For casual messages, reply briefly, warmly, and naturally '
    'without unnecessary medical information. '
    'Do not claim to be a doctor or certified medical professional. '
    'Do not diagnose diseases or prescribe medication. '
    'For serious or urgent symptoms, recommend consulting a qualified '
    'healthcare professional. '
    'Keep every response strictly within 1000 characters. '
    'Format responses clearly using short paragraphs or bullet points.';

// =========================================================
// CHAT MESSAGE MODEL
// =========================================================

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

// =========================================================
// AI CHATBOT SCREEN
// =========================================================

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
          "Hello! 👋 I'm your HappyLiver AI Health Assistant powered by Gemini. "
          "How can I assist you with your liver health, diet, hydration, "
          "or daily routines today?",
      isUser: false,
    ),
  ];

  bool _isTyping = false;

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();

    if (text.isEmpty || _isTyping) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));

      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    final String aiReply = await _fetchGeminiResponse(text);

    if (!mounted) {
      return;
    }

    setState(() {
      _isTyping = false;

      _messages.add(ChatMessage(text: aiReply, isUser: false));
    });

    _scrollToBottom();
  }

  // =========================================================
  // GEMINI API
  // =========================================================

  Future<String> _fetchGeminiResponse(String prompt) async {
    if (geminiApiKey.isEmpty ||
        geminiApiKey == 'PASTE_YOUR_GEMINI_API_KEY_HERE') {
      return _generateLocalFallbackResponse(prompt);
    }

    final List<String> modelsToTry = [
      geminiModel,
      'gemini-2.5-flash-lite',
      'gemini-2.0-flash',
    ];

    for (final model in modelsToTry) {
      try {
        final Uri url = Uri.parse(
          'https://generativelanguage.googleapis.com/'
          'v1beta/models/$model:generateContent'
          '?key=$geminiApiKey',
        );

        // -----------------------------------------------------
        // RECENT CONVERSATION HISTORY
        // -----------------------------------------------------

        final List<Map<String, dynamic>> contents = [];

        final List<ChatMessage> recentMessages = _messages.length > 8
            ? _messages.sublist(_messages.length - 8)
            : _messages;

        for (final message in recentMessages) {
          contents.add({
            'role': message.isUser ? 'user' : 'model',
            'parts': [
              {'text': message.text},
            ],
          });
        }

        // -----------------------------------------------------
        // REQUEST BODY
        // -----------------------------------------------------

        final Map<String, dynamic> body = {
          'system_instruction': {
            'parts': [
              {'text': geminiSystemPrompt},
            ],
          },
          'contents': contents,
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 1000},
        };

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final dynamic data = jsonDecode(response.body);

          final List<dynamic>? candidates =
              data['candidates'] as List<dynamic>?;

          if (candidates != null && candidates.isNotEmpty) {
            final dynamic content = candidates[0]['content'];

            final List<dynamic>? parts = content?['parts'] as List<dynamic>?;

            if (parts != null && parts.isNotEmpty) {
              String resultText = parts[0]['text']?.toString() ?? '';

              if (resultText.isEmpty) {
                continue;
              }

              if (resultText.length > maxCharacterLimit) {
                resultText = resultText.substring(0, maxCharacterLimit);
              }

              return resultText.trim();
            }
          }
        }
      } catch (_) {
        // Try the next Gemini model.
      }
    }

    return _generateLocalFallbackResponse(prompt);
  }

  // =========================================================
  // LOCAL FALLBACK
  // =========================================================

  String _generateLocalFallbackResponse(String text) {
    final String lower = text.toLowerCase();

    String reply;

    if (lower.contains('hi') ||
        lower.contains('hello') ||
        lower.contains('hey')) {
      reply =
          "Hello! 👋 I'm here to support your liver health journey. "
          "Feel free to ask about liver-friendly meals, hydration, "
          "cholesterol management, exercise, or healthy daily routines.";
    } else if (lower.contains('meal') ||
        lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('diet')) {
      reply =
          "**Liver-Friendly Food Tips:**\n\n"
          "• Eat more vegetables, fruits, whole grains, and legumes.\n"
          "• Choose lean proteins such as fish, chicken, beans, and lentils.\n"
          "• Choose healthier fats such as nuts, seeds, and olive oil.\n"
          "• Limit deep-fried foods, sugary foods, and highly processed foods.";
    } else if (lower.contains('water') ||
        lower.contains('drink') ||
        lower.contains('hydration')) {
      reply =
          "**Hydration Tips:**\n\n"
          "• Drink water regularly throughout the day.\n"
          "• Choose water instead of sugary soft drinks.\n"
          "• Your individual fluid needs can vary depending on your body, "
          "activity level, and health conditions.\n"
          "• If you have been given a fluid restriction by a healthcare "
          "professional, follow their advice.";
    } else if (lower.contains('sleep') ||
        lower.contains('rest') ||
        lower.contains('night')) {
      reply =
          "**Healthy Sleep:**\n\n"
          "• Aim for around 7–9 hours of sleep each night.\n"
          "• Keep a consistent sleeping and waking schedule.\n"
          "• Reduce screen use before bedtime.\n"
          "• A comfortable and quiet sleeping environment can support "
          "better rest.";
    } else if (lower.contains('cholesterol') || lower.contains('fatty liver')) {
      reply =
          "**Fatty Liver & Cholesterol:**\n\n"
          "• Eat more soluble fiber from oats, beans, lentils, and vegetables.\n"
          "• Limit foods high in saturated and trans fats.\n"
          "• Regular physical activity can support liver and heart health.\n"
          "• Follow your healthcare professional's advice about testing "
          "and treatment.";
    } else if (lower.contains('exercise') ||
        lower.contains('walk') ||
        lower.contains('workout')) {
      reply =
          "**Physical Activity:**\n\n"
          "• Regular physical activity can support liver and heart health.\n"
          "• Walking is a simple way to stay active.\n"
          "• Start gradually if you are not currently active.\n"
          "• Choose activities that are comfortable and suitable for you.";
    } else {
      reply =
          "Healthy liver habits include balanced nutrition, regular "
          "physical activity, adequate sleep, and limiting highly "
          "processed foods and sugary drinks.\n\n"
          "What would you like to know about liver health, nutrition, "
          "cholesterol, hydration, sleep, or exercise?";
    }

    if (reply.length > maxCharacterLimit) {
      reply = reply.substring(0, maxCharacterLimit);
    }

    return reply;
  }

  // =========================================================
  // SCROLL TO BOTTOM
  // =========================================================

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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF4),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =================================================
            // YOUR CUSTOM HEADER
            // =================================================
            const CustomHeader(title: 'AI Health Assistant', showBack: true),

            // =================================================
            // CHAT MESSAGES
            // =================================================
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }

                  final ChatMessage message = _messages[index];

                  return _buildMessageBubble(message);
                },
              ),
            ),

            // =================================================
            // MESSAGE INPUT
            // =================================================
            _buildMessageInput(),
          ],
        ),
      ),

      // =======================================================
      // SHARED BOTTOM NAVIGATION
      // =======================================================
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

  // =========================================================
  // MESSAGE INPUT
  // =========================================================

  Widget _buildMessageInput() {
    return Container(
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
                  onSubmitted: (_) {
                    _sendMessage();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
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
    );
  }

  // =========================================================
  // MESSAGE BUBBLE
  // =========================================================

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF146B0B),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/chatbot.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 16,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF146B0B) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: message.isUser
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: _MarkdownMessageText(
                text: message.text,
                isUser: message.isUser,
              ),
            ),
          ),

          if (message.isUser) ...[
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

  // =========================================================
  // TYPING INDICATOR
  // =========================================================

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF000000),
            child: ClipOval(
              child: Image.asset(
                'assets/images/chatbot.png',
                width: 20,
                height: 20,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 16,
                  );
                },
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
            child: Text(
              'AI is typing...',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// MARKDOWN MESSAGE TEXT
// =========================================================

class _MarkdownMessageText extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MarkdownMessageText({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isUser ? Colors.white : const Color(0xFF1C2D1F);

    final List<String> lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _buildLine(line, baseColor)).toList(),
    );
  }

  // =========================================================
  // BUILD LINE
  // =========================================================

  Widget _buildLine(String line, Color baseColor) {
    final String trimmed = line.trim();

    if (trimmed.isEmpty) {
      return const SizedBox(height: 6);
    }

    // =======================================================
    // HEADINGS
    // =======================================================

    if (trimmed.startsWith('### ') ||
        trimmed.startsWith('## ') ||
        trimmed.startsWith('# ')) {
      final String headerText = trimmed.replaceFirst(RegExp(r'^#+\s\*'), '');

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

    // =======================================================
    // BULLET POINTS
    // =======================================================

    if (trimmed.startsWith('* ') ||
        trimmed.startsWith('- ') ||
        trimmed.startsWith('• ')) {
      final String content = trimmed.substring(2).trim();

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

            Expanded(child: _buildRichInlineText(content, baseColor)),
          ],
        ),
      );
    }

    // =======================================================
    // NUMBERED LIST
    // =======================================================

    final RegExpMatch? numMatch = RegExp(
      r'^(\d+[\.\)])\s(.*)',
    ).firstMatch(trimmed);

    if (numMatch != null) {
      final String numberPrefix = numMatch.group(1)!;

      final String content = numMatch.group(2)!;

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

            Expanded(child: _buildRichInlineText(content, baseColor)),
          ],
        ),
      );
    }

    // =======================================================
    // NORMAL TEXT
    // =======================================================

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: _buildRichInlineText(trimmed, baseColor),
    );
  }

  // =========================================================
  // RICH TEXT
  // =========================================================

  Widget _buildRichInlineText(String text, Color baseColor) {
    final List<InlineSpan> spans = [];

    final RegExp exp = RegExp(r'(\*\*[^\*]+\*\*|\*[^\*]+\*|_[^_]+_|`[^`]+`)');

    int lastIndex = 0;

    for (final Match match in exp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(color: baseColor, fontSize: 14, height: 1.38),
          ),
        );
      }

      final String matchText = match.group(0)!;

      // =====================================================
      // BOLD
      // =====================================================

      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: TextStyle(
              color: isUser ? Colors.white : const Color(0xFF18321F),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1.38,
            ),
          ),
        );
      }
      // =====================================================
      // CODE
      // =====================================================
      else if (matchText.startsWith('`') && matchText.endsWith('`')) {
        spans.add(
          WidgetSpan(
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
          ),
        );
      }
      // =====================================================
      // ITALIC
      // =====================================================
      else if ((matchText.startsWith('*') && matchText.endsWith('*')) ||
          (matchText.startsWith('_') && matchText.endsWith('_'))) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: TextStyle(
              color: baseColor,
              fontStyle: FontStyle.italic,
              fontSize: 14,
              height: 1.38,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    // =======================================================
    // REMAINING TEXT
    // =======================================================

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(color: baseColor, fontSize: 14, height: 1.38),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}
