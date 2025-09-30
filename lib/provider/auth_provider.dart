import 'package:community_report_app/models/profile.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/services/auth_services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;
      _isInitialized = true;

      notifyListeners();
    });
  }

  Future<bool> signInWithEmail(
    String email,
    String password,
    ProfileProvider profileProvider,
  ) async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithEmail(email, password);
      if (_user != null) {
        await profileProvider.loadProfile(_user!.uid);
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerWithEmail(
    String email,
    String password,
    ProfileProvider profileProvider,
    Profile registProfile,
  ) async {
    _setLoading(true);
    try {
      _user = await _authService.registerWithEmail(
        email,
        password,
        registProfile,
      );
      if (_user != null) {
        await profileProvider.loadProfile(_user!.uid);
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithGoogle();
      _errorMessage = null;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
