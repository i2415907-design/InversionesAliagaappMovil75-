import 'package:dio/dio.dart';

class NotificacionService {
  final Dio _dio = Dio();
  final String baseUrl = "https://inversionesaliaga.com/v1";

  Future<List<dynamic>> getNotificaciones(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/notificaciones',
        queryParameters: {'token': token},
      );

      if (response.statusCode == 200 && response.data['res'] == true) {
        return response.data['datos']; // Retorna la lista de notificaciones
      }
      return [];
    } catch (e) {
      print("Error cargando notificaciones: $e");
      return [];
    }
  }

  Future<bool> marcarComoLeida(int idNotificacion) async {
    try {
      // Nota: Aquí no necesitamos el token porque el ID es único, 
      // pero si tu middleware api.key lo pide, agrégalo en queryParameters.
      final response = await _dio.post(
        '$baseUrl/notificaciones/leer',
        data: {'id_notificacion': idNotificacion},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}