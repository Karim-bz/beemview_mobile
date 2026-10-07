class Comment {
  const Comment({
    required this.id,
    required this.content,
    required this.authorName,
    this.createdAt,
  });

  final int id;
  final String content;
  final String authorName;
  final DateTime? createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) {
    // The API returns `user: { id, name, ... }` on comments.
    final user = (json['user'] as Map?)?.cast<String, dynamic>();
    return Comment(
      id: (json['id'] as num).toInt(),
      content: (json['content'] ?? '') as String,
      authorName: (user?['name'] ?? user?['full_name'] ?? '') as String,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
