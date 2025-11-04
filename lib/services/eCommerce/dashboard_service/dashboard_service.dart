import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/services/base/eCommerce/dashboard_provider_base.dart';
import 'package:ekray/utils/api_client.dart';

class DashboardService implements DashboardProviderBase {
  final Ref ref;
  DashboardService(this.ref);

  @override
  Future<Response> getDashboardData() async {
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getDashboardData);
    return response;
  }
}

final dashboardServiceProvider = Provider((ref) => DashboardService(ref));
