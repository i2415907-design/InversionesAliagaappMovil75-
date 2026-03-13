class UsuarioModel {
  final int idUsuario;
  final String nombreUsuario;
  final String contrasena;
  final String? apiToken;
  final String rol; 
  final String? fechaRegistro;
  final String? email;
  final int activo; 

  UsuarioModel({
    required this.idUsuario,
    required this.nombreUsuario,
    required this.contrasena,
    this.apiToken,
    required this.rol,
    this.fechaRegistro,
    this.email,
    required this.activo,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'],
      contrasena: json['contrasena'],
      apiToken: json['api_token'],
      rol: json['rol'],
      fechaRegistro: json['fecha_registro'],
      email: json['email'],
      activo: json['activo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre_usuario': nombreUsuario,
      'contrasena': contrasena,
      'api_token': apiToken,
      'rol': rol,
      'fecha_registro': fechaRegistro,
      'email': email,
      'activo': activo,
    };
  }
}