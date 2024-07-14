import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/audioplayer.dart';
import 'package:openspot/ui/theme_provider.dart';
import 'package:provider/provider.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final compressedHeight = 64.0;
  final bottomMargin = 0.0;
  final sideMargin = 10.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    musicPlayerStateChange.addListener(() => setState(() {}));

    return Container(
      margin: EdgeInsets.only(left: sideMargin, right: sideMargin, bottom: bottomMargin),
      width: MediaQuery.of(context).size.width,
      height: compressedHeight,
      child: Card.filled(
        child: Row(
          children: [
            (songCover.value.isEmpty ? const SizedBox(height: 48, width: 48) : CachedNetworkImage(imageUrl: songCover.value, height: 48, width: 48)),
            Expanded(
              child: Column(
                children: [
                  Text(songTitle.value),
                  Text(songArtist.value),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                if (isPlaying.value) {
                  pauseSong();
                } else {
                  playSong();
                }
              },
              icon: Icon(isPlaying.value ? Icons.pause : Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }
}
