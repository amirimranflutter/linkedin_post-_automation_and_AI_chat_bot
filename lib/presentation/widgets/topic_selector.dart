import 'package:flutter/material.dart';

class TopicSelector extends StatelessWidget {
  final List<String> topics;
  final String? selectedTopic;
  final ValueChanged<String> onTopicSelected;

  const TopicSelector({
    super.key,
    required this.topics,
    this.selectedTopic,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final isSelected = topic == selectedTopic;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == topics.length - 1 ? 0 : 8,
            ),
            child: FilterChip(
              label: Text(topic),
              selected: isSelected,
              onSelected: (_) => onTopicSelected(topic),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              selectedColor: Colors.blue.withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.white10,
              ),
            ),
          );
        },
      ),
    );
  }
}
