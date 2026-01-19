import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpService {
  final String baseURL = 'http://192.168.1.4:8000/api/';

  Future<http.Response> get(String endpoint, Map<String, dynamic>? queryParams) async {
    Uri url = Uri.parse('$baseURL$endpoint');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      final formattedParams = queryParams.map((key, value) => MapEntry(key, value.toString()));
      url = url.replace(queryParameters: formattedParams);
    }

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseURL$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> postWithFile(
    String endPoint,
    Map<String, String> fields,
    File? file,
    String fileFieldName,
  ) async {
    try {
      final url = Uri.parse('$baseURL$endPoint');
      final request = http.MultipartRequest('POST', url);
      
      request.fields.addAll(fields);
      
      if (file != null) {
        final imageFile = await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
        );
        request.files.add(imageFile);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> put(String endPoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseURL$endPoint');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> delete(String endPoint) async {
    final url = Uri.parse('$baseURL$endPoint');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return response;
  }
}