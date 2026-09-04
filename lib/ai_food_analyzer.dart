import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiFoodAnalyzer {
  Future<Map<String, dynamic>> analyzeFood(String imagePath) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is missing from .env');
    }

    final imageBytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const prompt = '''
You are a food and nutrition analysis assistant for the Happy Liver app.

Analyze the food shown in the image.

Return ONLY valid JSON in exactly this structure:

{
  "foodName": "string",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "cholesterol": 0,
  "score": 0,
  "healthRating": "Good",
  "recommendation": "string"
}

Rules:
- calories = estimated kcal
- protein = estimated grams
- carbs = estimated grams
- fat = estimated grams
- cholesterol = estimated milligrams
- score = liver and cholesterol friendliness from 0 to 100
- healthRating must be exactly Good, Moderate, or Poor
- recommendation must be short and practical
- Estimate nutrition from the visible food and reasonable portion assumptions
- Do not diagnose diseases
- Do not claim the result is medically accurate
- If food cannot be identified, use "Food not identified"
''';

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.2,
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini error ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    final text =
    decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];

    if (text == null || text.toString().trim().isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    return jsonDecode(text.toString()) as Map<String, dynamic>;
  }
}