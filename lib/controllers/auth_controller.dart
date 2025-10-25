import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  // User Registration
  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? state,
    String? crops,
    String? farmerType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        state: state,
        crops: crops,
        farmerType: farmerType,
      );

      if (success) {
        // After successful registration, automatically log in the user
        final loginResult = await AuthService.loginUser(email, password);
        if (loginResult != null) {
          _currentUser = loginResult['user'];
          _authToken = loginResult['token'];
          _isLoggedIn = true;
        }
      }

      return success;
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // User Login
  Future<bool> loginUser(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.loginUser(phone, password);
      if (result != null) {
        _currentUser = result['user'];
        _authToken = result['token'];
        _isLoggedIn = true;
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.forgotPassword(email);
      return success;
    } catch (e) {
      print('Forgot password error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch User Data
  Future<bool> fetchUserData() async {
    if (_currentUser == null || _authToken == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.fetchUserData(
        _currentUser!.id,
        _authToken!,
      );
      if (user != null) {
        _currentUser = user;
        return true;
      }
      return false;
    } catch (e) {
      print('Fetch user data error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update User Data
  Future<bool> updateUserData(Map<String, dynamic> updates) async {
    if (_currentUser == null || _authToken == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.updateUserData(
        _currentUser!.id,
        _authToken!,
        updates,
      );
      if (success) {
        // Update local user data
        _currentUser = _currentUser!.copyWith(
          name: updates['name'],
          email: updates['email'],
          phone: updates['phone'],
          state: updates['state'],
          crops: updates['crops'],
          farmerType: updates['farmerType'],
        );
      }
      return success;
    } catch (e) {
      print('Update user data error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _authToken = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Check Authentication Status (e.g., on app start)
  void checkAuthStatus() {
    // This could check shared preferences or secure storage for saved tokens
    // For now, we'll assume no persistent login
    _isLoggedIn = false;
    notifyListeners();
  }
}
