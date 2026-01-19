import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/usecase/request/register_request.dart';
import 'package:uas_3012310037/data/usecase/response/auth_response.dart';

class AuthRepository {
  final HttpService httpService;

  AuthRepository({required this.httpService});

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await httpService.post('auth/register', request.toMap());
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        
        // PERBAIKAN: Hapus .user karena di AuthResponse data sudah di-flatten (langsung)
        await prefs.setString('token', authResponse.token);
        await prefs.setString('name', authResponse.name); 
        await prefs.setString('email', authResponse.email);

        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to register user';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuthResponse> login(Map<String, dynamic> body) async {
    try {
      final response = await httpService.post('auth/login', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        
        // PERBAIKAN: Hapus .user di sini juga
        await prefs.setString('token', authResponse.token);
        await prefs.setString('name', authResponse.name);
        await prefs.setString('email', authResponse.email);

        return authResponse;
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final response = await httpService.post('logout', {});
    return response;
  }

  Future<http.Response> getUserProfile() async {
    final response = await httpService.get('profile', {});
    return response;
  }
}