class AuthResponse {
  final String token;
  final String name;
  final String email;

  AuthResponse({
    required this.token,
    required this.name,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    var data = json;
    if (json.containsKey('data') && json['data'] is Map) {
      data = json['data'];
    }

    String token = '';
    if (data['token'] != null) token = data['token'];
    else if (data['access_token'] != null) token = data['access_token'];
    else if (json['token'] != null) token = json['token'];
    else if (json['access_token'] != null) token = json['access_token'];

    final userData = data['user'] ?? json['user'] ?? data;

    return AuthResponse(
      token: token,
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
    );
  }
}