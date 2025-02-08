import 'package:flutter/material.dart';
import 'package:openspot/services/spotify.dart';
import 'package:openspot/src/common/cards.dart';
import 'package:provider/provider.dart';

NavigatorState? navigator;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    navigator = Navigator.of(context);

    final spotifyProvider = context.watch<SpotifyProvider>();

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Stack(
            children: [
              Container(
                color: theme.colorScheme.surface,
                height: 44,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                    return const SearchBar(
                      padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16)),
                      elevation: WidgetStatePropertyAll<double>(
                        3,
                      ),
                      shadowColor: WidgetStatePropertyAll<Color>(Colors.transparent),
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
            padding: const EdgeInsets.fromLTRB(8, 88, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    spotifyProvider.homeFeedData["data"]?["home"]["greeting"]["transformedLabel"] ?? "Hello!",
                    textAlign: TextAlign.left,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                ...((spotifyProvider.homeFeedData["data"]?["home"]["sectionContainer"]["sections"]["items"] ?? []) as List).map(
                  (section) {
                    var sectionType = section["sectionItems"]["items"]?[0]["content"]["__typename"] ?? "";
                    if (section["data"]["__typename"] == "HomeGenericSectionData" &&
                        (sectionType == "ArtistResponseWrapper" || sectionType == "PlaylistResponseWrapper")) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 24),
                            child: Text(
                              section["data"]["title"]["transformedLabel"] ?? "",
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          GridView.builder(
                            padding: const EdgeInsets.only(top: 4),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              childAspectRatio: 3 / 4,
                            ),
                            itemCount: (section["sectionItems"]["items"] as List).length,
                            itemBuilder: (context, index) {
                              final item = (section["sectionItems"]["items"] as List)[index];
                              final card = item["content"]["data"];
                              if (item["content"]["__typename"] == "ArtistResponseWrapper") {
                                final profilePicture = (card["visuals"]["avatarImage"]["sources"] as List)
                                        .firstWhere((image) => image["width"] == 320, orElse: () => card["visuals"]["avatarImage"]["sources"][0])?["url"] ??
                                    "";
                                return ArtistCard(
                                    name: (card["profile"]["name"] ?? "").replaceAll(RegExp(r"</?.+?>"), ""), profilePicture: profilePicture, uri: card["uri"]);
                              }
                              if (item["content"]["__typename"] == "PlaylistResponseWrapper") {
                                var coverPicture = card["images"]["items"][0]["sources"][0]["url"] ?? "";
                                return PlaylistCard(
                                  name: (card["name"] ?? "").replaceAll(RegExp(r"</?.+?>"), ""),
                                  description: (card["description"] ?? "").replaceAll(RegExp(r"</?.+?>"), ""),
                                  coverPicture: coverPicture,
                                  uri: card["uri"],
                                );
                              }
                              return Container();
                            },
                          ),
                        ],
                      );
                    }
                    return Container();
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
