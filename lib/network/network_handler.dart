import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class NetworkHandler {
  String baseurl = "https://api.ckempireapimanager.com";
  var log = Logger();

  FlutterSecureStorage storage = FlutterSecureStorage();

  Future get(String url) async {
    url = formatter(url);
    var response =
        await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer'});
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.i(response.body);
      return json.decode(response.body);
    }
    log.i(response.body);
    log.i(response.statusCode);
  }

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    url = formatter(url);
    var response = await http.post(Uri.parse(url),
        headers: {
          "Content-type": "application/json",
          'Authorization': 'Bearer'
        },
        body: json.encode(body));
    return response;
  }

  String formatter(String url) {
    return baseurl + url;
  }

  Future<http.StreamedResponse> patchImage(String url, String filePath) async {
    url = formatter(url);
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('img', filePath));
    request.headers.addAll(
        {"Content-type": "multipart/form-data", 'Authorization': 'Bearer '});
    var response = request.send();
    return response;
  }
}
