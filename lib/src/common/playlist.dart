import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:openspot/services/spotify.dart';
import 'package:provider/provider.dart';

class PlaylistViewer extends StatefulWidget {
  final String uri;
  final SpotifyProvider spotifyProvider;
  const PlaylistViewer({super.key, required this.uri, required this.spotifyProvider});

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
      setState(() {
        playlistData = tmp;
      });
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
                        child: (playlistData["coverImage"]?["url"] != null
                            ? CachedNetworkImage(imageUrl: playlistData["coverImage"]["url"], height: 128, width: 128)
                            : const SizedBox(height: 128, width: 128)),
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
                                    child: (playlistData["owner"]?["profilePicture"] != null
                                        ? CachedNetworkImage(imageUrl: playlistData["owner"]["profilePicture"], height: 24, width: 24)
                                        : const SizedBox(height: 24, width: 24)),
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
            isFinished: ((playlistData["tracks"] == null ? [] : playlistData["tracks"]) as List).length >= (playlistData["totalTracks"] ?? 0),
            onLoadMore: () async {
              await widget.spotifyProvider.loadMorePlaylistItems(widget.uri);
              await Future.delayed(const Duration(seconds: 100));
              return Future(() => true);
            },
            idleStatusText: "",
            loadingStatusText: "",
            failedStatusText: "",
            finishedStatusText: "",
            loadingWidgetColor: theme.colorScheme.primary,
            child: SliverList.separated(
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () {},
                  title: Text(
                    playlistData["tracks"][index]?["itemV2"]?["data"]?["name"] ?? "",
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                  subtitle: Text(
                    (playlistData["tracks"][index]?["itemV2"]?["data"]?["artists"]?["items"] as List).map((e) => e["profile"]?["name"] ?? "").join(", "),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                  leading: Builder(builder: (context) {
                    var imageUrl = (playlistData["tracks"]?[index]?["itemV2"]?["data"]?["albumOfTrack"]?["coverArt"]?["sources"] as List).firstWhere(
                          (image) => image["width"] == 640,
                        )?["url"] ??
                        playlistData["tracks"]?[index]?["itemV2"]?["data"]?["albumOfTrack"]?["coverArt"]?["sources"]?[0]?["url"];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: imageUrl != null ? CachedNetworkImage(imageUrl: imageUrl, height: 48, width: 48) : const SizedBox(),
                    );
                  }),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 1,
                );
                // return const SizedBox();
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
