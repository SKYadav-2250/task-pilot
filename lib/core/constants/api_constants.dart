class ApiConstants {
  // Base URL for the backend API
  static const String baseUrl = 'https://flutter-task-backend.vercel.app/api';

  // Endpoint paths
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String tasksEndpoint = '/tasks';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String themeKey = 'theme_mode';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
}
