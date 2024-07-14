import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

final player = AudioPlayer();

final musicPlayerStateChange = ValueNotifier(false);

final songTitle = ValueNotifier("");
final songArtist = ValueNotifier("");
final songCover = ValueNotifier("");
final songUrl = ValueNotifier("");

void setSongInfo(String title, String author, String coverUrl, String url) {
  songTitle.value = title;
  songArtist.value = author;
  songCover.value = coverUrl;

  if (songUrl.value != url) {
    songUrl.value = url;

    player.setAudioSource(AudioSource.uri(
      Uri.parse(url),
      tag: MediaItem(
        id: url,
        album: author,
        title: title,
        artUri: Uri.parse(coverUrl),
      ),
    ));
  }

  musicPlayerStateChange.value = !musicPlayerStateChange.value;
}

void playSong() {
  player.play();

  musicPlayerStateChange.value = !musicPlayerStateChange.value;
}

void pauseSong() {
  player.pause();

  musicPlayerStateChange.value = !musicPlayerStateChange.value;
}
