import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

class HttpService {
  final String baseURL = 'http://192.168.1.4:8000/api/';

  Future<http.Response> get(String endpoint, Map map) async {
    final url = Uri.parse('$baseURL$endpoint');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    log(response.body);
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
      // Add fields
      request.fields.addAll(fields);
      // Add file if available
      if (file != null) {
        final imageFile = await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
        );
        request.files.add(imageFile);
        log('File added: ${file.path}');
      }
      log('POST with File to: $url');
      log('Fields: ${request.fields}');
      log('Files: ${request.files.length}');
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      log('POST with File Response: ${response.statusCode} - ${response.body}');
      return response;
    } catch (e) {
      log('Error in postWithFile: $e');
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
    log('PUT Response: ${response.body}');
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