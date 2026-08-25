import 'user.dart';

/// Auth Response Entity
/// Represents the response from login/register
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}
