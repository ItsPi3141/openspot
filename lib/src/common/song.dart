import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/audioplayer.dart';
import 'package:openspot/services/youtube.dart';
import 'package:openspot/src/utils/numbers.dart';
import 'package:provider/provider.dart';

class Song extends StatelessWidget {
  final String title;
  final String artist;
  final String coverImage;
  final int duration;

  const Song({super.key, required this.title, required this.artist, required this.coverImage, required this.duration});

  @override
  Widget build(BuildContext context) {
    final youtubeProvider = context.watch<YouTubeProvider>();

    return ListTile(
      onTap: () async {
        final id = await youtubeProvider.getYouTubeSongId(title, artist);
        if (id == "") return;
        final url = await youtubeProvider.getSongDownloadUrl(id);
        if (url == "") return;
        if (kDebugMode) {
          print("Song URL: $url");
        }
        setSongInfo(title, artist, coverImage, url);
        playSong();
      },
      leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyMedium,
      title: Text(
        title,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      subtitle: Text(
        artist,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: coverImage,
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
      trailing: Text(msToTime(duration)),
    );
  }
}
