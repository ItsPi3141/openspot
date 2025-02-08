import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:openspot/ui/theme_provider.dart';
import 'package:openspot/ui/typography.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvier>(context);

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
                "Appearance",
              ),
              titlePadding: const EdgeInsetsDirectional.only(start: 16.0, bottom: 16.0),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final theme = Theme.of(context);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    {
                      "title": "Theme",
                      "description": "Only available on Android 12 and up",
                      "inputType": "radio",
                      "options": [
                        {
                          "title": "System",
                          "value": ThemeMode.system,
                          "onClick": () {
                            themeProvider.setThemeMode(ThemeMode.system);
                          }
                        },
                        {
                          "title": "Light",
                          "value": ThemeMode.light,
                          "onClick": () {
                            themeProvider.setThemeMode(ThemeMode.light);
                          }
                        },
                        {
                          "title": "Dark",
                          "value": ThemeMode.dark,
                          "onClick": () {
                            themeProvider.setThemeMode(ThemeMode.dark);
                          }
                        }
                      ]
                    },
                    {
                      "title": "Material You",
                      "description": "Only available on Android 12 and up",
                      "inputType": "bool",
                      "value": themeProvider.usingMaterialYou,
                      "onClick": (enabled) {
                        setState(() {
                          themeProvider.setUsingMaterialYou(enabled);
                        });
                      }
                    }
                  ].map(
                    (settingsItem) {
                      switch (settingsItem["inputType"]) {
                        case "bool":
                          {
                            return SwitchListTile(
                              value: settingsItem["value"] as bool,
                              onChanged: (enabled) {
                                (settingsItem["onClick"] as void Function(bool))(enabled);
                              },
                              title: DynamicColorText(
                                settingsItem["title"] as String,
                                style: theme.textTheme.titleLarge,
                              ),
                              subtitle: DynamicColorText(settingsItem["description"] as String),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                            );
                          }
                        case "radio":
                          {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    settingsItem["title"] as String,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ),
                                ...(settingsItem["options"] as List).map((option) {
                                  return RadioListTile(
                                    title: DynamicColorText(option["title"] as String),
                                    value: option["value"],
                                    groupValue: themeProvider.currentTheme,
                                    onChanged: (_) {
                                      (option["onClick"] as void Function())();
                                    },
                                  );
                                })
                              ],
                            );
                          }
                        default:
                          {
                            return Container();
                          }
                      }
                    },
                  ).toList(),
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
