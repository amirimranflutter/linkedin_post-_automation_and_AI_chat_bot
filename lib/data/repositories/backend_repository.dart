import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/post_model.dart';

class BackendRepository {
  Future<bool> schedulePost(PostModel post) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.appsScriptUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': AppConstants.appsScriptSecret,
        },
        body: jsonEncode(post.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> scheduleBatchPosts(List<PostModel> posts) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.appsScriptUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': AppConstants.appsScriptSecret,
        },
        body: jsonEncode({
          'action': 'batch',
          'posts': posts.map((p) => p.toJson()).toList(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
