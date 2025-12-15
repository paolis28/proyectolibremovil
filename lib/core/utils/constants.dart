/// Constantes de la aplicación
class AppConstants {
  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api', // Android emulator localhost
  );

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pagination
  static const int pageSize = 20;
}

/// Rutas de navegación
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String gymAreas = '/gym-areas';
  static const String gymAreaDetail = '/gym-areas/:id';
  static const String reservations = '/reservations';
  static const String profile = '/profile';
  static const String makeReservation = '/make-reservation';
}