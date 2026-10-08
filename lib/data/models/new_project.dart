import '../../core/format.dart';

/// Payload for POST /projects.
class NewProject {
  const NewProject({
    required this.name,
    required this.organizationalUnitId,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  final String name;
  final int organizationalUnitId;
  final String description;
  final String status;
  final DateTime startDate;
  final DateTime endDate;

  Map<String, dynamic> toJson() => {
    'name': name,
    'organizational_unit_id': organizationalUnitId,
    'description': description,
    'status': status,
    'start_date': toApiDate(startDate),
    'end_date': toApiDate(endDate),
  };
}
