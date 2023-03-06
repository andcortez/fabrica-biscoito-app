class Ingredientes {
  late double qntIngrediente1;
  late double qntIngrediente2;
  late double qntIngrediente3;

  Ingredientes(
      this.qntIngrediente1, this.qntIngrediente2, this.qntIngrediente3);

  double get qntDeIngrediente1 => qntIngrediente1;

  double get qntDeIngrediente2 => qntIngrediente2;

  double get qntDeIngrediente3 => qntIngrediente3;

  Map<String, dynamic> toJson() => {
        'qntIngrediente1': qntDeIngrediente1,
        'qntIngrediente2': qntDeIngrediente2,
        'qntIngrediente3': qntDeIngrediente3,
      };

  factory Ingredientes.fromJson(Map<String, dynamic> json) {
    return Ingredientes(
      json['qntIngrediente1'],
      json['qntIngrediente2'],
      json['qntIngrediente3'],
    );
  }
}
