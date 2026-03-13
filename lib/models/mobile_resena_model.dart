import 'cliente_model.dart';
import 'pedido_model.dart'; 

class MobileResenaModel {
  final int resenaId;
  final int idPedido;
  final int idCliente;
  final int? calificacion; 
  final String? comentario;
  final String? imagenUrl;
  final String fechaCreacion;
  final int moderada; 
  
  PedidoModel? pedido;
  ClienteModel? cliente;

  MobileResenaModel({
    required this.resenaId,
    required this.idPedido,
    required this.idCliente,
    this.calificacion,
    this.comentario,
    this.imagenUrl,
    required this.fechaCreacion,
    required this.moderada,
    this.pedido,
    this.cliente,
  });

  factory MobileResenaModel.fromJson(Map<String, dynamic> json) {
    return MobileResenaModel(
      resenaId: json['resena_id'],
      idPedido: json['id_pedido'],
      idCliente: json['id_cliente'],
      calificacion: json['calificacion'],
      comentario: json['comentario'],
      imagenUrl: json['imagen_url'],
      fechaCreacion: json['fecha_creacion'],
      moderada: json['moderada'] ?? 0,
      
      pedido: json['pedido'] != null 
          ? PedidoModel.fromJson(json['pedido']) 
          : null,
      cliente: json['cliente'] != null 
          ? ClienteModel.fromJson(json['cliente']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resena_id': resenaId,
      'id_pedido': idPedido,
      'id_cliente': idCliente,
      'calificacion': calificacion,
      'comentario': comentario,
      'imagen_url': imagenUrl,
      'fecha_creacion': fechaCreacion,
      'moderada': moderada,
      'pedido': pedido?.toJson(),
      'cliente': cliente?.toJson(),
    };
  }
}