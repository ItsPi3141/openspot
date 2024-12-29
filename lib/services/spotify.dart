import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:openspot/utils.dart';

class SpotifyProvider with ChangeNotifier {
  String bearerToken = "";
  String clientToken = "";
  String spotifyToken = "";

  String clientId = "";
  String clientVersion = "";

  Map<String, String> queryHashes = {};

  Map<String, dynamic> homeFeedData = {};

  Map<String, dynamic> playlistCache = {};

  SpotifyProvider() {
    reload();
  }

  void reload() async {
    await getTokens();
    await getHomeFeed();
    notifyListeners();
  }

  Future<void> getTokens() async {
    // get bearer and spotify token
    final spotifyWebpage = await http.get(
      Uri.parse("https://open.spotify.com/"),
      headers: {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
      },
    );
    if (spotifyWebpage.statusCode != 200) return;
    bearerToken = RegExp(r'(?<="accessToken":")(.+?)(?=")').stringMatch(spotifyWebpage.body) ?? "";
    spotifyToken = RegExp(r'(?<="correlationId":")(.+?)(?=")').stringMatch(spotifyWebpage.body) ?? "";
    clientId = RegExp(r'(?<="clientId":")(.+?)(?=")').stringMatch(spotifyWebpage.body) ?? "";
    clientVersion = RegExp(r'(?<="clientVersion":")(.+?)(?=")').stringMatch(spotifyWebpage.body) ?? "";
    final spotifyWebPlayerUrl =
        RegExp(r'(?<=<script src=")(https:\/\/open.spotifycdn.com\/cdn\/build\/web-player\/web-player.+?)(?=")').stringMatch(spotifyWebpage.body) ?? "";
    if (kDebugMode) {
      print("Spotify bearer token: $bearerToken");
      print("Spotify token: $spotifyToken");
      print("Spotify client id: $clientId");
      print("Spotify web player url: $spotifyWebPlayerUrl");
    }

    // get query hashes in main web player file
    final spotifyWebPlayer = await http.get(
      Uri.parse(spotifyWebPlayerUrl),
      headers: {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
      },
    );
    if (spotifyWebPlayer.statusCode == 200) {
      final queries = RegExp(r'(?<="(?<name>.+?)","query",")(?<hash>.+?)(?=")').allMatches(spotifyWebPlayer.body);
      for (final query in queries) {
        if (query.namedGroup("name") == null || query.namedGroup("hash") == null) return;
        queryHashes[query.namedGroup("name")!] = query.namedGroup("hash")!;
        if (kDebugMode) {
          print("Spotify ${query.namedGroup("name")!} query hash: ${query.namedGroup("hash")!}");
        }
      }
    } else {
      return;
    }

    // get additional query hashes
    // extract possible file ids
    final possibleFileIds = RegExp(
            r'build\/web-player\/(?<id>\d+)\.css":"https:\/\/open-exp\.spotifycdn\.com\/cdn\/build\/web-player\/\1\.(?<hash>[a-z0-9]+)\.css","build\/web-player\/\1\.js":"https:\/\/open-exp\.spotifycdn\.com\/cdn\/build\/web-player\/\1\.\2\.js')
        .allMatches(spotifyWebPlayer.body)
        .map((RegExpMatch m) => m.namedGroup("id"));
    // extract proper hashes
    final hashes = <String, String>{};
    RegExp(r'(?<=\+{(\d+:"[a-z0-9]+",?)*)(?<m>\d+:"[a-z0-9]+"),?(?=(\d+:"[a-z0-9]+",?)*}\[.+?]\+"\.js")')
        .allMatches(spotifyWebPlayer.body)
        .forEach((RegExpMatch m) {
      final entry = m.namedGroup("m");
      if (entry == null) return;
      final parsed = RegExp(r'(?<id>\d+):"(?<hash>[a-z0-9]+)"').firstMatch(entry);
      if (parsed?.namedGroup("id") == null || parsed?.namedGroup("hash") == null) return;
      hashes[parsed!.namedGroup("id")!] = parsed.namedGroup("hash")!;
    });
    // fetch each js file
    for (final id in possibleFileIds) {
      final url = "https://open-exp.spotifycdn.com/cdn/build/web-player/$id.${hashes[id]}.js";
      final js = await http.get(Uri.parse(url));
      if (js.statusCode == 200) {
        final queries = RegExp(r'(?<="(?<name>.+?)","query",")(?<hash>.+?)(?=")').allMatches(js.body);
        for (final query in queries) {
          if (query.namedGroup("name") == null || query.namedGroup("hash") == null) return;
          queryHashes[query.namedGroup("name")!] = query.namedGroup("hash")!;
          if (kDebugMode) {
            print("Spotify ${query.namedGroup("name")!} query hash: ${query.namedGroup("hash")!}");
          }
        }
      }
    }

    // get client token
    // spotify is picky about headers
    // http.post doesn't work because it adds bad things to the request header
    final spotifyClientToken = await jsonPostRequest(
      Uri.parse("https://clienttoken.spotify.com/v1/clienttoken"),
      headers: {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
        "accept": "application/json",
        "accept-language": "en-US,en;q=0.9",
        "content-type": "application/json",
      },
      body: json.encode(
        {
          "client_data": {
            "client_version": clientVersion,
            "client_id": clientId,
            "js_sdk_data": {
              "device_brand": "unknown",
              "device_model": "unknown",
              "os": "windows",
              "os_version": "NT 10.0",
              "device_id": spotifyToken,
              "device_type": "computer"
            }
          }
        },
      ),
    );

    if (spotifyClientToken.statusCode == 200) {
      clientToken = RegExp(r'(?<="token":")(.+?)(?=")').stringMatch(spotifyClientToken.body) ?? "";
      if (kDebugMode) {
        print("Spotify client token: $clientToken");
      }
    }
  }

  Future<void> getHomeFeed() async {
    final String timezone = await FlutterTimezone.getLocalTimezone();
    final Map<String, dynamic> geolocationData = jsonDecode(RegExp(r"({.+})").stringMatch((await http.get(
          Uri.parse("https://geolocation.onetrust.com/cookieconsentpub/v1/geo/location"),
        ))
            .body) ??
        "");
    if (kDebugMode) {
      print("Timezone: $timezone");
      print("Country: ${geolocationData["country"] ?? "US"}");
    }
    final queryVariables = Uri.encodeComponent(
      jsonEncode(
        {"timeZone": timezone, "sp_t": spotifyToken, "country": geolocationData["country"] ?? "US", "facet": null, "sectionItemsLimit": 10},
      ),
    );
    final queryExtensions = Uri.encodeComponent(
      jsonEncode(
        {
          "persistedQuery": {
            "version": 1,
            "sha256Hash": queryHashes["home"],
          }
        },
      ),
    );
    // can query the following:
    // home
    // homeFeedChips
    // homeSubfeed
    // homeSection
    final res = await http.get(
      Uri.parse("https://api-partner.spotify.com/pathfinder/v1/query?operationName=home&variables=$queryVariables&extensions=$queryExtensions"),
      headers: {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
        "authorization": "Bearer $bearerToken",
      },
    );
    if (res.statusCode == 200) {
      homeFeedData = jsonDecode(utf8.decode(res.bodyBytes));
    }
  }

  Future<Map<String, dynamic>> getPlaylist(String uri) async {
    if (playlistCache[uri] != null) {
      return playlistCache[uri];
    }
    final queryVariables = Uri.encodeComponent(
      jsonEncode(
        {
          "uri": uri,
          "offset": 0,
          "limit": 25,
        },
      ),
    );
    final queryExtensions = Uri.encodeComponent(
      jsonEncode(
        {
          "persistedQuery": {
            "version": 1,
            "sha256Hash": queryHashes["fetchPlaylist"],
          }
        },
      ),
    );
    final res = await http.get(
      Uri.parse("https://api-partner.spotify.com/pathfinder/v1/query?operationName=fetchPlaylist&variables=$queryVariables&extensions=$queryExtensions"),
      headers: {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
        "authorization": "Bearer $bearerToken",
      },
    );
    if (res.statusCode != 200) {
      reload();
      return {};
    }

    var playlistRawData = jsonDecode(utf8.decode(res.bodyBytes));
    var playlistData = {
      "name": playlistRawData["data"]["playlistV2"]["name"],
      "description": playlistRawData["data"]["playlistV2"]["description"],
      "uri": uri,
      "coverImage": {
        "url": playlistRawData["data"]["playlistV2"]["images"]["items"][0]["sources"][0]["url"],
        "color": playlistRawData["data"]["playlistV2"]["images"]["items"][0]["extractedColors"]["colorRaw"]["hex"]
      },
      "owner": {
        "name": playlistRawData["data"]["playlistV2"]["ownerV2"]["data"]["name"],
        "uri": playlistRawData["data"]["playlistV2"]["ownerV2"]["data"]["uri"],
        "profilePicture": playlistRawData["data"]["playlistV2"]["ownerV2"]["data"]["avatar"]["sources"][0]["url"]
      },
      "tracks": playlistRawData["data"]["playlistV2"]["content"]["items"],
      "totalTracks": playlistRawData["data"]["playlistV2"]["content"]["totalCount"],
    };
    playlistCache[uri] = playlistData;

    return playlistData;
  }

  Future<bool> loadMorePlaylistItems(String uri, {int count = 100}) async {
    if (playlistCache[uri] == null) return false;
    if (playlistCache[uri]["tracks"].length >= playlistCache[uri]["totalTracks"]) return true;

    final queryVariables = Uri.encodeComponent(
      jsonEncode(
        {
          "uri": uri,
          "offset": playlistCache[uri]["tracks"].length,
          "limit": 100,
        },
      ),
    );
    final queryExtensions = Uri.encodeComponent(
      jsonEncode(
        {
          "persistedQuery": {
            "version": 1,
            "sha256Hash": queryHashes["fetchPlaylist"],
          }
        },
      ),
    );
    final res = await http.get(
      Uri.parse(
          "https://api-partner.spotify.com/pathfinder/v1/query?operationName=fetchPlaylistContents&variables=$queryVariables&extensions=$queryExtensions"),
      headers: {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
        "authorization": "Bearer $bearerToken",
      },
    );

    if (res.statusCode != 200) {
      reload();
      return false;
    }

    var playlistRawData = jsonDecode(utf8.decode(res.bodyBytes));
    playlistCache[uri]["tracks"] = [...playlistCache[uri]["tracks"], ...playlistRawData["data"]["playlistV2"]["content"]["items"]];
    return true;
  }
}
