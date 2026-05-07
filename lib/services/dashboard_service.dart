import '../core/api_client.dart';
import '../core/json_helper.dart';
import '../models/dashboard_resume.dart';

class DashboardService {
  final ApiClient _api;

  const DashboardService({ApiClient api = const ApiClient()}) : _api = api;

  Future<DashboardResume> fetchResume() async {
    final data = await _api.get('dashboard/resume');
    return DashboardResume.fromJson(readMap(data));
  }
}
