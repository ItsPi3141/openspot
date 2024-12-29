import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/spotify.dart';
import 'package:openspot/services/youtube.dart';
import 'package:openspot/src/common/playlist.dart';

class HomePage extends StatefulWidget {
  final SpotifyProvider spotifyProvider;
  final YouTubeProvider youTubeProvider;
  const HomePage({super.key, required this.spotifyProvider, required this.youTubeProvider});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(112.0),
          child: Stack(
            children: [
              Container(
                color: theme.colorScheme.surface,
                height: 44.0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                    return const SearchBar(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
                      elevation: MaterialStatePropertyAll<double>(
                        3.0,
                      ),
                      shadowColor: MaterialStatePropertyAll<Color>(Colors.transparent),
                      leading: Icon(Icons.search),
                      hintText: "Search for a song...",
                    );
                  },
                  suggestionsBuilder: (BuildContext context, SearchController controller) {
                    return List<ListTile>.generate(
                      5,
                      (int index) {
                        final String item = 'item $index';
                        return ListTile(
                          title: Text(item),
                          onTap: () {},
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 88.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.spotifyProvider.homeFeedData["data"]?["home"]["greeting"]["transformedLabel"] ?? "Hello!",
                  textAlign: TextAlign.left,
                  style: theme.textTheme.headlineSmall,
                ),
                ...((widget.spotifyProvider.homeFeedData["data"]?["home"]["sectionContainer"]["sections"]["items"] ?? []) as List).map(
                  (section) {
                    var sectionType = section["sectionItems"]["items"]?[0]["content"]["__typename"] ?? "";
                    if (section["data"]["__typename"] == "HomeGenericSectionData" &&
                        (sectionType == "ArtistResponseWrapper" || sectionType == "PlaylistResponseWrapper")) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  Text(
                                    section["data"]["title"]["transformedLabel"] ?? "",
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              GridView.count(
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                childAspectRatio: 3 / 4,
                                shrinkWrap: true,
                                primary: false,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                children: [
                                  ...(section["sectionItems"]["items"] as List).map(
                                    (item) {
                                      var card = item["content"]["data"];
                                      if (item["content"]["__typename"] == "ArtistResponseWrapper") {
                                        var profilePicture = (card["visuals"]["avatarImage"]["sources"] as List).firstWhere((image) => image["width"] == 320,
                                                orElse: () => card["visuals"]["avatarImage"]["sources"][0])?["url"] ??
                                            "";
                                        return Card(
                                          color: Theme.of(context).colorScheme.surface,
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    child: AspectRatio(
                                                      aspectRatio: 1,
                                                      child: CachedNetworkImage(
                                                        imageUrl: profilePicture,
                                                        fit: BoxFit.cover,
                                                        errorWidget: (context, url, error) => Icon(
                                                          Icons.person,
                                                          size: 96.0,
                                                          color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                                                        ),
                                                        placeholder: (context, url) => Icon(
                                                          Icons.person,
                                                          size: 96.0,
                                                          color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
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
                                                      Text((card["profile"]["name"] ?? "").replaceAll(RegExp(r"</?.+?>"), ""),
                                                          style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                                      if (item["content"]["__typename"] == "PlaylistResponseWrapper") {
                                        var profilePicture = card["images"]["items"][0]["sources"][0]["url"] ?? "";
                                        return Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => PlaylistViewer(
                                                    uri: card["uri"],
                                                    spotifyProvider: widget.spotifyProvider,
                                                    youtubeProvider: widget.youTubeProvider,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    child: AspectRatio(
                                                      aspectRatio: 1,
                                                      child: CachedNetworkImage(
                                                        imageUrl: profilePicture,
                                                        fit: BoxFit.cover,
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
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      Text((card["name"] ?? "").replaceAll(RegExp(r"</?.+?>"), ""),
                                                          style: TextStyle(
                                                            fontSize: theme.textTheme.titleMedium?.fontSize,
                                                            fontWeight: theme.textTheme.titleMedium?.fontWeight,
                                                            height: 1,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis),
                                                      Text(
                                                        (card["description"] ?? "").replaceAll(RegExp(r"</?.+?>"), ""),
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
                                      return Container();
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return Container();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
