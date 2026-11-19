import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/app_info_repository.dart';

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
