import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/spotify.dart';
import 'package:openspot/services/youtube.dart';
import 'package:openspot/src/common/song.dart';

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
          SliverAppBar(
            stretch: false,
            pinned: true,
            snap: true,
            floating: true,
            expandedHeight: 192,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var height = constraints.biggest.height - MediaQuery.of(context).viewPadding.top;

                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  title: Text(height < 60 ? playlistData["name"] ?? "Playlist" : ""),
                  background: Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, top: MediaQuery.of(context).viewPadding.top + 48),
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
                  ),
                );
              },
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
                return Song(
                  title: playlistData["tracks"][index]?["itemV2"]?["data"]?["name"] ?? "",
                  artist: (playlistData["tracks"][index]?["itemV2"]?["data"]?["artists"]?["items"] as List).map((e) => e["profile"]?["name"] ?? "").join(", "),
                  coverImage: (playlistData["tracks"]?[index]?["itemV2"]?["data"]?["albumOfTrack"]?["coverArt"]?["sources"] as List).firstWhere(
                          (image) => image["width"] == 640,
                          orElse: () => playlistData["tracks"]?[index]?["itemV2"]?["data"]?["albumOfTrack"]?["coverArt"]?["sources"]?[0])?["url"] ??
                      "",
                  duration: playlistData["tracks"][index]?["itemV2"]?["data"]?["trackDuration"]?["totalMilliseconds"] ?? 0,
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          )
        ],
      ),
    );
    //   },
    // );
  }
}
