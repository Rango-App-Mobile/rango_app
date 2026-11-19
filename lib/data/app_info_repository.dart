import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rango_app/core/error/failure.dart';

abstract interface class AppInfoRepository {
  Future<String> fetchVersion();
}

final appInfoRepositoryProvider = Provider<AppInfoRepository>(
  (ref) => PackageInfoAppInfoRepository(),
);

class PackageInfoAppInfoRepository implements AppInfoRepository {
  @override
  Future<String> fetchVersion() async {
    try {
      return (await PackageInfo.fromPlatform()).version;
    } on PlatformException {
      throw const UnexpectedFailure();
    } on MissingPluginException {
      throw const UnexpectedFailure();
    }
  }
}
