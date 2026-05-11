import '../modeles/dashboard_resume.dart';
import 'api_service.dart';

class AdminDashboardService {
  final ApiService _api;

  const AdminDashboardService({ApiService api = const ApiService()}) : _api = api;

  // Charge le résumé.
  Future<DashboardResume> fetchResume() async {
    final data = await _api.get('dashboard/resume');
    return DashboardResume.fromJson(readMap(data));
  }
}
