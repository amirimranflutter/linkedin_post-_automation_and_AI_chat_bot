import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/post_model.dart';

class PostQueueCardWidget extends StatelessWidget {
  final PostModel post;
  final VoidCallback onRemove;
  final VoidCallback? onEdit;

  const PostQueueCardWidget({
    super.key,
    required this.post,
    required this.onRemove,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    post.status.name.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                    onPressed: onRemove,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.topic,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              post.content.length > 100
                  ? '${post.content.substring(0, 100)}...'
                  : post.content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (post.scheduledAt != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A66C2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Color(0xFF0A66C2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(post.scheduledAt!),
                      style: const TextStyle(
                        color: Color(0xFF0A66C2),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (post.status) {
      case PostStatus.draft:
        return Colors.grey;
      case PostStatus.queued:
        return Colors.blue;
      case PostStatus.paused:
        return Colors.orange;
      case PostStatus.scheduled:
        return Colors.purple;
      case PostStatus.posted:
        return Colors.green;
      case PostStatus.failed:
        return Colors.red;
    }
  }
}
