import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/spotify.dart';
import 'package:openspot/src/utils/colors.dart';
import 'package:provider/provider.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    final spotifyProvider = context.watch<SpotifyProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            stretch: false,
            pinned: true,
            snap: true,
            floating: true,
            expandedHeight: 72,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Discover",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              titlePadding: const EdgeInsetsDirectional.only(start: 16.0, bottom: 16.0),
            ),
          ),
          FutureBuilder(
            future: spotifyProvider.getBrowsableGenres(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final l = snapshot.data!;
                return SliverGrid.builder(
                  itemBuilder: (context, index) => ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 64),
                    child: Padding(
                      padding: index % 2 == 0 ? const EdgeInsets.only(left: 8) : const EdgeInsets.only(right: 8),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {},
                          child: Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            children: [
                              Container(
                                color: hexToColor(l[index]["content"]["data"]["data"]["cardRepresentation"]["backgroundColor"]["hex"])
                                    .harmonizeWith(Theme.of(context).colorScheme.surfaceContainerLowest)
                                    .withAlpha(144),
                              ),
                              Transform.translate(
                                offset: Offset(32, 20),
                                child: Transform.rotate(
                                  angle: 0.42,
                                  child: CachedNetworkImage(
                                    height: 128,
                                    width: 128,
                                    imageUrl: l[index]["content"]["data"]["data"]["cardRepresentation"]["artwork"]["sources"][0]["url"],
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 12, 64, 12),
                                    child: Text(
                                      l[index]["content"]["data"]["data"]["cardRepresentation"]["title"]["transformedLabel"],
                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, height: 1.25),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.6),
                  itemCount: l.length,
                );
              } else {
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) => Card(), childCount: 6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                );
              }
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          )
        ],
      ),
    );
  }
}
