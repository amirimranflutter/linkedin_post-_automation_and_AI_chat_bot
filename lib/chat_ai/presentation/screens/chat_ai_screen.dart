import 'package:flutter/material.dart';
import 'package:linkedin_auto_poster/chat_ai/models/message_model.dart';
import 'package:linkedin_auto_poster/chat_ai/presentation/widgets/chat_input_field.dart';
import 'package:linkedin_auto_poster/chat_ai/presentation/widgets/chat_message_bubble.dart';
import 'package:linkedin_auto_poster/chat_ai/repositories/chat_ai_repository.dart';

class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final ChatAiRepository _repository = ChatAiRepository();
  final TextEditingController _controller = TextEditingController();
  final List<MessageModel> _messages = [];

  bool _isSending = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text,
    );

    setState(() {
      _messages.add(userMessage);
      _isSending = true;
    });

    _controller.clear();

    try {
      final response = await _repository.sendWithHistory(_messages);

      final aiMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: response,
      );

      setState(() {
        _messages.add(aiMessage);
        _isSending = false;
      });
    } catch (e) {
      setState(() => _isSending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1E1E1E), Colors.black],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Start a conversation',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[_messages.length - 1 - index];
                        return ChatMessageBubble(
                          role: message.role,
                          content: message.content,
                        );
                      },
              ),
            ),
            ChatInputField(
              controller: _controller,
              onSend: _sendMessage,
              isLoading: _isSending,
            ),
          ],
        ),
      ),
    );
  }
}
