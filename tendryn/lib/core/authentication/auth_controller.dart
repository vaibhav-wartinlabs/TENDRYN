import 'package:get/get.dart';
import 'package:tendryn/core/api/api_exception.dart';
import 'package:tendryn/core/authentication/auth_service.dart';
import 'package:tendryn/core/authentication/auth_state.dart';
import 'package:tendryn/models/user.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/auth_service.dart';

enum Permission { viewDashboard, sendMessages, manageUsers }

/// App-wide session state (permanent). Everything that needs "who is signed in"
/// observes [state]; the router guard and interceptors call into it.
class AuthController extends GetxController {
  AuthController({required this._authService, required this._session, this._previewUser});

  final AuthService _authService;
  final SessionService _session;

  /// Development preview only: when set, startup signs in as this user
  /// without any token or API call. Null in normal operation.
  final User? _previewUser;

  final state = const AuthState.unknown().obs;

  bool get isAuthenticated => state.value.isAuthenticated;
  User? get user => state.value.user;

  static const Map<UserRole, Set<Permission>> _grants = {
    UserRole.admin: {Permission.viewDashboard, Permission.sendMessages, Permission.manageUsers},
    UserRole.member: {Permission.viewDashboard, Permission.sendMessages},
  };

  bool can(Permission permission) {
    final current = user;
    return current != null && (_grants[current.role]?.contains(permission) ?? false);
  }

  /// Called once at startup. Never throws; any failure means "signed out".
  Future<void> restoreSession() async {
    if (_previewUser != null) {
      state.value = AuthState.authenticated(_previewUser);
      return;
    }
    try {
      final tokens = await _session.readTokens();
      if (tokens == null) {
        state.value = const AuthState.unauthenticated();
        return;
      }
      state.value = AuthState.authenticated(await _authService.fetchCurrentUser());
    } catch (_) {
      state.value = const AuthState.unauthenticated();
    }
  }

  /// Throws [ApiException] so the login form can show it.
  Future<void> login(String email, String password) async {
    final result = await _authService.login(email: email, password: password);
    await _session.saveTokens(result.tokens);
    state.value = AuthState.authenticated(result.user);
  }

  /// Updates current user's role and display name (for active persona/role switcher).
  void updateActiveRole(String jobTitle, [String? displayName]) {
    final current = user;
    final updated = User(
      id: current?.id ?? 'demo-user',
      name: displayName ?? current?.name ?? 'Dr Thandi Nkosi',
      email: current?.email ?? 'alex@example.com',
      role: current?.role ?? UserRole.member,
      jobTitle: jobTitle,
      clinicName: current?.clinicName ?? 'Soweto Community Health Centre',
    );
    state.value = AuthState.authenticated(updated);
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on ApiException {
      // Server-side logout is best effort; the local session always ends.
    }
    await _endSession();
  }

  /// Refresh token rejected or API said 401 for good: go back to login.
  Future<void> handleSessionExpired() async {
    if (!isAuthenticated) return;
    await _endSession();
  }

  Future<void> _endSession() async {
    await _session.clear();
    state.value = const AuthState.unauthenticated();
    Get.offAllNamed(AppRoutes.login);
  }
}
