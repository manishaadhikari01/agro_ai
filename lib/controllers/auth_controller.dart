import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';

class AuthController with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;

  bool _otpVerified = false;
  String? _verifiedPhone;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isOtpVerified => _otpVerified;
  String? get verifiedPhone => _verifiedPhone;

  bool isOtpVerifiedFor(String phone) {
    return _otpVerified && _verifiedPhone == phone;
  }

  // ---------------- AUTH STATE ----------------

  /// Check auth state from stored JWT
  Future<void> checkAuthStatus() async {
    final token = await TokenService.getAccessToken();
    _isLoggedIn = token != null;
    notifyListeners();
  }

  // ---------------- LOGIN ----------------
  /// Login user
  Future<bool> loginUser({
    String? phone,
    String? email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.login(
        phone: phone,
        email: email,
        password: password,
      );

      if (!success) return false;

      // 🔐 VERIFY TOKEN EXISTS (REAL AUTH)
      final token = await TokenService.getAccessToken();
      _isLoggedIn = token != null;

      return _isLoggedIn;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- OTP ----------------
  /// Send OTP to phone
  Future<bool> sendOtp({required String phone}) async {
    _otpVerified = false;
    _verifiedPhone = null;
    _isLoading = true;
    notifyListeners();

    try {
      final sent = await AuthService.sendOtp(phone: phone);
      return sent;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp({required String phone, required String otp}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final verified = await AuthService.verifyOtp(phone: phone, otp: otp);
      if (verified) {
        _otpVerified = true;
        _verifiedPhone = phone;
      }
      return verified;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🆕 Register user
  Future<bool> registerUser({
    required String name,
    required String phone,
    String? email,
    required String password,
    String? state,
    String? district,
    String? crops,
    String? farmerType,
  }) async {
    if (!isOtpVerifiedFor(phone)) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        state: state,
        district: district ?? 'unknown',
        crops: crops,
        farmerType: farmerType,
      );

      if (!success) return false;

      // 🔐 Only logged in if token exists
      final token = await TokenService.getAccessToken();
      _isLoggedIn = token != null;

      return _isLoggedIn;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- LOGOUT ----------------

  Future<void> logout() async {
    await TokenService.clear(); // ✅ CRITICAL
    _isLoggedIn = false;
    _otpVerified = false;
    _verifiedPhone = null;
    notifyListeners();
  }
}
