import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/audioplayer.dart';
import 'package:openspot/services/spotify.dart';
import 'package:openspot/services/youtube.dart';
import 'package:openspot/src/common/artist.dart';
import 'package:openspot/src/common/playlist.dart';
import 'package:openspot/src/utils/numbers.dart';
import 'package:provider/provider.dart';

class SongListItem extends StatelessWidget {
  final String title;
  final String artist;
  final String coverImage;
  final int duration;

  const SongListItem({super.key, required this.title, required this.artist, required this.coverImage, required this.duration});

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
            color: Theme.of(context).textTheme.labelSmall!.color!.withAlpha(127),
          ),
          placeholder: (context, url) => Icon(
            Icons.music_note_rounded,
            color: Theme.of(context).textTheme.labelSmall!.color!.withAlpha(127),
          ),
        ),
      ),
      trailing: Text(msToTime(duration)),
    );
  }
}

class ArtistCard extends StatelessWidget {
  final String name;
  final String profilePicture;
  final String uri;

  const ArtistCard({super.key, required this.name, required this.profilePicture, required this.uri});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotifyProvider = context.watch<SpotifyProvider>();
    final youtubeProvider = context.watch<YouTubeProvider>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArtistViewer(
                uri: uri,
                spotifyProvider: spotifyProvider,
                youtubeProvider: youtubeProvider,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: profilePicture,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 96,
                      color: Theme.of(context).textTheme.labelSmall!.color!.withAlpha(127),
                    ),
                    placeholder: (context, url) => Icon(
                      Icons.person,
                      size: 96,
                      color: Theme.of(context).textTheme.labelSmall!.color!.withAlpha(127),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(
                    "Artist",
                    style: theme.textTheme.bodySmall,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final String name;
  final String description;
  final String coverPicture;
  final String uri;

  const PlaylistCard({super.key, required this.name, required this.description, required this.coverPicture, required this.uri});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotifyProvider = context.watch<SpotifyProvider>();
    final youtubeProvider = context.watch<YouTubeProvider>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlaylistViewer(
                uri: uri,
                spotifyProvider: spotifyProvider,
                youtubeProvider: youtubeProvider,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: coverPicture,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(
                      Icons.album,
                      size: 96,
                      color: Theme.of(context).textTheme.labelSmall!.color!.withAlpha(127),
                    ),
                    placeholder: (context, url) => Icon(
                      Icons.album,
                      size: 96,
                      color: Theme.of(context).textTheme.labelSmall!.color!.withAlpha(127),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name,
                      style: TextStyle(
                        fontSize: theme.textTheme.titleMedium?.fontSize,
                        fontWeight: theme.textTheme.titleMedium?.fontWeight,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall?.fontSize,
                      fontWeight: theme.textTheme.bodySmall?.fontWeight,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
