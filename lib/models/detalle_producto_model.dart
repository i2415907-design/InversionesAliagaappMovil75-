class DetalleProducto {
  final String nombre;
  final String imagen;
  final int cantidad;
  final String precio;

  DetalleProducto({
    required this.nombre,
    required this.imagen,
    required this.cantidad,
    required this.precio,
  });

  factory DetalleProducto.fromJson(Map<String, dynamic> json) {
    return DetalleProducto(
      nombre: json['producto']['nombre_producto'] ?? 'Producto sin nombre',
      imagen: json['producto']['url_imagen'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      precio: json['precio_unitario']?.toString() ?? '0.00',
    );
  }
}


