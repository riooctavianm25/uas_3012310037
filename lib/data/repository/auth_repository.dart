import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/usecase/request/register_request.dart';
import 'package:uas_3012310037/data/usecase/response/auth_response.dart';


class AuthRepository {
  final HttpService httpService;

  AuthRepository({required this.httpService});

  Future<AuthRepository> register(RegisterRequest request) async {
    final response = await httpService.post('register', request.toMap());
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AuthRepository(httpService: httpService);
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<AuthRepository> login(Map<String, dynamic> body) async {
    final response = await httpService.post('login', body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthRepository(httpService: httpService);
    } else {
      throw Exception('Failed to login user');
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