import 'package:dio/dio.dart';

class PerfilService {
  final Dio _dio = Dio();
  final String baseUrl = "https://inversionesaliaga.com/v1";

  Future<Map<String, dynamic>?> obtenerPerfil(String token) async {
    try {
      final response = await _dio.get('$baseUrl/perfil', 
        queryParameters: {'token': token});
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> cambiarPassword(String token, String actual, String nueva) async {
    try {
      final response = await _dio.post('$baseUrl/actualizar-password',
        queryParameters: {'token': token},
        data: {
          'password_actual': actual,
          'nueva_password': nueva,
        },
      );
      return {'success': true, 'mensaje': response.data['mensaje']};
    } on DioException catch (e) {
      return {
        'success': false, 
        'mensaje': e.response?.data['mensaje'] ?? 'Error al actualizar'
      };
    }
  }
}

