import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_location_repository.dart';

void main() {
  test('returns the fixed Porto Alegre point', () async {
    const repository = FakeLocationRepository();

    expect(await repository.currentPosition(), FakeLocationRepository.point);
  });

  test('settings calls do nothing', () async {
    const repository = FakeLocationRepository();

    await repository.openAppSettings();
    await repository.openLocationSettings();
  });
}
