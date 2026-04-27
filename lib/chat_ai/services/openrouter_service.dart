import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class OpenRouterService {
  final String baseUrl;
  final String apiKey;
  final String model;

  OpenRouterService({
    String? baseUrl,
    String? apiKey,
    String? model,
  })  : baseUrl = baseUrl ?? dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1',
        apiKey = apiKey ?? dotenv.env['OPENROUTER_API_KEY'] ?? '',
        model = model ?? dotenv.env['OPENROUTER_MODEL'] ?? 'meta-llama/llama-3-8b-instruct:free';

  Future<String> generateResponse(String userMessage) async {
    print('🔵 [OpenRouterService.generateResponse] Starting...');
    print('🔵 [OpenRouterService] Base URL: $baseUrl');
    print('🔵 [OpenRouterService] Model: $model');
    print('🔵 [OpenRouterService] API Key: ${apiKey.substring(0, 20)}...');
    print('🔵 [OpenRouterService] User message: $userMessage');

    if (apiKey.isEmpty || !apiKey.startsWith('sk-or-v1-')) {
      print('🔴 [OpenRouterService] ERROR: Invalid OpenRouter API key format');
      return 'Invalid OpenRouter API key. Key should start with "sk-or-v1-"';
    }

    final messages = [
      {
        'role': 'system',
        'content': 'You are a helpful, friendly AI assistant. Provide clear and concise responses.'
      },
      {
        'role': 'user',
        'content': userMessage
      }
    ];

    int retries = 3;
    int delaySeconds = 2;
    while (retries > 0) {
      try {
        final url = '$baseUrl/chat/completions';
        print('🔵 [OpenRouterService] Calling URL: $url (attempts left: $retries)');

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://your-app.com',
            'X-Title': 'Chat AI App',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 1000,
          }),
        );

        if (response.statusCode == 429) {
          retries--;
          print('🔴 [OpenRouterService] 429 Rate Limit. Retrying in ${delaySeconds}s... ($retries left)');
          if (retries > 0) {
            await Future.delayed(Duration(seconds: delaySeconds));
            delaySeconds *= 2;
            continue;
          }
        }
        return _handleResponse(response);
      } catch (e, stackTrace) {
        print('🔴 [OpenRouterService] EXCEPTION: $e');
        print('🔴 [OpenRouterService] Stack trace: $stackTrace');
        return 'Network error: $e';
      }
    }
    return 'Failed after retries - rate limit exceeded. Try again shortly.';
  }

  Future<String> generateWithHistory(List<MessageModel> history) async {
    print('🔵 [OpenRouterService.generateWithHistory] Starting...');
    print('🔵 [OpenRouterService] History length: ${history.length}');

    if (apiKey.isEmpty || !apiKey.startsWith('sk-or-v1-')) {
      print('🔴 [OpenRouterService] ERROR: Invalid OpenRouter API key format');
      return 'Invalid OpenRouter API key. Key should start with "sk-or-v1-"';
    }

    final messages = [
      {
        'role': 'system',
        'content': 'You are a helpful, friendly AI assistant. Provide clear and concise responses.'
      },
      for (final msg in history)
        {
          'role': msg.role,
          'content': msg.content
        }
    ];

    int retries = 3;
    int delaySeconds = 2;
    while (retries > 0) {
      try {
        final url = '$baseUrl/chat/completions';
        print('🔵 [OpenRouterService] Calling URL: $url (attempts left: $retries)');

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://your-app.com',
            'X-Title': 'Chat AI App',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 1000,
          }),
        );

        if (response.statusCode == 429) {
          retries--;
          print('🔴 [OpenRouterService] 429 Rate Limit. Retrying in ${delaySeconds}s... ($retries left)');
          if (retries > 0) {
            await Future.delayed(Duration(seconds: delaySeconds));
            delaySeconds *= 2;
            continue;
          }
        }
        return _handleResponse(response);
      } catch (e, stackTrace) {
        print('🔴 [OpenRouterService] EXCEPTION: $e');
        print('🔴 [OpenRouterService] Stack trace: $stackTrace');
        return 'Network error: $e';
      }
    }
    return 'Failed after retries - rate limit exceeded. Try again shortly.';
  }

  String _handleResponse(http.Response response) {
    print('🔵 [OpenRouterService] Response status: ${response.statusCode}');
    print('🔵 [OpenRouterService] Response body: ${response.body}');

    switch (response.statusCode) {
      case 200:
        try {
          final data = jsonDecode(response.body);
          final choices = data['choices'] as List<dynamic>?;
          
          if (choices == null || choices.isEmpty) {
            print('🔴 [OpenRouterService] ERROR: No choices in response');
            return 'No response from AI - empty choices array';
          }
          
          final content = choices[0]['message']['content'];
          if (content == null || content.toString().trim().isEmpty) {
            print('🔴 [OpenRouterService] ERROR: Empty content in response');
            return 'AI returned empty response';
          }
          
          print('🟢 [OpenRouterService] SUCCESS: Generated content length: ${content.toString().length}');
          return content.toString();
        } catch (e) {
          print('🔴 [OpenRouterService] ERROR parsing response: $e');
          return 'Error parsing AI response: $e';
        }

      case 429:
        print('🔴 [OpenRouterService] ERROR 429: Rate limit exceeded');
        return 'Rate limit exceeded. Please wait a moment and try again.';

      case 401:
        print('🔴 [OpenRouterService] ERROR 401: Invalid API key');
        return 'Invalid OpenRouter API key. Please check your configuration.';

      case 400:
        print('🔴 [OpenRouterService] ERROR 400: Bad request');
        return 'Bad request: ${response.body}';

      case 404:
        print('🔴 [OpenRouterService] ERROR 404: Model not found');
        return 'Model not found. Current model: $model';

      default:
        print('🔴 [OpenRouterService] ERROR: HTTP ${response.statusCode}');
        return 'Error ${response.statusCode}: ${response.body}';
    }
  }
}