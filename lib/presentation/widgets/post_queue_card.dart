import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/post_model.dart';

class PostQueueCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onRemove;
  final VoidCallback? onEdit;

  const PostQueueCard({
    super.key,
    required this.post,
    required this.onRemove,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  post.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.topic,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.content.length > 100
                ? '${post.content.substring(0, 100)}...'
                : post.content,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (post.scheduledAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(post.scheduledAt!),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (post.status) {
      case PostStatus.draft:
        return Colors.grey;
      case PostStatus.queued:
        return Colors.blue;
      case PostStatus.scheduled:
        return Colors.orange;
      case PostStatus.posted:
        return Colors.green;
      case PostStatus.failed:
        return Colors.red;
    }
  }
}
