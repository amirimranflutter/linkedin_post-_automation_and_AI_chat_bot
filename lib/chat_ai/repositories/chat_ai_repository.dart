import 'package:linkedin_auto_poster/chat_ai/services/chat_ai_service.dart';
import 'package:linkedin_auto_poster/chat_ai/models/message_model.dart';

class ChatAiRepository {
  final ChatAiService _service;

  ChatAiRepository({ChatAiService? service})
      : _service = service ?? ChatAiService();

  Future<String> sendMessage(String message) async {
    print('🟠 [ChatAiRepository.sendMessage] Starting...');
    print('🟠 [ChatAiRepository] Message: $message');
    
    try {
      final result = await _service.generateResponse(message);
      print('🟢 [ChatAiRepository] SUCCESS: Response received');
      return result;
    } catch (e, stackTrace) {
      print('🔴 [ChatAiRepository] EXCEPTION: $e');
      print('🔴 [ChatAiRepository] Stack trace: $stackTrace');
      return 'Repository error: $e';
    }
  }

  Future<String> sendWithHistory(List<MessageModel> history) async {
    print('🟠 [ChatAiRepository.sendWithHistory] Starting...');
    print('🟠 [ChatAiRepository] History length: ${history.length}');
    
    try {
      final result = await _service.generateWithHistory(history);
      print('🟢 [ChatAiRepository] SUCCESS: Response received');
      return result;
    } catch (e, stackTrace) {
      print('🔴 [ChatAiRepository] EXCEPTION: $e');
      print('🔴 [ChatAiRepository] Stack trace: $stackTrace');
      return 'Repository error: $e';
    }
  }
}
