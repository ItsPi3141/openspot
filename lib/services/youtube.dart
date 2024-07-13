import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:http/http.dart' as http;

String decipherTransformationsJs = "";
String decipherJs = "";
String nTransformJs = "";

class YouTubeProvider with ChangeNotifier {
  String apiUrl = "https://music.youtube.com/youtubei/v1/player?prettyPrint=false";
  String searchApiUrl = "https://music.youtube.com/youtubei/v1/search?prettyPrint=false";
  int targetItag = 140;

  bool isExtractingFunctions = false;

  JavascriptRuntime flutterJs = getJavascriptRuntime();

  YouTubeProvider() {
    try {
      extractFunctions();
    } catch (_) {
      isExtractingFunctions = false;
    }
  }

  Future<Map<String, String>> extractFunctions() async {
    if (decipherTransformationsJs.isNotEmpty && decipherJs.isNotEmpty && nTransformJs.isNotEmpty) {
      return {
        "decipher": decipherJs,
        "ncode": nTransformJs,
      };
    }
    final emptyResponse = {
      "decipher": "",
      "ncode": "",
    };
    if (isExtractingFunctions) return emptyResponse;

    isExtractingFunctions = true;

    // extract base.js url
    final youtubeWebpage = await http.get(
      Uri.parse("https://youtube.com"),
    );
    String baseJsUrl;
    if (youtubeWebpage.statusCode == 200) {
      baseJsUrl = RegExp(r'"jsUrl":"(?<url>\/s\/player\/(?<build>[0-9a-f]*)\/player_ias\.vflset\/(?<region>[a-z]+_[A-Z]+)\/base.js)"')
              .firstMatch(youtubeWebpage.body)
              ?.namedGroup("url") ??
          "";
      if (kDebugMode) {
        print("Youtube base.js url: $baseJsUrl");
      }
    } else {
      return emptyResponse;
    }

    // fetch base.js
    final baseJsRes = await http.get(Uri.parse("https://youtube.com$baseJsUrl"));
    if (baseJsRes.statusCode != 200) {
      return emptyResponse;
    }
    String baseJs = baseJsRes.body;

    String extractDecipherTransformations() {
      if (decipherTransformationsJs.isNotEmpty) {
        return decipherTransformationsJs;
      }

      String transformationsFuncName = _getTextBetween(baseJs, 'a=a.split("");', ".");
      if (transformationsFuncName.isNotEmpty) {
        // find function declaration
        String declaration = "var $transformationsFuncName=";
        String afterTransformationsFunc = baseJs.substring(baseJs.indexOf(declaration) + declaration.length);
        String transformationsFunc = "$declaration${_cutJsFunction(afterTransformationsFunc)}";

        decipherTransformationsJs = transformationsFunc;

        return transformationsFunc;
      }
      return "";
    }

    String extractDecipher() {
      if (decipherJs.isNotEmpty) {
        return decipherJs;
      }

      String deciphFuncName = _getTextBetween(baseJs, 'a.set("alr","yes");c&&(c=', "(decodeURIComponent(c)");
      if (deciphFuncName.isNotEmpty) {
        // find function declaration
        String declaration = '$deciphFuncName=function(a)';
        String afterDeciphFunc = baseJs.substring(baseJs.indexOf(declaration) + declaration.length);
        String transformations = extractDecipherTransformations();
        String deciphFunc = '$transformations;var $declaration${_cutJsFunction(afterDeciphFunc)};$deciphFuncName(deciph)';

        decipherJs = deciphFunc;

        return deciphFunc;
      }
      return "";
    }

    String extractNcode() {
      if (nTransformJs.isNotEmpty) {
        return nTransformJs;
      }

      String ncodeFuncName = _getTextBetween(baseJs, "c=a.get(b))&&(c=", "(c)");
      if (ncodeFuncName.contains("[")) {
        // it could be something like
        // var wrapperArray=[actualFunction];
        ncodeFuncName = _getTextBetween(baseJs, "var ${ncodeFuncName.split("[")[0]}=[", "]");
      }
      if (ncodeFuncName.isNotEmpty) {
        // find function declaration
        String declaration = '$ncodeFuncName=function(a)';
        String afterNcodeFunc = baseJs.substring(baseJs.indexOf(declaration) + declaration.length);
        String ncodeFunc = 'var $declaration${_cutJsFunction(afterNcodeFunc)}';

        nTransformJs = ncodeFunc;

        return '$ncodeFunc;$ncodeFuncName(ncode)';
      }
      return "";
    }

    isExtractingFunctions = false;
    return {
      "decipher": extractDecipher(),
      "ncode": extractNcode(),
    };
  }

  Future<String> getSongDownloadUrl(id) async {
    dynamic songInfo = jsonDecode((await http.post(Uri.parse(apiUrl), body: createUrlFetchBody(id))).body);

    if (((songInfo?["playabilityStatus"]?["status"] ?? "") != "OK")) return "";

    dynamic downloadInfo = (songInfo?["streamingData"]?["adaptiveFormats"] as List).firstWhere((e) => (e?["itag"] ?? "") == targetItag);
    var downloadUrl = "";
    if ((downloadInfo as Map).containsKey("url")) {
      downloadUrl = downloadInfo["url"];
    } else {
      downloadUrl = await decipher(downloadInfo["url"] ?? downloadInfo["signatureCipher"] ?? downloadInfo["cipher"]);
    }
    return downloadUrl;
  }

  Future<String> getYouTubeSongId(name, artist) async {
    if (kDebugMode) {
      print('Searching for "$artist $name"...');
    }
    dynamic searchResults = jsonDecode((await http.post(Uri.parse(searchApiUrl), body: createSearchFetchBody("$artist $name"))).body);
    String videoId =
        (searchResults?["contents"]?["tabbedSearchResultsRenderer"]?["tabs"][0]?["tabRenderer"]?["content"]?["sectionListRenderer"]?["contents"] ?? [])
                    .firstWhere((e) => (e as Map).containsKey("musicShelfRenderer"))?["musicShelfRenderer"]?["contents"][0]?["musicResponsiveListItemRenderer"]
                ?["playlistItemData"]?["videoId"] ??
            "";
    return videoId;
  }

  String createSearchFetchBody(query) {
    return jsonEncode({
      "context": {
        "client": {
          "clientName": "WEB_REMIX",
          "clientVersion": "1.20240501.01.00",
        }
      },
      "query": query,
    });
  }

  String createUrlFetchBody(musicId) {
    return jsonEncode({
      "videoId": musicId,
      "context": {
        "client": {
          "clientName": "IOS",
          "clientVersion": "19.09.3",
        }
      }
    });
  }

// helper functions for deciphering download urls
  Future<String> _decipherSig(String sig) async {
    final f = await extractFunctions();
    JsEvalResult res = flutterJs.evaluate("var deciph=`$sig`;${f["decipher"]}");
    return res.toString();
  }

  Future<String> _nTransform(String ncode) async {
    final f = await extractFunctions();
    JsEvalResult res = flutterJs.evaluate("var ncode=`$ncode`;${f["ncode"]}");
    return res.toString();
  }

  Future<String> decipher(String url) async {
    // decipher
    Map<String, String> queries = Uri.splitQueryString(url.split("?").elementAtOrNull(1) ?? url);
    if (!queries.containsKey("s") || queries["url"] == "") return queries["url"] ?? "";
    Uri newUrl = Uri.dataFromString(Uri.decodeComponent(queries["url"] as String));
    Map<String, String> newDeciphQueries = {};
    for (var key in newUrl.queryParameters.keys) {
      newDeciphQueries[key] = newUrl.queryParameters[key] ?? "";
    }
    newDeciphQueries[queries["sp"] ?? "signature"] = await _decipherSig(Uri.decodeComponent(queries["s"] as String));
    newUrl.replace(queryParameters: newDeciphQueries);

    // ncode
    String n = newUrl.queryParameters["n"] ?? "";
    if (n == "") return newUrl.toString();
    Map<String, String> newNcodeQueries = {};
    for (var key in newUrl.queryParameters.keys) {
      newNcodeQueries[key] = newUrl.queryParameters[key] ?? "";
    }
    newNcodeQueries["n"] = await _nTransform(Uri.decodeComponent(n));
    newUrl.replace(queryParameters: newNcodeQueries);
    return newUrl.toString();
  }

  // helper functions
  String _getTextBetween(String text, String start, String end) {
    String after = text.substring(text.indexOf(start) + start.length);
    return after.substring(0, after.indexOf(end));
  }

  String _cutJsFunction(String text) {
    int openBrackets = 0;
    bool isInString = false;
    String highestStringChar = "";
    bool isInRegex = false;
    for (int i = 0; i < text.length; i++) {
      if (!isInString && !isInRegex && ['"', "'", "`"].contains(text[i])) {
        isInString = true;
        highestStringChar = text[i];
      } else if (isInString && !isInRegex && text[i] == highestStringChar && text[i - 1] != "\\") {
        isInString = false;
        highestStringChar = "";
      } else if (text[i] == "/" && (text[i - 1] == "," || isInRegex) && !isInString) {
        isInRegex = !isInRegex;
      } else if (!isInRegex && !isInString) {
        if (text[i] == "{") openBrackets++;
        if (text[i] == "}") openBrackets--;
      }

      if (openBrackets == 0) return text.substring(0, i + 1);
    }
    return "{}";
  }
}
