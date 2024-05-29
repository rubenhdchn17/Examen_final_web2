class Site {
  final int id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String ubicacion;
  final bool abierto;

  Site({required this.id, required this.nombre, required this.categoria, required this.descripcion, required this.ubicacion, required this.abierto});

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
        id: json['id'],
        nombre: json['nombre'],
        categoria: json['categoria'],
        descripcion: json['descripcion'],
        ubicacion: json['ubicacion'],
        abierto: json['abierto'],
    );
  }
}

