import 'package:dio/dio.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';

class VendedorService {
  final Dio _dio = Dio();
  final String baseUrl = "https://inversionesaliaga.com/v1";

Future<List<PedidoModel>> getPedidosAsignados(String token) async {
  try {
    final response = await _dio.get('$baseUrl/vendedor/mis-pedidos', 
      queryParameters: {'token': token});
    
    // Verificamos si response.data es una lista
    if (response.data is List) {
      return (response.data as List)
          .map((p) => PedidoModel.fromJson(p))
          .toList();
    }
    return [];
  } catch (e) {
    print("Error en service: $e");
    return [];
  }
}

  Future<bool> iniciarRuta(String token, int idPedido) async {
    try {
      await _dio.post('$baseUrl/vendedor/iniciar-ruta', 
        queryParameters: {'token': token},
        data: {'id_pedido': idPedido});
      return true;
    } catch (e) {
      return false;
    }
  }

Future<bool> finalizarEntrega(String token, int idPedido, String imagePath) async {
  try {
    FormData formData = FormData.fromMap({
      "id_pedido": idPedido,
      "estado": "entregado",
    });

    if (imagePath.isNotEmpty) {
      formData.files.add(MapEntry(
        "foto_evidencia", 
        await MultipartFile.fromFile(imagePath),
      ));
    }

    final response = await _dio.post(
      '$baseUrl/vendedor/completar-pedido', 
      data: formData,
      queryParameters: {'token': token}, 
      options: Options(headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      }),
    );

    return response.statusCode == 200;
  } catch (e) {
    print("Error detallado en finalizarEntrega: $e");
    return false;
  }
}
  Future<bool> cancelarEntrega(String token, int idPedido, String motivo) async {
  try {
    await _dio.post('$baseUrl/vendedor/cancelar-entrega', 
      queryParameters: {'token': token},
      data: {
        'id_pedido': idPedido,
        'motivo': motivo,
        'nuevo_estado': 'pendiente' 
      }
    );
    return true;
  } catch (e) {
    return false;
  }
}
Future<List<PedidoModel>> getPedidosEntregados(String token) async {
  try {
    final response = await _dio.get('$baseUrl/vendedor/mis-entregas', 
      queryParameters: {'token': token});
    
    return (response.data as List)
        .map((p) => PedidoModel.fromJson(p))
        .toList();
  } catch (e) {
    return [];
  }
}
}


