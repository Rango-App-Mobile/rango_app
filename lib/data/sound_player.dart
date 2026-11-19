import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/audioplayers_sound_player.dart';

/// The short sound effects of the choosing game.
enum Sound { like, pass, win }

/// Plays [Sound]s. Never throws: a sound is a bonus, never worth a failure.
abstract interface class SoundPlayer {
  Future<void> play(Sound sound);
}

final soundPlayerProvider = Provider<SoundPlayer>(
  (ref) => AudioplayersSoundPlayer(),
);
