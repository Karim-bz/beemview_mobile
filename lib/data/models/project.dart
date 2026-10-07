class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.taskCount = 0,
  });

  final int id;
  final String name;
  final String? description;
  final String? status;
  final int taskCount;

  factory Project.fromJson(Map<String, dynamic> json) {
    final tasks = (json['Tasks'] as List?) ?? const [];
    return Project(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      status: json['status'] as String?,
      taskCount: tasks.length,
    );
  }
}
