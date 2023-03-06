import 'Ingredientes.dart';

class Pedido {
  late String tipoPedido;
  late Ingredientes ingrediente;
  late int ID;

  Pedido(this.tipoPedido, double a, double b, double c, this.ID) {
    ingrediente = Ingredientes(a, b, c);
  }

  String get tipoDoPedido => tipoPedido;

  double get ingrediente1 => ingrediente.qntDeIngrediente1;
  double get ingrediente2 => ingrediente.qntDeIngrediente2;
  double get ingrediente3 => ingrediente.qntDeIngrediente3;

  int get identification => ID;

  double somaIngredientes() =>
      ingrediente.qntDeIngrediente1 +
      ingrediente.qntDeIngrediente2 +
      ingrediente.qntDeIngrediente3;

  Map<String, dynamic> toJson() => {
        'tipoPedido': tipoPedido,
        'ingrediente': ingrediente.toJson(),
        'ID': ID,
      };
  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
        json['tipoPedido'],
        json['ingrediente']['qntIngrediente1'],
        json['ingrediente']['qntIngrediente2'],
        json['ingrediente']['qntIngrediente3'],
        json['ID']);
  }
}
