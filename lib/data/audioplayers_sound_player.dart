import 'package:audioplayers/audioplayers.dart';
import 'package:rango_app/data/sound_player.dart';

/// Plays the bundled `assets/sounds/<name>.mp3` files, one player per sound
/// so a quick second swipe restarts the effect instead of waiting.
class AudioplayersSoundPlayer implements SoundPlayer {
  final _players = <Sound, AudioPlayer>{};

  @override
  Future<void> play(Sound sound) async {
    try {
      var player = _players[sound];
      if (player == null) {
        player = AudioPlayer();
        _players[sound] = player;
        await player.setPlayerMode(PlayerMode.lowLatency);
      }
      await player.stop();
      await player.play(AssetSource('sounds/${sound.name}.mp3'));
    } on Object catch (_) {
      // No audio device, no plugin (tests) or a bad file: stay silent.
    }
  }
}
