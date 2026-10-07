class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.taskCount = 0,
    this.organizationalUnit,
  });

  final int id;
  final String name;
  final String? description;
  final String? status;
  final int taskCount;
  final OrganizationalUnit? organizationalUnit;

  factory Project.fromJson(Map<String, dynamic> json) {
    final tasks = (json['Tasks'] as List?) ?? const [];
    final unit = json['OrganizationalUnit'];

    return Project(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      status: json['status'] as String?,
      taskCount: tasks.length,
      organizationalUnit: unit is Map
          ? OrganizationalUnit.fromJson(unit.cast<String, dynamic>())
          : null,
    );
  }
}

class OrganizationalUnit {
  const OrganizationalUnit({required this.id, required this.name, this.type});

  final int id;
  final String name;
  final String? type;

  factory OrganizationalUnit.fromJson(Map<String, dynamic> json) {
    return OrganizationalUnit(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      type: json['type'] as String?,
    );
  }
}
