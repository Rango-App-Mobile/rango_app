import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rango_app/data/package_info_app_info_repository.dart';

void main() {
  group('PackageInfoAppInfoRepository', () {
    test('returns the installed app version', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Rango',
        packageName: 'com.example.rango',
        version: '1.2.3',
        buildNumber: '7',
        buildSignature: '',
      );

      final version = await PackageInfoAppInfoRepository().fetchVersion();

      expect(version, '1.2.3');
    });
  });
}
