class PostModel {
  final String id;
  final String topic;
  final String content;
  final DateTime? scheduledAt;
  final PostStatus status;

  PostModel({
    String? id,
    required this.topic,
    required this.content,
    this.scheduledAt,
    this.status = PostStatus.draft,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  PostModel copyWith({
    String? id,
    String? topic,
    String? content,
    DateTime? scheduledAt,
    PostStatus? status,
  }) {
    return PostModel(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      content: content ?? this.content,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'content': content,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'status': status.name,
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      topic: json['topic'],
      content: json['content'],
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      status: PostStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PostStatus.draft,
      ),
    );
  }
}

enum PostStatus { 
  draft,      // Not scheduled, can be edited
  queued,     // Ready to be scheduled
  paused,     // Temporarily paused from scheduling
  scheduled,  // Sent to backend for scheduling
  posted,     // Successfully posted
  failed      // Failed to post
}
