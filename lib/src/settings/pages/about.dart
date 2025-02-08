import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            stretch: false,
            pinned: true,
            snap: true,
            floating: true,
            expandedHeight: 112,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "About",
              ),
              titlePadding: const EdgeInsetsDirectional.only(start: 16.0, bottom: 16.0),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final theme = Theme.of(context);
// PackageInfo.fromPlatform()
                return FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                                  radius: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "OpenSpot",
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text("v${snapshot.data?.version ?? ""} (${snapshot.data?.buildNumber ?? ""})"),
                                const SizedBox(height: 8),
                                FilledButton.tonalIcon(
                                    onPressed: () {
                                      final Uri url = Uri.parse('https://github.com/ItsPi3141/OpenSpot');
                                      launchUrl(url, mode: LaunchMode.externalApplication);
                                    },
                                    icon: const Icon(Mdi.github),
                                    label: const Text("GitHub")),
                              ],
                            ),
                            const Divider(
                              height: 32,
                            ),
                            ...[
                              {
                                "name": "ItsPi3141",
                                "link": "https://github.com/ItsPi3141",
                                "picture": "https://avatars.githubusercontent.com/u/90981829",
                                "title": "Main developer",
                              }
                            ].map(
                              (c) => ListTile(
                                onTap: () {
                                  final Uri url = Uri.parse(c["link"]!);
                                  launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
                                },
                                leading: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.surfaceContainerLow,
                                  ),
                                  child: CachedNetworkImage(
                                    width: 64,
                                    height: 64,
                                    imageUrl: c["picture"]!,
                                  ),
                                ),
                                title: Text(c["name"]!, style: theme.textTheme.titleLarge),
                                subtitle: Text(c["title"]!),
                                contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                              ),
                            )
                          ],
                        );
                      } else {
                        return Container();
                      }
                    });
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
