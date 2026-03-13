import 'package:dio/dio.dart';
import '../models/pedido_model.dart';
import '../models/distrito_model.dart';

class PedidoService {
  final Dio _dio = Dio();

  Future<List<PedidoModel>> getMisPedidos(String token) async {
    try {
      final response = await _dio.get(
        'https://inversionesaliaga.com/v1/mis-pedidos',
        queryParameters: {'token': token},
      );

      if (response.statusCode == 200) {
        List data = response.data['datos'];
        return data.map((json) => PedidoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error en PedidoService: $e");
      return [];
    }
  }

  Future<bool> updateUbicacion({
    required String token,
    required int idPedido,
    required int idDistrito,
    required String direccionCliente,
    required String referencia,
    required String codigoPostal,
  }) async {
    try {
      final response = await _dio.post(
        'https://inversionesaliaga.com/v1/actualizar-ubicacion',
        queryParameters: {'token': token},
        data: {
          'id_pedido': idPedido,
          'id_distrito': idDistrito,
          'direccion_cliente': direccionCliente,     
          'referencia': referencia,
          'codigo_postal': codigoPostal,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error al actualizar: $e");
      return false;
    }
  }

  Future<List<DistritoModel>> getDistritos(String token) async {
    try {
      final response = await _dio.get(
        'https://inversionesaliaga.com/v1/distritos',
        queryParameters: {'token': token},
      );
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => DistritoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error cargando distritos: $e");
      return [];
    }
  }
}


