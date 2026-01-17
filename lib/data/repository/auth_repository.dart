import 'package:http/http.dart' as http;
import 'package:uas_3012310037/data/service/httpservice.dart';

class AuthRepository {
  final HttpService _httpService = HttpService();
  
  Future<http.Response> register(Map<String, dynamic> body) async {
    final response = await _httpService.post('register', body);
    return response;
  }

  Future<http.Response> login(Map<String, dynamic> body) async {
    final response = await _httpService.post('login', body);
    return response;
  }

  Future<http.Response> logout() async {
    final response = await _httpService.post('logout', {});
    return response;
  }

  Future<http.Response> getUserProfile() async {
    final response = await _httpService.get('profile', {});
    return response;
  }
}