class CategoriaModel {
  final int idCategoria;
  final String nombreCat;
  final String? descripcionCat;

  CategoriaModel({
    required this.idCategoria,
    required this.nombreCat,
    this.descripcionCat,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      idCategoria: json['id_categoria'],
      nombreCat: json['nombre_cat'],
      descripcionCat: json['descripcion_cat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_categoria': idCategoria,
      'nombre_cat': nombreCat,
      'descripcion_cat': descripcionCat,
    };
  }
}