import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/backend_repository.dart';
import '../widgets/generate_button.dart';
import '../widgets/post_preview_card.dart';
import '../widgets/topic_selector.dart';
import '../widgets/time_picker_button.dart';
import '../widgets/post_queue_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  final AiRepository _aiRepository = AiRepository();
  final BackendRepository _backendRepository = BackendRepository();

  String _generatedContent = '';
  bool _isGenerating = false;
  bool _isScheduling = false;
  String? _selectedTopic;
  DateTime? _scheduledTime;
  final List<PostModel> _postQueue = [];

  static const int _maxQueueSize = 10;
  static const List<String> _predefinedTopics = [
    'AI',
    'Flutter',
    'Growth',
    'Leadership',
    'Productivity',
    'Career',
    'Tech Trends',
    'Startups',
  ];

  Future<void> _handleGenerate() async {
    final topic = _selectedTopic ?? _topicController.text;
    if (topic.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedContent = '';
    });

    try {
      final content = await _aiRepository.getGeneratedContent(topic);
      setState(() {
        _generatedContent = content;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate post.')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _addToQueue() {
    if (_generatedContent.isEmpty) return;
    if (_postQueue.length >= _maxQueueSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Queue is full (max 10 posts)')),
      );
      return;
    }

    final post = PostModel(
      topic: _selectedTopic ?? _topicController.text,
      content: _generatedContent,
      scheduledAt: _scheduledTime,
      status: PostStatus.queued,
    );

    setState(() {
      _postQueue.add(post);
      _generatedContent = '';
      _topicController.clear();
      _selectedTopic = null;
      _scheduledTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post added to queue!')),
    );
  }

  void _removeFromQueue(int index) {
    setState(() {
      _postQueue.removeAt(index);
    });
  }

  Future<void> _scheduleAllPosts() async {
    if (_postQueue.isEmpty) return;

    setState(() => _isScheduling = true);

    final success = await _backendRepository.scheduleBatchPosts(_postQueue);

    setState(() => _isScheduling = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All posts scheduled successfully!')),
      );
      setState(() {
        _postQueue.clear();
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to schedule posts.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1E1E1E), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'LinkedIn Auto Poster',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Craft your professional story with AI.',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Select a Topic',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TopicSelector(
                    topics: _predefinedTopics,
                    selectedTopic: _selectedTopic,
                    onTopicSelected: (topic) {
                      setState(() {
                        _selectedTopic = topic;
                        _topicController.text = topic;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _topicController,
                    decoration: InputDecoration(
                      hintText: 'Or enter a custom topic...',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.topic, color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  GenerateButton(
                    onPressed: _handleGenerate,
                    isLoading: _isGenerating,
                  ),
                  const SizedBox(height: 40),
                  if (_generatedContent.isNotEmpty || _isGenerating) ...[
                    const Text(
                      'Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isGenerating)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      PostPreviewCard(content: _generatedContent),
                      const SizedBox(height: 16),
                      TimePickerButton(
                        scheduledTime: _scheduledTime,
                        onTimeSelected: (time) {
                          setState(() => _scheduledTime = time);
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addToQueue,
                          icon: const Icon(Icons.add),
                          label: const Text('Add to Queue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                  if (_postQueue.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Queue (${_postQueue.length}/$_maxQueueSize)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _isScheduling ? null : _scheduleAllPosts,
                          icon: _isScheduling
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send, size: 18),
                          label: const Text('Schedule All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_postQueue.length, (index) {
                      return PostQueueCard(
                        post: _postQueue[index],
                        onRemove: () => _removeFromQueue(index),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
