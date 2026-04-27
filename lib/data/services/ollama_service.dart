// COMMENTED OUT - Using OpenRouter service instead for chat AI
/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class OllamaService {
  final String baseUrl;
  final String model;
  final String apiKey;

  OllamaService({
    String? baseUrl,
    String? model,
    String? apiKey,
  })  : baseUrl = baseUrl ?? AppConstants.ollamaBaseUrl,
        model = model ?? AppConstants.ollamaModel,
        apiKey = apiKey ?? AppConstants.ollamaApiKey;

  Future<String> generatePost(String topic) async {
    final prompt = '''Write a professional, engaging LinkedIn post about "$topic". 
Include relevant hashtags and a call to action. Keep it under 2000 characters.''';

    try {
      final isOpenAI = baseUrl.contains('/v1') || !baseUrl.contains(':11434');
      final url = isOpenAI 
          ? (baseUrl.endsWith('/') ? '${baseUrl}chat/completions' : '$baseUrl/chat/completions')
          : (baseUrl.endsWith('/') ? '${baseUrl}api/generate' : '$baseUrl/api/generate');

      print('Calling URL: $url');

      final Map<String, dynamic> body = isOpenAI
          ? {
              'model': model,
              'messages': [
                {'role': 'user', 'content': prompt}
              ],
              'stream': false,
            }
          : {
              'model': model,
              'prompt': prompt,
              'stream': false,
            };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (isOpenAI) {
          final choices = data['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) return 'No choices in response';
          return choices[0]?['message']?['content'] ?? 'No content in choice';
        }
        return data['response'] ?? 'No response field found';
      } else {
        return 'Failed to generate content. Status: ${response.statusCode}\nBody: ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
*/