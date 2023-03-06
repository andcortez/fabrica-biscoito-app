class Usuario {
  String nome;
  int ID;
  Usuario(this.nome, this.ID);

  String getNome() => nome;

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'ID': ID,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(json['nome'], json['ID']);
  }
}
