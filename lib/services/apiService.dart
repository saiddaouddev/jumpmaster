import 'dart:convert';
import 'dart:developer';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jumpmaster/core/Constants.dart';

class ApiService {
  static final _storage = GetStorage();

  static Future<Map<String, dynamic>> callApi({
    required String api,
    required String method,
    Map<String, dynamic>? data,
    XFile? imageFile,
  }) async {
    final token = _storage.read("token") ?? ""; 
    final url = Uri.parse(Constants.baseUrl + api);

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            url.replace(
              queryParameters: data?.map(
                (k, v) => MapEntry(k, v?.toString() ?? ''),
              ),
            ),
            headers: _headers(token),
          );
          break;

        case 'POST':
          response = await http.post(
            url,
            headers: _headers(token),
            body: jsonEncode(data ?? {}),
          );
          break;

        case 'PUT':
          response = await http.put(
            url,
            headers: _headers(token),
            body: jsonEncode(data ?? {}),
          );
          break;

        case 'DELETE':
          response = await http.delete(
            url,
            headers: _headers(token),
            body: jsonEncode(data ?? {}),
          );
          break;

        case 'MULTIPART':
          response = await _multipartRequest(url, token, data, imageFile);
          break;

        default:
          throw Exception('Unsupported method');
      }
      log(response.body.toString());
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }

  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<http.Response> _multipartRequest(
    Uri url,
    String token,
    Map<String, dynamic>? data,
    XFile? image,
  ) async {
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    data?.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', image.path),
      );
    }

    final streamed = await request.send();
    return http.Response(
      await streamed.stream.bytesToString(),
      streamed.statusCode,
    );
  }
}
