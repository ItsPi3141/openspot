import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:openspot/src/settings/pages/about.dart';
import 'package:openspot/src/settings/pages/appearance.dart';
import 'package:openspot/ui/theme_provider.dart';
import 'package:openspot/ui/typography.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvier(),
          builder: (context, child) {
            return SliverAppBar(
              stretch: false,
              pinned: true,
              snap: true,
              floating: true,
              expandedHeight: 112,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Settings",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 16.0, bottom: 16.0),
              ),
            );
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  {
                    "index": 0,
                    "icon": Icons.palette_outlined,
                    "title": "Apperance",
                    "description": "Change the look and feel of the app",
                  },
                  {
                    "index": 1,
                    "icon": Icons.info_outline,
                    "title": "About",
                    "description": "Useful information about the app",
                  }
                ].map((e) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => [
                          const AppearanceScreen(),
                          const AboutScreen()
                        ][e["index"] as int],
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(e["icon"]! as IconData),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DynamicColorText(e["title"] as String,
                                  style: theme.textTheme.titleLarge),
                              DynamicColorText(e["description"] as String),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            childCount: 1,
          ),
        ),
      ],
    );
  }
}
