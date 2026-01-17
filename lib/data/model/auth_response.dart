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
    return AuthResponse(
      token: json['token'],
      name: json['name'],
      email: json['email'],
    );
  }
}