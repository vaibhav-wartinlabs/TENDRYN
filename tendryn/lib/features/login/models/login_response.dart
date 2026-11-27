import 'package:tendryn/models/auth_tokens.dart';
import 'package:tendryn/models/user.dart';

class LoginResponse {
  const LoginResponse({required this.tokens, required this.user});

  final AuthTokens tokens;
  final User user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        tokens: AuthTokens.fromJson(json),
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {...tokens.toJson(), 'user': user.toJson()};
}
