import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:openspot/services/audioplayer.dart';

bool isPlayerExpanded = false;

class MusicPlayer extends StatefulWidget {
  final bool isCompact;
  const MusicPlayer({super.key, this.isCompact = true});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final compressedHeight = 64.0;
  final sideMargin = 8.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    musicPlayerStateChange.addListener(() => setState(() {}));

    if (widget.isCompact) {
      return Container(
        margin: EdgeInsets.all(sideMargin),
        width: MediaQuery.of(context).size.width,
        height: compressedHeight,
        child: GestureDetector(
          onTap: () {
            isPlayerExpanded = true;
            Navigator.of(context).push(FullPlayer());
          },
          child: Stack(
            children: [
              FadeTransitionHero(
                tag: "player_background",
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Hero(
                      tag: "player_albumCover",
                      child: Card.filled(
                        color: Colors.white.withOpacity(0.1),
                        shadowColor: Colors.transparent,
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: songCover.value,
                          fit: BoxFit.cover,
                          height: 48,
                          width: 48,
                          errorWidget: (context, url, error) => Icon(
                            Icons.music_note_rounded,
                            color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                          ),
                          placeholder: (context, url) => Icon(
                            Icons.music_note_rounded,
                            color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: "player_songTitle",
                              child: Text(
                                songTitle.value,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                            Hero(
                              tag: "player_songArtist",
                              child: Text(
                                songArtist.value,
                                style: Theme.of(context).textTheme.labelMedium,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FadeTransitionHero(tag: "player_btnLL", child: Container()),
                    FadeTransitionHero(tag: "player_btnL", child: Container()),
                    FadeTransitionHero(
                      tag: "player_playBtn",
                      child: IconButton(
                        onPressed: () {
                          if (player.playing) {
                            pauseSong();
                          } else {
                            playSong();
                          }
                        },
                        icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
                      ),
                    ),
                    FadeTransitionHero(tag: "player_btnR", child: Container()),
                    FadeTransitionHero(tag: "player_btnRR", child: Container()),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SafeArea(
        child: Stack(
          children: [
            FadeTransitionHero(
              tag: "player_background",
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: "player_albumCover",
                    child: Card.filled(
                      color: Colors.white.withOpacity(0.1),
                      shadowColor: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: songCover.value,
                        fit: BoxFit.cover,
                        height: 256,
                        width: 256,
                        errorWidget: (context, url, error) => Icon(
                          Icons.music_note_rounded,
                          color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                        ),
                        placeholder: (context, url) => Icon(
                          Icons.music_note_rounded,
                          color: Color(Theme.of(context).textTheme.labelSmall!.color!.value).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  Hero(
                    tag: "player_songTitle",
                    child: Text(
                      songTitle.value,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Hero(
                    tag: "player_songArtist",
                    child: Text(
                      songArtist.value,
                      style: Theme.of(context).textTheme.labelMedium,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeTransitionHero(
                        tag: "player_btnLL",
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.shuffle_rounded),
                        ),
                      ),
                      FadeTransitionHero(
                        tag: "player_btnL",
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.skip_previous_rounded),
                        ),
                      ),
                      FadeTransitionHero(
                        tag: "player_playBtn",
                        child: IconButton.filledTonal(
                          onPressed: () {
                            if (player.playing) {
                              pauseSong();
                            } else {
                              playSong();
                            }
                          },
                          icon: Icon(player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        ),
                      ),
                      FadeTransitionHero(
                        tag: "player_btnR",
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                      ),
                      FadeTransitionHero(
                        tag: "player_btnRR",
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.repeat_rounded),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}

class FullPlayer extends PageRoute<void> {
  FullPlayer({super.settings});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.01);

  @override
  String get barrierLabel => "";

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Return new state full widget to use route active mixin
    return const MusicPlayer(
      isCompact: false,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class FadeTransitionHero extends Hero {
  const FadeTransitionHero({
    super.key,
    required super.tag,
    super.createRectTween,
    super.flightShuttleBuilder,
    super.placeholderBuilder,
    super.transitionOnUserGestures = false,
    required super.child,
  });

  @override
  HeroFlightShuttleBuilder? get flightShuttleBuilder {
    return (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
      if (flightDirection == HeroFlightDirection.pop) {
        return Stack(children: [
          Positioned.fill(child: toHeroContext.widget),
          FadeTransition(opacity: animation, child: fromHeroContext.widget),
        ]);
      } else {
        return Stack(children: [
          Positioned.fill(child: fromHeroContext.widget),
          FadeTransition(opacity: animation, child: toHeroContext.widget),
        ]);
      }
    };
  }

  @override
  bool get transitionOnUserGestures => true;
}
