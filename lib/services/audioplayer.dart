import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

final player = AudioPlayer();

final musicPlayerStateChange = ValueNotifier(false);

final isPlaying = ValueNotifier(false);

final songTitle = ValueNotifier("title");
final songArtist = ValueNotifier("artist");
final songCover = ValueNotifier("");

void setSongInfo(String title, String author, String coverUrl) {
  songTitle.value = title;
  songArtist.value = author;
  songCover.value = coverUrl;

  musicPlayerStateChange.value = !musicPlayerStateChange.value;
}

String currentSongUrl = "";
void playSong({String? url}) {
  if ((url ?? "").isNotEmpty && url != currentSongUrl) {
    player.setUrl(url as String);
    currentSongUrl = url;
  }
  player.play();

  isPlaying.value = true;
  musicPlayerStateChange.value = !musicPlayerStateChange.value;
}

void pauseSong() {
  player.pause();

  isPlaying.value = false;
  musicPlayerStateChange.value = !musicPlayerStateChange.value;
}
