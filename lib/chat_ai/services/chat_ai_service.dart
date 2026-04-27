import '../models/message_model.dart';
import 'openrouter_service_chat_AI.dart';

class ChatAiService {
  final OpenRouterService _openRouterService;

  ChatAiService({OpenRouterService? openRouterService})
      : _openRouterService = openRouterService ?? OpenRouterService();

  Future<String> generateResponse(String userMessage) async {
    print('🟡 [ChatAiService.generateResponse] Starting...');
    print('🟡 [ChatAiService] User message: $userMessage');
    
    try {
      final result = await _openRouterService.generateResponse(userMessage);
      print('🟢 [ChatAiService] SUCCESS: Response received');
      return result;
    } catch (e, stackTrace) {
      print('🔴 [ChatAiService] EXCEPTION: $e');
      print('🔴 [ChatAiService] Stack trace: $stackTrace');
      return 'ChatAiService error: $e';
    }
  }

  Future<String> generateWithHistory(List<MessageModel> history) async {
    print('🟡 [ChatAiService.generateWithHistory] Starting...');
    print('🟡 [ChatAiService] History length: ${history.length}');
    
    try {
      final result = await _openRouterService.generateWithHistory(history);
      print('🟢 [ChatAiService] SUCCESS: Response received');
      return result;
    } catch (e, stackTrace) {
      print('🔴 [ChatAiService] EXCEPTION: $e');
      print('🔴 [ChatAiService] Stack trace: $stackTrace');
      return 'ChatAiService error: $e';
    }
  }
}
