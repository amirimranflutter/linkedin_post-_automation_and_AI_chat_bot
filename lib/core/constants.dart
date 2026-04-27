import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // // Ollama API (Cloud)
  // static String get ollamaBaseUrl => dotenv.env['OLLAMA_BASE_URL'] ?? 'https://api.ollama.com';
  // static String get ollamaModel => dotenv.env['OLLAMA_MODEL'] ?? 'llama2';
  // static String get ollamaApiKey => dotenv.env['OLLAMA_API_KEY'] ?? '';

  // OpenRouter API
  static String get openRouterBaseUrl {
    final url = dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';
    print('🔧 [AppConstants] OpenRouter Base URL: $url');
    return url;
  }
  
  static String get openRouterModel {
    final model = dotenv.env['OPENROUTER_MODEL'] ?? 'openai/gpt-oss-120b:free';
    print('🔧 [AppConstants] OpenRouter Model: $model');
    return model;
  }
  
  static String get openRouterApiKey {
    final key = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    print('🔧 [AppConstants] OpenRouter API Key length: ${key.length}');
    print('🔧 [AppConstants] OpenRouter API Key starts with: ${key.isNotEmpty ? key.substring(0, key.length > 10 ? 10 : key.length) : 'EMPTY'}');
    return key;
  }

  // Apps Script
  static String get appsScriptUrl => dotenv.env['APPS_SCRIPT_URL'] ?? '';
  static String get appsScriptSecret => dotenv.env['APPS_SCRIPT_SECRET'] ?? '';

  // Colors
  static const String linkedinBlue = '#0A66C2';
  static const String deepBlue = '#004182';
  static const String bgTint = '#E8F0FE';
  static const String scheduledGreen = '#1A7F37';
  static const String queuedOrange = '#C05A00';
  static const String darkBackground = '#000000';
}
