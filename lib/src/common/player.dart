import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/audioplayer.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final compressedHeight = 72.0;
  final sideMargin = 6.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    musicPlayerStateChange.addListener(() => setState(() {}));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: sideMargin),
      width: MediaQuery.of(context).size.width,
      height: compressedHeight,
      child: Card.filled(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Card.filled(
                color: Colors.white.withOpacity(0.1),
                shadowColor: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: songCover.value,
                  height: 48,
                  width: 48,
                  errorWidget: (context, url, error) => Icon(
                    Icons.music_note_rounded,
                    color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                  ),
                  placeholder: (context, url) => Icon(
                    Icons.music_note_rounded,
                    color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        songTitle.value,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      Text(
                        songArtist.value,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (player.playing) {
                    pauseSong();
                  } else {
                    playSong();
                  }
                },
                icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicPlayerFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(0, 4 + scaffoldGeometry.contentBottom - (scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.contentBottom));
  }
}
