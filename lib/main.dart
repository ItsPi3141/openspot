import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mdi/mdi.dart';
import 'package:openspot/services/spotify.dart';
import 'package:openspot/services/youtube.dart';
import 'package:openspot/src/common/player.dart';
import 'package:provider/provider.dart';

import 'package:openspot/ui/theme_provider.dart';

import 'package:openspot/src/home/home.dart';
import 'package:openspot/src/library/library.dart';
import 'package:openspot/src/discover/discover.dart';
import 'package:openspot/src/settings/settings.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.itspi3141.openspot.channel.audio',
    androidNotificationChannelName: 'Music',
    androidNotificationOngoing: true,
    androidNotificationClickStartsActivity: true,
    androidResumeOnClick: true,
  );
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static final _defaultLightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
  static final _defaultDarkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvier(),
      builder: (BuildContext context, Widget? _) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            var themeProvider = Provider.of<ThemeProvier>(context);

            const bottomSheetTheme = BottomSheetThemeData(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(),
            );

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "Openspot",
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: themeProvider.useMaterialYou ? lightDynamic ?? _defaultLightColorScheme : _defaultLightColorScheme,
                splashFactory: InkSparkle.splashFactory,
                brightness: Brightness.light,
                bottomSheetTheme: bottomSheetTheme,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: themeProvider.useMaterialYou ? darkDynamic ?? _defaultDarkColorScheme : _defaultDarkColorScheme,
                splashFactory: InkSparkle.splashFactory,
                brightness: Brightness.dark,
                bottomSheetTheme: bottomSheetTheme,
              ),
              themeMode: themeProvider.currentTheme,
              home: const NavigationWrapper(),
            );
          },
        );
      },
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (navigator?.canPop() ?? false) {
      navigator?.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SpotifyProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => YouTubeProvider(),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          List<MaterialPage> pageStack = [
            MaterialPage(
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  HomePage(
                    spotifyProvider: Provider.of<SpotifyProvider>(context),
                    youTubeProvider: Provider.of<YouTubeProvider>(context),
                  ),
                  const DiscoverPage(),
                  const LibraryPage(),
                  const SettingsPage()
                ],
              ),
            ),
          ];

          return Scaffold(
            body: Navigator(
              pages: pageStack,
              onPopPage: (route, result) => route.didPop(result),
            ),
            bottomSheet: const MusicPlayer(),
            bottomNavigationBar: NavigationBar(
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.auto_awesome),
                  icon: Icon(Icons.auto_awesome_outlined),
                  label: 'Discover',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Mdi.bookshelf),
                  icon: Icon(Mdi.bookshelf),
                  label: 'Library',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.settings),
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) {
                navigator?.popUntil((route) => !(navigator?.canPop() ?? false));
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
