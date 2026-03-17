import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<dynamic>> getPedidosPorEstado(String estado) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/admin/pedidos', 
        queryParameters: {
          'estado': estado,
          'token': token, 
        },
      );

      if (response.statusCode == 200) {
        return response.data['datos'] ?? []; 
      }
      return [];
    } catch (e) {
      print("Error en AdminService (getPedidos): $e");
      return [];
    }
  }

Future<bool> actualizarEstadoPedido(int idPedido, String nuevoEstado) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    final response = await _dio.post(
      '/actualizar-estado-pedido', 
      data: {
        'id_pedido': idPedido,
        'estado': nuevoEstado,
      },
      queryParameters: {'token': token},
    );

    return response.statusCode == 200;
  } catch (e) {
    print("Error al actualizar estado: $e");
    return false;
  }
}

  Future<Map<String, dynamic>?> getResenaPedido(int pedidoId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/admin/pedidos/$pedidoId/resena',
        queryParameters: {'token': token}, 
      );

      if (response.statusCode == 200) {
        return response.data['datos'];
      }
      return null;
    } catch (e) {
      print("Error al obtener reseña: $e");
      return null;
    }
  }
}

