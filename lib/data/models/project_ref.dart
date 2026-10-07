/// Minimal project reference — used inside task details. Full project
/// data lives in `Project`.
class ProjectRef {
  const ProjectRef({required this.id, required this.name});

  final int id;
  final String name;

  factory ProjectRef.fromJson(Map<String, dynamic> json) {
    return ProjectRef(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
    );
  }
}
