import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/post_model.dart';

class BackendRepository {
  Future<bool> schedulePost(PostModel post) async {
    print('🟠 [BackendRepository.schedulePost] Starting...');
    print('🟠 [BackendRepository] Post ID: ${post.id}');
    print('🟠 [BackendRepository] Topic: ${post.topic}');
    print('🟠 [BackendRepository] Scheduled at: ${post.scheduledAt}');
    print('🟠 [BackendRepository] Status: ${post.status}');
    
    try {
      final url = AppConstants.appsScriptUrl;
      print('🟠 [BackendRepository] Calling URL: $url');
      
      if (url.isEmpty) {
        print('🔴 [BackendRepository] ERROR: Apps Script URL is empty');
        return false;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': AppConstants.appsScriptSecret,
        },
        body: jsonEncode(post.toJson()),
      );

      print('🟠 [BackendRepository] Response status: ${response.statusCode}');
      print('🟠 [BackendRepository] Response body: ${response.body}');

      final success = response.statusCode == 200;
      if (success) {
        print('🟢 [BackendRepository] SUCCESS: Post scheduled');
      } else {
        print('🔴 [BackendRepository] ERROR: Failed to schedule post');
      }
      
      return success;
    } catch (e, stackTrace) {
      print('🔴 [BackendRepository] EXCEPTION: $e');
      print('🔴 [BackendRepository] Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> scheduleBatchPosts(List<PostModel> posts) async {
    print('🟠 [BackendRepository.scheduleBatchPosts] Starting...');
    print('🟠 [BackendRepository] Batch size: ${posts.length}');
    
    for (int i = 0; i < posts.length; i++) {
      print('🟠 [BackendRepository] Post ${i + 1}: ${posts[i].topic} at ${posts[i].scheduledAt}');
    }
    
    try {
      final url = AppConstants.appsScriptUrl;
      print('🟠 [BackendRepository] Calling URL: $url');
      
      if (url.isEmpty) {
        print('🔴 [BackendRepository] ERROR: Apps Script URL is empty');
        return false;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': AppConstants.appsScriptSecret,
        },
        body: jsonEncode({
          'action': 'batch',
          'posts': posts.map((p) => p.toJson()).toList(),
        }),
      );

      print('🟠 [BackendRepository] Response status: ${response.statusCode}');
      print('🟠 [BackendRepository] Response body: ${response.body}');

      final success = response.statusCode == 200;
      if (success) {
        print('🟢 [BackendRepository] SUCCESS: Batch posts scheduled');
      } else {
        print('🔴 [BackendRepository] ERROR: Failed to schedule batch posts');
      }
      
      return success;
    } catch (e, stackTrace) {
      print('🔴 [BackendRepository] EXCEPTION: $e');
      print('🔴 [BackendRepository] Stack trace: $stackTrace');
      return false;
    }
  }
}
