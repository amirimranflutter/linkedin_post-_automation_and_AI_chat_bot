import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/post_model.dart';
import 'dart:developer' as developer;

class BackendRepository {
  /// Check if the backend configuration is properly set up
  bool isConfigured() {
    final url = AppConstants.appsScriptUrl;
    final secret = AppConstants.appsScriptSecret;
    
    developer.log('🔧 [BackendRepository.isConfigured] Checking configuration...');
    developer.log('🔧 [BackendRepository] Apps Script URL: ${url.isNotEmpty ? "CONFIGURED" : "NOT CONFIGURED"}');
    developer.log('🔧 [BackendRepository] Apps Script Secret: ${secret.isNotEmpty ? "CONFIGURED" : "NOT CONFIGURED"}');
    
    final configured = url.isNotEmpty && secret.isNotEmpty;
    developer.log('🔧 [BackendRepository] Configuration status: ${configured ? "READY" : "INCOMPLETE"}');
    
    return configured;
  }

  Future<bool> schedulePost(PostModel post) async {
    developer.log('🟠 [BackendRepository.schedulePost] Starting...');
    developer.log('🟠 [BackendRepository] Post ID: ${post.id}');
    developer.log('🟠 [BackendRepository] Topic: ${post.topic}');
    developer.log('🟠 [BackendRepository] Scheduled at: ${post.scheduledAt}');
    developer.log('🟠 [BackendRepository] Status: ${post.status}');
    
    try {
      final url = AppConstants.appsScriptUrl;
      final secret = AppConstants.appsScriptSecret;
      
      developer.log('🟠 [BackendRepository] Apps Script URL: ${url.isNotEmpty ? url : "NOT CONFIGURED"}');
      developer.log('🟠 [BackendRepository] Apps Script Secret: ${secret.isNotEmpty ? "CONFIGURED (${secret.length} chars)" : "NOT CONFIGURED"}');
      
      if (url.isEmpty) {
        developer.log('🔴 [BackendRepository] ERROR: Apps Script URL is empty - check APPS_SCRIPT_URL in .env file');
        return false;
      }

      if (secret.isEmpty) {
        developer.log('🔴 [BackendRepository] ERROR: Apps Script Secret is empty - check APPS_SCRIPT_SECRET in .env file');
        return false;
      }

      final postData = post.toJson();
      developer.log('🟠 [BackendRepository] Post data: ${jsonEncode(postData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': secret,
        },
        body: jsonEncode(postData),
      );

      developer.log('🟠 [BackendRepository] Response status: ${response.statusCode}');
      developer.log('🟠 [BackendRepository] Response headers: ${response.headers}');
      developer.log('🟠 [BackendRepository] Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          
          // Check if the response indicates successful scheduling
          if (responseData['status'] == 'success') {
            developer.log('🟢 [BackendRepository] SUCCESS: Post scheduled successfully');
            
            // Log additional details if available
            if (responseData['linkedin_result'] != null) {
              final linkedinResult = responseData['linkedin_result'];
              if (linkedinResult['postId'] != null) {
                developer.log('🟢 [BackendRepository] LinkedIn Post ID: ${linkedinResult['postId']}');
              }
              if (linkedinResult['scheduledAt'] != null) {
                developer.log('🟢 [BackendRepository] Scheduled for: ${linkedinResult['scheduledAt']}');
              }
            }
            
            return true;
          } else {
            developer.log('🔴 [BackendRepository] ERROR: Backend returned error status - ${responseData['message'] ?? 'Unknown error'}');
            return false;
          }
        } catch (e) {
          developer.log('🔴 [BackendRepository] ERROR: Failed to parse response JSON - $e');
          return false;
        }
      } else {
        developer.log('🔴 [BackendRepository] ERROR: HTTP ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e, stackTrace) {
      developer.log('🔴 [BackendRepository] EXCEPTION: $e');
      developer.log('🔴 [BackendRepository] Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> scheduleBatchPosts(List<PostModel> posts) async {
    developer.log('🟠 [BackendRepository.scheduleBatchPosts] Starting...');
    developer.log('🟠 [BackendRepository] Batch size: ${posts.length}');
    
    for (int i = 0; i < posts.length; i++) {
      developer.log('🟠 [BackendRepository] Post ${i + 1}: ${posts[i].topic} at ${posts[i].scheduledAt}');
    }
    
    try {
      final url = AppConstants.appsScriptUrl;
      final secret = AppConstants.appsScriptSecret;
      
      developer.log('🟠 [BackendRepository] Apps Script URL: ${url.isNotEmpty ? url : "NOT CONFIGURED"}');
      developer.log('🟠 [BackendRepository] Apps Script Secret: ${secret.isNotEmpty ? "CONFIGURED (${secret.length} chars)" : "NOT CONFIGURED"}');
      
      if (url.isEmpty) {
        developer.log('🔴 [BackendRepository] ERROR: Apps Script URL is empty - check APPS_SCRIPT_URL in .env file');
        return false;
      }

      if (secret.isEmpty) {
        developer.log('🔴 [BackendRepository] ERROR: Apps Script Secret is empty - check APPS_SCRIPT_SECRET in .env file');
        return false;
      }

      final batchData = {
        'action': 'batch',
        'posts': posts.map((p) => p.toJson()).toList(),
      };
      
      developer.log('🟠 [BackendRepository] Batch data: ${jsonEncode(batchData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': secret,
        },
        body: jsonEncode(batchData),
      );

      developer.log('🟠 [BackendRepository] Response status: ${response.statusCode}');
      developer.log('🟠 [BackendRepository] Response headers: ${response.headers}');
      developer.log('🟠 [BackendRepository] Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          
          // Check if the response indicates successful batch scheduling
          if (responseData['status'] == 'success') {
            developer.log('🟢 [BackendRepository] SUCCESS: Batch posts scheduled successfully');
            
            // Log details about each post if available
            if (responseData['results'] != null) {
              final results = responseData['results'] as List;
              for (int i = 0; i < results.length; i++) {
                final result = results[i];
                developer.log('🟢 [BackendRepository] Post ${i + 1} (${result['topic']}): ${result['status']}');
              }
            }
            
            return true;
          } else {
            developer.log('🔴 [BackendRepository] ERROR: Backend returned error status - ${responseData['message'] ?? 'Unknown error'}');
            return false;
          }
        } catch (e) {
          developer.log('🔴 [BackendRepository] ERROR: Failed to parse response JSON - $e');
          return false;
        }
      } else {
        developer.log('🔴 [BackendRepository] ERROR: HTTP ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e, stackTrace) {
      developer.log('🔴 [BackendRepository] EXCEPTION: $e');
      developer.log('🔴 [BackendRepository] Stack trace: $stackTrace');
      return false;
    }
  }
}
