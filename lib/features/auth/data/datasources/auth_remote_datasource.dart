import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// DataSource remoto para autenticación
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String fullName, String email, String password, String? phone);
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        final token = response['data']['token'] as String;
        final user = UserModel.fromJson(response['data']['user']);

        // Guardar token
        await sharedPreferences.setString('auth_token', token);
        apiClient.setToken(token);

        return user;
      } else {
        throw ServerException(response['message'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<UserModel> register(
      String fullName,
      String email,
      String password,
      String? phone,
      ) async {
    try {
      final response = await apiClient.post('/auth/register', {
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      });

      if (response['success'] == true) {
        final token = response['data']['token'] as String;
        final user = UserModel.fromJson(response['data']['user']);

        // Guardar token
        await sharedPreferences.setString('auth_token', token);
        apiClient.setToken(token);

        return user;
      } else {
        throw ServerException(response['message'] ?? 'Error al registrar');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get('/auth/profile');

      if (response['success'] == true) {
        return UserModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] ?? 'Error al obtener perfil');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }
}