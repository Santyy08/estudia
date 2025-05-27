class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String? fotoPerfil;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoPerfil,
  });

  Usuario copyWith({
    String? id,
    String? nombre,
    String? email,
    String? fotoPerfil,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
    );
  }
}
