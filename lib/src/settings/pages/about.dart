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
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 16.0, bottom: 16.0),
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
                                  backgroundColor:
                                      theme.colorScheme.surfaceVariant,
                                  radius: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "OpenSpot",
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    "v${snapshot.data?.version ?? ""} (${snapshot.data?.buildNumber ?? ""})"),
                                const SizedBox(height: 8),
                                FilledButton.tonalIcon(
                                    onPressed: () {
                                      final Uri url = Uri.parse(
                                          'https://github.com/ItsPi3141/OpenSpot');
                                      launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    },
                                    icon: const Icon(Mdi.github),
                                    label: const Text("GitHub")),
                              ],
                            ),
                            const Divider(
                              height: 32,
                            ),
                            ListTile(
                              onTap: () {},
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.surfaceVariant,
                                radius: 32,
                              ),
                              title: Text("ItsPi3141",
                                  style: theme.textTheme.titleLarge),
                              subtitle: const Text(
                                "Main developer",
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 12.0),
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
