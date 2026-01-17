import 'package:http/http.dart' as http;
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/usecase/request/register_request.dart';


class AuthRepository {
  final HttpService httpService;

  AuthRepository({required this.httpService});

  Future<http.Response> register(RegisterRequest request) async {
    final response = await httpService.post('register', request.toMap());
    return response;
  }

  Future<http.Response> login(Map<String, dynamic> body) async {
    final response = await httpService.post('login', body);
    return response;
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