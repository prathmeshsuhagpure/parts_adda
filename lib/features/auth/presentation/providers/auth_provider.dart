import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/user_model.dart';
import '../../../../core/storage/secure_storage.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpSent,
  b2bSubmitted,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  AuthProvider({required AuthRepository repo}) : _repo = repo;

  // ── State
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  bool _initialized = false;
  String? _error;
  bool _seenOnboarding = false;
  String? _dealerStatus;

  // ── Getters
  AuthStatus get status => _status;

  UserModel? get user => _user;

  String? get error => _error;

  bool get isLoading => _status == AuthStatus.loading;

  bool get seenOnboarding => _seenOnboarding;

  String? get dealerStatus => _dealerStatus;

  Future<void> loadOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    _seenOnboarding = prefs.getBool("seen_onboarding") ?? false;
    notifyListeners();
  }

  Future<void> setOnboardingSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_onboarding", value);

    _seenOnboarding = value;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;

    try {
      await loadOnboarding();
      final loggedIn = await SecureStorage.isLoggedIn();

      if (!loggedIn) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      final user = await _repo.getCurrentUser();
      _user = user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      await SecureStorage.clearAll();
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> login({
    required String phoneOrEmail,
    required String password,
  }) async {
    _setLoading();
    try {
      final token = await _repo.login(
        phoneOrEmail: phoneOrEmail,
        password: password,
      );
      await _saveTokens(token);
      _user = token.user;
      _status = AuthStatus.authenticated;
      _error = null;
      await _handleFCMToken();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = _parseError(e);
    }
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading();
    try {
      final token = await _repo.signup(
        email: email,
        name: name,
        phone: phone,
        password: password,
        role: role,
      );
      await _saveTokens(token);
      _user = token.user;
      _status = AuthStatus.authenticated;
      _error = null;
      await _handleFCMToken();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = _parseError(e);
    }
    notifyListeners();
  }

  Future<void> applyForDealer({
    required String businessName,
    required String gstNumber,
    required String contactName,
    required String phone,
    required String address,
    required String email,
    required String panNumber,
    required String city,
    required String state,
    required String pincode,
    required String password,
  }) async {
    _setLoading();
    try {
      await _repo.applyForDealer(
        businessName: businessName,
        gstNumber: gstNumber,
        contactName: contactName,
        phone: phone,
        address: address,
        email: email,
        panNumber: panNumber,
        city: city,
        state: state,
        pincode: pincode,
        password: password,
      );
      _status = AuthStatus.b2bSubmitted;
      _error = null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = _parseError(e);
    }
    notifyListeners();
  }

  Future<void> getDealerStatus() async {
    try {
      final status = await _repo.getDealerStatus();
      _dealerStatus = status;
      _error = null;
    } catch (e) {
      _error = _parseError(e);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    await SecureStorage.clearAll();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers
  void _setLoading() {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
  }

  Future<void> _saveTokens(AuthTokenModel token) async {
    await SecureStorage.saveAccessToken(token.accessToken);
    await SecureStorage.saveRefreshToken(token.refreshToken);
    await SecureStorage.saveUserId(token.user.id);
    await SecureStorage.saveUserRole(token.user.role.name);
  }

  String _parseError(dynamic e) {
    if (e is Exception) return e.toString().replaceFirst('Exception: ', '');
    return e.toString();
  }

  Future<void> _handleFCMToken() async {
    try {
      final messaging = FirebaseMessaging.instance;

      final token = await messaging.getToken();

      if (token != null) {
        print("FCM TOKEN 👉 $token");

        await _repo.updateFcmToken(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print("REFRESHED TOKEN 👉 $newToken");

        try {
          await _repo.updateFcmToken(newToken);
        } catch (e) {
          print("FCM refresh error: $e");
        }
      });
    } catch (e) {
      print("FCM error: $e");
    }
  }
}
