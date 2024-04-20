import 'package:cached_network_image/cached_network_image.dart';
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [],
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
    //   },
    // );
  }
}
