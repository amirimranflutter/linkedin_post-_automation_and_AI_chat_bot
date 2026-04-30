import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'dart:developer' as developer;
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Try to initialize Firebase (optional - app works without it)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('🔥 [Main] Firebase initialized successfully');
  } catch (e) {
    developer.log('⚠️ [Main] Firebase initialization failed: $e');
    developer.log('📱 [Main] App will continue without Firebase features');
    // App continues without Firebase - authentication will show appropriate messages
  }

  try {
    // Load environment variables
    await dotenv.load(fileName: "assets/.env");
    developer.log('🔧 [Main] Environment variables loaded');
  } catch (e) {
    developer.log('⚠️ [Main] Failed to load .env file: $e');
    // App continues without .env - will use default values
  }
  
  runApp(const LinkedInAutoPosterApp());
}
