// import 'package:google_generative_ai/google_generative_ai.dart';
// import '../../core/constants.dart';
//
// class GeminiService {
//   late final GenerativeModel _model;
//
//   GeminiService() {
//     _model = GenerativeModel(
//       model: 'gemini-1.5-flash',
//       apiKey: AppConstants.geminiApiKey,
//     );
//   }
//
//   Future<String> generatePost(String topic) async {
//     final prompt = 'Write a professional, engaging LinkedIn post about "$topic". '
//         'Include relevant hashtags and a call to action. Keep it under 2000 characters.';
//
//     final content = [Content.text(prompt)];
//     final response = await _model.generateContent(content);
//
//     return response.text ?? 'Failed to generate content.';
//   }
// }
