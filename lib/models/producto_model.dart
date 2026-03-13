import 'categoria_model.dart';

class ProductoModel {
  final int idProducto;
  final String nombreProducto;
  final String? descripcionProducto;
  final String? marca;
  final double precioProducto;
  final int? stockProducto;
  final String? imagen;
  final String? fechaRegistro;
  final int idCategoria;
  final String estadoProducto; 
  
  CategoriaModel? categoria;

  ProductoModel({
    required this.idProducto,
    required this.nombreProducto,
    this.descripcionProducto,
    this.marca,
    required this.precioProducto,
    this.stockProducto,
    this.imagen,
    this.fechaRegistro,
    required this.idCategoria,
    required this.estadoProducto,
    this.categoria,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      idProducto: json['id_producto'],
      nombreProducto: json['nombre_producto'],
      descripcionProducto: json['descripcion_producto'],
      marca: json['marca'],
      precioProducto: double.parse(json['precio_producto'].toString()),
      stockProducto: json['stock_producto'],
      imagen: json['imagen'],
      fechaRegistro: json['fecha_registro'],
      idCategoria: json['id_categoria'],
      estadoProducto: json['estado_producto'],
      categoria: json['categoria'] != null 
          ? CategoriaModel.fromJson(json['categoria']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_producto': idProducto,
      'nombre_producto': nombreProducto,
      'descripcion_producto': descripcionProducto,
      'marca': marca,
      'precio_producto': precioProducto,
      'stock_producto': stockProducto,
      'imagen': imagen,
      'fecha_registro': fechaRegistro,
      'id_categoria': idCategoria,
      'estado_producto': estadoProducto,
      'categoria': categoria?.toJson(),
    };
  }
}



