import 'dart:convert';
import 'dart:io';
import 'dart:math';

String randomAlphanumeric(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

class JsonPostRequestResponse {
  final int _statusCode;
  final String _body;
  JsonPostRequestResponse(this._statusCode, this._body);
  int get statusCode => _statusCode;
  String get body => _body;
}

Future<JsonPostRequestResponse> jsonPostRequest(
  Uri url, {
  Map<String, String> headers = const {},
  String body = "",
}) async {
  HttpClient httpClient = HttpClient();
  HttpClientRequest request = await httpClient.postUrl(url);
  headers.forEach((key, value) {
    request.headers.set(key, value);
  });
  request.add(utf8.encode(body));
  HttpClientResponse response = await request.close();

  String responseBody = await response.transform(utf8.decoder).join();
  int statusCode = response.statusCode;
  httpClient.close();
  return JsonPostRequestResponse(statusCode, responseBody);
}
