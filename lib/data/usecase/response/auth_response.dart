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
    final userData = json['user'] != null ? json['user'] : json;

    return AuthResponse(
      token: json['token'] ?? json['access_token'] ?? '', 
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
    );
  }
}