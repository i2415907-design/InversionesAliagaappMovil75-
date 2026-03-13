class ClienteModel {
  final int idCliente;
  final int docIdent;
  final String nombreCliente;
  final String apellidoCliente;
  final String? emailCliente;
  final String? telefonoCliente;
  final String? direccionCliente;
  final String? fechaRegistro;

  ClienteModel({
    required this.idCliente,
    required this.docIdent,
    required this.nombreCliente,
    required this.apellidoCliente,
    this.emailCliente,
    this.telefonoCliente,
    this.direccionCliente,
    this.fechaRegistro,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      idCliente: json['id_cliente'],
      docIdent: json['doc_ident'],
      nombreCliente: json['nombre_cliente'],
      apellidoCliente: json['apellido_cliente'],
      emailCliente: json['email_cliente'],
      telefonoCliente: json['telefono_cliente'],
      direccionCliente: json['direccion_cliente'],
      fechaRegistro: json['fecha_registro'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cliente': idCliente,
      'doc_ident': docIdent,
      'nombre_cliente': nombreCliente,
      'apellido_cliente': apellidoCliente,
      'email_cliente': emailCliente,
      'telefono_cliente': telefonoCliente,
      'direccion_cliente': direccionCliente,
      'fecha_registro': fechaRegistro,
    };
  }
}


