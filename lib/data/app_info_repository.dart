import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/package_info_app_info_repository.dart';

abstract interface class AppInfoRepository {
  Future<String> fetchVersion();
}

final appInfoRepositoryProvider = Provider<AppInfoRepository>(
  (ref) => PackageInfoAppInfoRepository(),
);
