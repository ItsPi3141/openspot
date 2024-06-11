import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class YouTubeProvider extends ChangeNotifier {
  String apiUrl = "https://music.youtube.com/youtubei/v1/player?prettyPrint=false";
  String searchApiUrl = "https://music.youtube.com/youtubei/v1/search?prettyPrint=false";
  int targetItag = 140;

  YouTubeProvider();

  Future<String> getSongDownloadUrl(id) async {
    dynamic songInfo = jsonDecode((await http.post(Uri.parse(apiUrl), body: createUrlFetchBody(id))).body);

    if (((songInfo?.playabilityStatus?.status ?? "") != "OK")) return "";

    dynamic downloadInfo = (songInfo?.streamingData?.adaptiveFormats as List).firstWhere((e) => e.itag == targetItag);
    var downloadUrl = "";
    if ((downloadInfo as Map).containsKey("url")) {
      downloadUrl = downloadInfo["url"];
    } else {
      downloadUrl = decipher(downloadInfo["url"] ?? downloadInfo["signatureCipher"] ?? downloadInfo["cipher"]);
    }
    return downloadUrl;
  }

  Future<String> getYouTubeUrl(name, artist) async {
    dynamic searchResults = jsonDecode((await http.post(Uri.parse(searchApiUrl), body: createSearchFetchBody("$artist $name"))).body);
    String videoId = (searchResults?.contents?.tabbedSearchResultsRenderer?.tabs[0]?.tabRenderer?.content?.sectionListRenderer?.contents as List)
            .firstWhere((e) => (e as Map).containsKey("musicShelfRenderer"))
            ?.musicShelfRenderer
            ?.contents[0]
            ?.musicResponsiveListItemRenderer
            ?.playlistItemData
            ?.videoId ??
        "";
    return videoId;
  }
}

Map<String, dynamic> createSearchFetchBody(query) {
  return {
    "context": {
      "client": {
        "clientName": "WEB_REMIX",
        "clientVersion": "1.20240501.01.00",
      },
    },
    "query": query,
  };
}

Map<String, dynamic> createUrlFetchBody(musicId) {
  return {
    "videoId": musicId,
    "context": {
      "client": {
        "clientName": "WEB",
        "clientVersion": "2.20210622.10.00",
      },
      "thirdParty": {
        "embedUrl": "https://music.youtube.com/watch?v=$musicId",
      },
    },
    "playbackContext": {
      "contentPlaybackContext": {
        "signatureTimestamp": 19822, // from youtube music build d0ea0c5b
      },
    },
  };
}

// helper functions for deciphering download urls
// taken from youtube music build d0ea0c5b
String _decipherSig(String sig) {
  List<String> swapElementAtPos(List<String> array, int position) {
    var temp = array[0];
    array[0] = array[position % array.length];
    array[position % array.length] = temp;
    return array;
  }

  List<String> reverseList(List<String> array) {
    return List.from(array.reversed);
  }

  List<String> spliceList(List<String> array, int position) {
    List<String> temp = array;
    temp.removeRange(0, position);
    return temp;
  }

  var a = sig.split("");
  a = reverseList(a);
  a = spliceList(a, 1);
  a = swapElementAtPos(a, 21);
  a = reverseList(a);
  a = swapElementAtPos(a, 13);
  a = swapElementAtPos(a, 18);
  a = reverseList(a);
  a = swapElementAtPos(a, 19);
  return a.join("");
}

String _nTransform(String ncode) {
  return "enhanced_except_7ZoBkuX-_w8_$ncode";
}

String decipher(String url) {
  // decipher
  Map<String, String> queries = Uri.splitQueryString(url.split("?").elementAtOrNull(1) ?? url);
  if (!queries.containsKey("s") || queries["url"] == "") return queries["url"] ?? "";
  Uri newUrl = Uri.dataFromString(Uri.decodeComponent(queries["url"] as String));
  newUrl.queryParameters.update(queries["sp"] ?? "signature", (value) => _decipherSig(Uri.decodeComponent(queries["s"] as String)));

  // ncode
  String n = newUrl.queryParameters["n"] ?? "";
  if (n == "") return newUrl.toString();
  newUrl.queryParameters.update("n", (value) => _nTransform(Uri.decodeComponent(n)));
  return newUrl.toString();
}
