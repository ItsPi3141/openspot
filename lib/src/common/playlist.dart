import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/audioplayer.dart';
import 'package:openspot/services/spotify.dart';
import 'package:openspot/services/youtube.dart';

class PlaylistViewer extends StatefulWidget {
  final String uri;
  final SpotifyProvider spotifyProvider;
  final YouTubeProvider youtubeProvider;
  const PlaylistViewer({super.key, required this.uri, required this.spotifyProvider, required this.youtubeProvider});

  @override
  State<PlaylistViewer> createState() => _PlaylistViewerState();
}

class _PlaylistViewerState extends State<PlaylistViewer> {
  Map<String, dynamic> playlistData = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    (() async {
      var tmp = await widget.spotifyProvider.getPlaylist(widget.uri);
      try {
        setState(() {
          playlistData = tmp;
        });
      } catch (_) {}
    })();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            stretch: false,
            pinned: true,
            snap: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Playlist"),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: playlistData["coverImage"]?["url"] ?? "",
                          height: 128,
                          width: 128,
                          errorWidget: (context, url, error) => Icon(
                            Icons.album,
                            size: 96.0,
                            color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                          ),
                          placeholder: (context, url) => Icon(
                            Icons.album,
                            size: 96.0,
                            color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlistData["name"] ?? "",
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              playlistData["description"] ?? "",
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {},
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(69),
                                    child: CachedNetworkImage(
                                      imageUrl: playlistData["owner"]?["profilePicture"] ?? "",
                                      height: 24,
                                      width: 24,
                                      errorWidget: (context, url, error) => Icon(
                                        Icons.person,
                                        color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                                      ),
                                      placeholder: (context, url) => Icon(
                                        Icons.person,
                                        color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(playlistData["owner"]?["name"] ?? "")
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: 1,
            ),
          ),
          EasyLoadMore(
            isFinished: ((playlistData["tracks"] ?? []) as List).length >= (playlistData["totalTracks"] ?? 0),
            onLoadMore: () async {
              return await widget.spotifyProvider.loadMorePlaylistItems(widget.uri);
            },
            idleStatusText: "",
            loadingStatusText: "",
            failedStatusText: "",
            finishedStatusText: "That's all!",
            loadingWidgetColor: theme.colorScheme.primary,
            child: SliverList.separated(
              itemBuilder: (BuildContext context, int index) {
                String title = playlistData["tracks"][index]?["itemV2"]?["data"]?["name"] ?? "";
                String artist =
                    (playlistData["tracks"][index]?["itemV2"]?["data"]?["artists"]?["items"] as List).map((e) => e["profile"]?["name"] ?? "").join(", ");
                String coverImage = (playlistData["tracks"]?[index]?["itemV2"]?["data"]?["albumOfTrack"]?["coverArt"]?["sources"] as List).firstWhere(
                      (image) => image["width"] == 640,
                    )?["url"] ??
                    playlistData["tracks"]?[index]?["itemV2"]?["data"]?["albumOfTrack"]?["coverArt"]?["sources"]?[0]?["url"];

                return ListTile(
                  onTap: () async {
                    final id = await widget.youtubeProvider.getYouTubeSongId(playlistData["tracks"][index]?["itemV2"]?["data"]?["name"],
                        (playlistData["tracks"][index]?["itemV2"]?["data"]?["artists"]?["items"] as List)[0]["profile"]?["name"]);
                    if (id == "") return;
                    final url = await widget.youtubeProvider.getSongDownloadUrl(id);
                    if (url == "") return;
                    if (kDebugMode) {
                      print("Song URL: $url");
                    }
                    setSongInfo(title, artist, coverImage, url);
                    playSong();
                  },
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
                  leading: Builder(builder: (context) {
                    return ClipRRect(
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
                    );
                  }),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 1,
                );
              },
              itemCount: playlistData["tracks"]?.length ?? 0,
            ),
          ),
        ],
      ),
    );
    //   },
    // );
  }
}
