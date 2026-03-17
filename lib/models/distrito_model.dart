class DistritoModel {
  final int id;
  final String nombre;

  DistritoModel({required this.id, required this.nombre});

  factory DistritoModel.fromJson(Map<String, dynamic> json) {
    return DistritoModel(
      id: json['id_distrito'],
      nombre: json['nombre_distr'],
    );
  }
}


