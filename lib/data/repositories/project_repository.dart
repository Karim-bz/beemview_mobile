import 'package:beemview_mobile/core/api_paths.dart';

import '../../core/api_client.dart';
import '../models/project.dart';

/// Result of a single projects page fetch.
class ProjectsPage {
  const ProjectsPage({required this.items, required this.total});

  final List<Project> items;
  final int total;
}

class ProjectRepository {
  ProjectRepository(this._api);

  final ApiClient _api;

  /// Fetches a page of projects. Defaults match the API (limit 10).
  Future<ProjectsPage> fetchProjects({int limit = 10, int offset = 0}) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiPaths.projects,
      query: {'limit': limit, 'offset': offset},
    );

    final body = res.data ?? {};
    final rawList = (body['data']) as List? ?? const [];
    final items = rawList
        .whereType<Map>()
        .map((e) => Project.fromJson(e.cast<String, dynamic>()))
        .toList();

    final total = (body['total'] as num?)?.toInt() ?? items.length;

    return ProjectsPage(items: items, total: total);
  }
}
