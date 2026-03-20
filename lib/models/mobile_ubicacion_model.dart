class MobileUbicacionModel {
  final int ubicacionId;
  final int seguimientoId;
  final double latitud;
  final double longitud;
  final String fechaUbicacion;

  MobileUbicacionModel({
    required this.ubicacionId,
    required this.seguimientoId,
    required this.latitud,
    required this.longitud,
    required this.fechaUbicacion,
  });

  factory MobileUbicacionModel.fromJson(Map<String, dynamic> json) {
    return MobileUbicacionModel(
      ubicacionId: json['ubicacion_id'],
      seguimientoId: json['seguimiento_id'],
      latitud: double.parse(json['latitud'].toString()),
      longitud: double.parse(json['longitud'].toString()),
      fechaUbicacion: json['fecha_ubicacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ubicacion_id': ubicacionId,
      'seguimiento_id': seguimientoId,
      'latitud': latitud,
      'longitud': longitud,
      'fecha_ubicacion': fechaUbicacion,
    };
  }
}