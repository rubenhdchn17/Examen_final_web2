class Review {
  final int id;
  final String contenido;
  final int calificacion;
  final int idUsuario;
  final int idSitio;

  Review({
    required this.id,
    required this.contenido,
    required this.calificacion,
    required this.idUsuario,
    required this.idSitio,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      contenido: json['contenido'],
      calificacion: json['calificacion'],
      idUsuario: json['idUsuario'],
      idSitio: json['idSitio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
    'id': id,
    'contenido': contenido,
    'calificacion': calificacion,
    'idUsuario': idUsuario,
    'idSitio': idSitio,
    };
  }
}

