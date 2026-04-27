import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'chat_ai_app.dart';

void main() async {
  print('🚀 [main_chat_ai] Starting Chat AI app...');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🚀 [main_chat_ai] Loading .env file...');
    await dotenv.load(fileName: "assets/.env");
    print('🟢 [main_chat_ai] .env file loaded successfully');
    
    // Print some env variables for debugging
    print('🔧 [main_chat_ai] OPENROUTER_BASE_URL: ${dotenv.env['OPENROUTER_BASE_URL']}');
    print('🔧 [main_chat_ai] OPENROUTER_MODEL: ${dotenv.env['OPENROUTER_MODEL']}');
    print('🔧 [main_chat_ai] OPENROUTER_API_KEY length: ${dotenv.env['OPENROUTER_API_KEY']?.length ?? 0}');
    
  } catch (e, stackTrace) {
    print('🔴 [main_chat_ai] ERROR loading .env: $e');
    print('🔴 [main_chat_ai] Stack trace: $stackTrace');
  }
  
  print('🚀 [main_chat_ai] Running app...');
  runApp(const ChatAiApp());
}