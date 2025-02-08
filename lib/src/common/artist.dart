import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/spotify.dart';
import 'package:openspot/services/youtube.dart';
import 'package:openspot/src/common/cards.dart';
import 'package:openspot/src/utils/numbers.dart';

class ArtistViewer extends StatefulWidget {
  final String uri;
  final SpotifyProvider spotifyProvider;
  final YouTubeProvider youtubeProvider;
  const ArtistViewer({super.key, required this.uri, required this.spotifyProvider, required this.youtubeProvider});

  @override
  State<ArtistViewer> createState() => _ArtistViewerState();
}

class _ArtistViewerState extends State<ArtistViewer> {
  Map<String, dynamic> artistData = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    (() async {
      var tmp = await widget.spotifyProvider.getArtist(widget.uri);
      try {
        setState(() {
          artistData = tmp;
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
            expandedHeight: 160,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var height = constraints.biggest.height - MediaQuery.of(context).viewPadding.top;

                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  title: Text(height < 60 ? (artistData["profile"]?["name"] ?? "") : ""),
                  background: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: artistData["visuals"]?["headerImage"]["sources"][0]["url"] ?? "",
                        fit: BoxFit.cover,
                        alignment: FractionalOffset.center,
                        color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                        colorBlendMode: BlendMode.srcATop,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (context, url, error) => Container(),
                        placeholder: (context, url) => Container(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: MediaQuery.of(context).viewPadding.top + 48),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: CachedNetworkImage(
                                imageUrl: artistData["visuals"]?["avatarImage"]["sources"][0]["url"] ?? "",
                                height: 96,
                                width: 96,
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                  size: 96.0,
                                  color: Theme.of(context).textTheme.labelSmall!.color!.withValues(alpha: 0.5),
                                ),
                                placeholder: (context, url) => Icon(
                                  Icons.person,
                                  size: 96.0,
                                  color: Theme.of(context).textTheme.labelSmall!.color!.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      artistData["profile"]?["name"] ?? "",
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      (artistData["stats"] != null)
                                          ? "${addCommas((artistData["stats"]?["monthlyListeners"] as int).toString())} monthly listeners"
                                          : "",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Popular",
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: ((artistData["discography"]?["topTracks"]["items"] ?? []) as List).map((track) {
                    final t = track["track"];
                    return SongListItem(
                      title: t?["name"],
                      artist: ((t?["artists"]?["items"] ?? []) as List).map((e) => e["profile"]?["name"] ?? "").join(", "),
                      coverImage: t?["albumOfTrack"]?["coverArt"]?["sources"]?[0]?["url"] ?? "",
                      duration: t?["duration"]["totalMilliseconds"] ?? 0,
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Albums",
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
