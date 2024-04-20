import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:openspot/utils.dart';

class SpotifyProvider extends ChangeNotifier {
  String bearerToken = "";
  String clientToken = "";
  String spotifyToken = "";

  String clientId = "";

  String spotifyWebPlayerUrl = "";
  String queryHash = "";

  dynamic homeFeedData;

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
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
      },
    );
    if (spotifyWebpage.statusCode == 200) {
      bearerToken = RegExp(r'(?<="accessToken":")(.+?)(?=")')
              .stringMatch(spotifyWebpage.body) ??
          "";
      spotifyToken = RegExp(r'(?<="correlationId":")(.+?)(?=")')
              .stringMatch(spotifyWebpage.body) ??
          "";
      clientId = RegExp(r'(?<="clientId":")(.+?)(?=")')
              .stringMatch(spotifyWebpage.body) ??
          "";
      spotifyWebPlayerUrl =
          RegExp(r'(?<=<script src=")(https:\/\/open.spotifycdn.com\/cdn\/build\/web-player\/web-player.+?)(?=")')
                  .stringMatch(spotifyWebpage.body) ??
              "";
      if (kDebugMode) {
        print("Spotify bearer token: $bearerToken");
        print("Spotify token: $spotifyToken");
        print("Spotify client id: $clientId");
        print("Spotify web player url: $spotifyWebPlayerUrl");
      }
    }

    // get query hash
    final spotifyWebPlayer = await http.get(
      Uri.parse(spotifyWebPlayerUrl),
      headers: {
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
      },
    );
    if (spotifyWebPlayer.statusCode == 200) {
      queryHash = RegExp(r'(?<="home","query",")(.+?)(?=")')
              .stringMatch(spotifyWebPlayer.body) ??
          "";
      if (kDebugMode) {
        print("Spotify query hash: $queryHash");
      }
    }

    // get client token
    // spotify is picky about headers
    // http.post doesn't work because it adds bad things to the request header
    final spotifyClientToken = await jsonPostRequest(
      Uri.parse("https://clienttoken.spotify.com/v1/clienttoken"),
      headers: {
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
        "accept": "application/json",
        "accept-language": "en-US,en;q=0.9",
        "content-type": "application/json",
      },
      body: json.encode(
        {
          "client_data": {
            "client_version":
                "1.2.69.420.${randomAlphanumeric(9)}", // format: 1.2.36.659.gbea22fb8
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
      clientToken = RegExp(r'(?<="token":")(.+?)(?=")')
              .stringMatch(spotifyClientToken.body) ??
          "";
      if (kDebugMode) {
        print("Spotify client token: $clientToken");
      }
    }
  }

  Future<void> getHomeFeed() async {
    final String timezone = await FlutterTimezone.getLocalTimezone();
    final Map<String, dynamic> geolocationData =
        jsonDecode(RegExp(r"({.+})").stringMatch((await http.get(
              Uri.parse(
                  "https://geolocation.onetrust.com/cookieconsentpub/v1/geo/location"),
            ))
                .body) ??
            "");
    final queryVariables = Uri.encodeComponent(
      jsonEncode(
        {
          "timeZone": timezone,
          "sp_t": spotifyToken,
          "country": geolocationData["country"] ?? "US",
          "facet": null,
          "sectionItemsLimit": 10
        },
      ),
    );
    final queryExtensions = Uri.encodeComponent(
      jsonEncode(
        {
          "persistedQuery": {
            "version": 1,
            "sha256Hash": queryHash,
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
      Uri.parse(
          "https://api-partner.spotify.com/pathfinder/v1/query?operationName=home&variables=$queryVariables&extensions=$queryExtensions"),
      headers: {
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
        "authorization": "Bearer $bearerToken",
      },
    );
    if (res.statusCode == 200) {
      homeFeedData = jsonDecode(res.body);
    }
  }
}
