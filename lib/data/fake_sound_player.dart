import 'package:rango_app/data/sound_player.dart';

/// Records what would have played, for tests.
class FakeSoundPlayer implements SoundPlayer {
  final played = <Sound>[];

  @override
  Future<void> play(Sound sound) async => played.add(sound);
}
