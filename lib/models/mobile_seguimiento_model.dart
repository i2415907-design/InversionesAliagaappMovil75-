import 'pedido_model.dart'; 
import 'mobile_ubicacion_model.dart';

class MobileSeguimientoModel {
  final int seguimientoId;
  final int idPedido;
  final String codigoSeguimiento;
  final String estadoApp; 
  final double? latitud;
  final double? longitud;
  final String fechaActualizacion;
  
  // Relaciones
  PedidoModel? pedido;
  List<MobileUbicacionModel>? ubicaciones;

  MobileSeguimientoModel({
    required this.seguimientoId,
    required this.idPedido,
    required this.codigoSeguimiento,
    required this.estadoApp,
    this.latitud,
    this.longitud,
    required this.fechaActualizacion,
    this.pedido,
    this.ubicaciones,
  });

  factory MobileSeguimientoModel.fromJson(Map<String, dynamic> json) {
    List<MobileUbicacionModel>? ubicacionesList;
    if (json['ubicaciones'] != null) {
      var ubicacionesJson = json['ubicaciones'] as List;
      ubicacionesList = ubicacionesJson
          .map((u) => MobileUbicacionModel.fromJson(u))
          .toList();
    }

    return MobileSeguimientoModel(
      seguimientoId: json['seguimiento_id'],
      idPedido: json['id_pedido'],
      codigoSeguimiento: json['codigo_seguimiento'],
      estadoApp: json['estado_app'] ?? 'preparando',
      latitud: json['latitud'] != null 
          ? double.parse(json['latitud'].toString()) 
          : null,
      longitud: json['longitud'] != null 
          ? double.parse(json['longitud'].toString()) 
          : null,
      fechaActualizacion: json['fecha_actualizacion'],
      
      pedido: json['pedido'] != null 
          ? PedidoModel.fromJson(json['pedido']) 
          : null,
      ubicaciones: ubicacionesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seguimiento_id': seguimientoId,
      'id_pedido': idPedido,
      'codigo_seguimiento': codigoSeguimiento,
      'estado_app': estadoApp,
      'latitud': latitud,
      'longitud': longitud,
      'fecha_actualizacion': fechaActualizacion,
      'pedido': pedido?.toJson(),
      'ubicaciones': ubicaciones?.map((u) => u.toJson()).toList(),
    };
  }
}