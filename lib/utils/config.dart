class Config {
  // Backend API Configuration
  static const String baseUrl =
      'http://10.0.2.2:8000'; // Replace with actual backend URL
  //'http://192.168.1.5:8000';

  static const String apiKey =
      'your-api-key'; // Replace with actual API key if needed

  // Authentication Endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String forgotPasswordEndpoint = '$baseUrl/auth/forgot-password';
  static const String userDataEndpoint = '$baseUrl/user/data';

  // Other API Endpoints
  static const String chatbotEndpoint = '$baseUrl/chat';
  static const String weatherEndpoint = '$baseUrl/weather';
  static const String cropInfoEndpoint = '$baseUrl/crops';

  // App Constants
  static const String appName = 'DeepShiva';
  static const int passwordMinLength = 6;
}
