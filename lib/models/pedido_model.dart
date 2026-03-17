import 'package:rutasinversionesaliaga/models/detalle_producto_model.dart';
import 'package:rutasinversionesaliaga/models/cliente_model.dart';
import 'package:rutasinversionesaliaga/models/distrito_model.dart';

class PedidoModel {
  final int idPedido;
  final String estado;
  final String total;
  final String fecha;
  final List<DetalleProducto> detalles;
  
  final ClienteModel? cliente;
  final DistritoModel? distrito;

  int? tempIdDistrito;
  String? tempCodigoPostal;
  String? tempReferencia;
  String? tempDireccion;

  final String nombreEncargado; 
  final String? calificacion;
  final String? comentario;
  final String? fotoEvidencia;

  PedidoModel({
    required this.idPedido,
    required this.estado,
    required this.total,
    required this.fecha,
    required this.detalles,
    this.cliente,
    this.distrito,
    this.tempIdDistrito,
    this.tempCodigoPostal,
    this.tempReferencia,
    this.tempDireccion,
    this.nombreEncargado = 'No asignado', 
    this.calificacion ,
    this.comentario,
    this.fotoEvidencia,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    var listaDetalles = (json['venta'] != null && json['venta']['detalles'] != null)
        ? json['venta']['detalles'] as List
        : [];
    
    List<DetalleProducto> productos = listaDetalles
        .map((d) => DetalleProducto.fromJson(d))
        .toList();

    return PedidoModel(
      idPedido: json['id_pedido'],
      estado: json['estado_pedido'] ?? '',
      total: json['total_pedido'].toString(),
      fecha: json['fecha_pedido'] ?? '',
      detalles: productos,
      cliente: json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      distrito: json['distrito'] != null ? DistritoModel.fromJson(json['distrito']) : null,
      tempIdDistrito: json['id_distrito'],
      tempCodigoPostal: json['codigo_postal'],
      tempDireccion: json['direccion_auxiliar'] ?? json['direccion_cliente'] ?? 
                     (json['cliente'] != null ? json['cliente']['direccion_cliente'] : 'No hay dirección'),
      tempReferencia: json['referencia_ped'] ?? 'Sin referencia',
      nombreEncargado: json['nombre_encargado'] ?? 'Pendiente de asignar',
      calificacion: json['calificacion']?.toString() ?? '0',
      comentario: json['comentario'] ?? 'Sin comentarios del cliente',
      fotoEvidencia: json['foto_evidencia'] ?? '',
    );
  }
  toJson() {
    return {
      'id_pedido': idPedido,
      'calificacion': calificacion,
      'comentario': comentario,
      'foto_evidencia': fotoEvidencia,
    };
  }
}

