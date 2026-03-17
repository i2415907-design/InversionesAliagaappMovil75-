import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://inversionesaliaga.com/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'contrasena': password},
      );

      if (response.statusCode == 200) {
        final String? token = response.data['token'];
        final String? rol =
            response.data['usuario']['rol']; 

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          if (rol != null)
            await prefs.setString('user_role', rol); 
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      print("Error Dio: ${e.type} - ${e.message}");
      if (e.response != null) {
        print("Data error: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      print("Error general: $e");
      return false;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'name': name, 
          'email': email, 
          'password': password, 
          'password_confirmation': passwordConfirmation, 
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', response.data['token']);
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Error en registro: ${e.response?.data}");
      return false;
    }
  }
}


