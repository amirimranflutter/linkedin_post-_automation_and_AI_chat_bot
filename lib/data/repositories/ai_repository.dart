import '../services/openrouter_service_linkedin.dart';

class AiRepository {
  final OpenRouterService _openRouterService = OpenRouterService();

  Future<String> getGeneratedContent(String topic) {
    return _openRouterService.generatePost(topic);
  }
}
