import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/usecase/request/register_request.dart';
import 'package:uas_3012310037/data/usecase/response/auth_response.dart';


class AuthRepository {
  final HttpService httpService;

  AuthRepository({required this.httpService});

  Future<void> register(RegisterRequest request) async {
    try {
      final response = await httpService.post('auth/register', request.toMap());
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to register user';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> login(Map<String, dynamic> body) async {
    try {
      final response = await httpService.post('auth/login', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to login user';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<http.Response> logout() async {
    final response = await httpService.post('logout', {});
    return response;
  }

  Future<http.Response> getUserProfile() async {
    final response = await httpService.get('profile', {});
    return response;
  }
}