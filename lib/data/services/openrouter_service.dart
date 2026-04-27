import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class OpenRouterService {
  final String baseUrl;
  final String apiKey;
  final String model;

  OpenRouterService({
    String? baseUrl,
    String? apiKey,
    String? model,
  })  : baseUrl = baseUrl ?? AppConstants.openRouterBaseUrl,
        apiKey = apiKey ?? AppConstants.openRouterApiKey,
        model = model ?? AppConstants.openRouterModel;

  Future<String> generatePost(String topic) async {
    final prompt = '''Write a professional, engaging LinkedIn post about "$topic". 
Include relevant hashtags and a call to action. Keep it under 2000 characters.''';

    final messages = [
      {
        'role': 'system',
        'content': 'You are a professional LinkedIn growth expert. Create engaging, professional posts that drive engagement and establish thought leadership.'
      },
      {
        'role': 'user',
        'content': prompt
      }
    ];

    int retries = 3;
    int retryDelaySeconds = 2;

    while (retries > 0) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://your-app.com', // Optional, for OpenRouter rankings
            'X-Title': 'LinkedIn Auto Poster', // Optional
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 1000,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final choices = data['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) return 'Failed to generate content - no response';
          return choices[0]['message']['content'] ?? 'Failed to generate content - empty response';
        } else if (response.statusCode == 429) {
          retries--;
          print('🔴 [OpenRouterService] 429 Rate Limit reached. Retrying in $retryDelaySeconds seconds... ($retries left)');
          if (retries > 0) {
            await Future.delayed(Duration(seconds: retryDelaySeconds));
            retryDelaySeconds *= 2; // Exponential backoff
            continue;
          }
          return 'Failed to generate content - Rate limit exceeded (429). Please wait a moment or switch models.';
        } else {
          return 'Failed to generate content. Status: ${response.statusCode}\nBody: ${response.body}';
        }
      } catch (e) {
        return 'Error: $e';
      }
    }
    return 'Failed to generate content after retries.';
  }
}