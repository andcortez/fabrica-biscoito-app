import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Pedido.dart';
import 'Usuario.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _selectedOption = 'Biscoito Simples';
  late double _input1;
  late double _input2;
  late double _input3;
  late String nomeUsuario;
  int _selectedIndex = 0;

  Future<Map<String, dynamic>> _getStock() async {
    final url = Uri.parse('http://192.168.0.167:8080/estoque');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get stock');
    }
  }

  void _sendData() async {
    var random = Random();
    int randomNum = random.nextInt(1000);
    final url = Uri.parse('http://192.168.0.167:8080/pedidos');
    final url2 = Uri.parse('http://192.168.0.167:8080/usuario');
    Usuario user = Usuario(nomeUsuario, randomNum);
    Pedido pedido =
        Pedido(_selectedOption, _input1, _input2, _input3, randomNum);

    // Busca os dados do estoque
    final stock = await _getStock();

    // Verifica se há ingredientes suficientes
    if (_input1 <= stock['ingrediente1'] &&
        _input2 <= stock['ingrediente2'] &&
        _input3 <= stock['ingrediente3']) {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(pedido.toJson()));
      final response2 = await http.post(url2,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(user.toJson()));

      if (response.statusCode == 200 && response2.statusCode == 200) {
        print('Dados enviados');
      } else {
        print('Falha');
      }
    } else {
      // Mostra uma mensagem de erro se não houver ingredientes suficientes
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text(
                'Não há ingredientes suficientes no estoque para fazer o pedido.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home2': (context) => MyApp2(),
        '/home3': (context) => MyApp3(),
        '/home': (context) => Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (BuildContext context) {
                      switch (settings.name) {
                        case '/tabela':
                          return TableScreen();
                        case '/grafico':
                          return ChartPage();
                        case '/estoque':
                          return StockScreen();
                        case '/estoque-view':
                          return StockScreenView();
                        default:
                          return Scaffold(
                            appBar: AppBar(
                              title: Text('Cliente Remoto'),
                            ),
                            body: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    DropdownButton<String>(
                                      items: [
                                        DropdownMenuItem<String>(
                                          child: Text('Biscoito Simples'),
                                          value: 'Biscoito Simples',
                                        ),
                                        DropdownMenuItem<String>(
                                          child: Text('Biscoito Recheado'),
                                          value: 'Biscoito Recheado',
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedOption = value!;
                                        });
                                      },
                                      hint: Text('Select an option'),
                                      value: _selectedOption,
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          nomeUsuario = value;
                                        });
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        labelText: 'Digite seu nome',
                                      ),
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _input1 =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Ingrediente 1',
                                      ),
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _input2 =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Ingrediente 2',
                                      ),
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _input3 =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Ingrediente 3',
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    ElevatedButton(
                                      style: style,
                                      onPressed: _sendData,
                                      child: const Text('Enviar Pedido'),
                                    ),
                                    ElevatedButton(
                                      child: Text(
                                        'Exibir Estoque',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/estoque');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            bottomNavigationBar: BottomNavigationBar(
                              items: const <BottomNavigationBarItem>[
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.cookie),
                                  label: 'Pedido',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.table_chart),
                                  label: 'Tabela',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.graphic_eq),
                                  label: 'Grafico',
                                ),
                              ],
                              currentIndex: _selectedIndex,
                              selectedItemColor: Colors.blue,
                              onTap: (index) {
                                setState(() {
                                  _selectedIndex = index;
                                  if (index == 0) {
                                    // Navega para a tela de Login
                                    Navigator.pushNamed(context, '/');
                                  } else if (index == 1) {
                                    Navigator.pushNamed(context, '/tabela');
                                  } else if (index == 2) {
                                    Navigator.pushNamed(context, '/grafico');
                                  }
                                });
                              },
                            ),
                          );
                      }
                    });
              },
            )
      },
    );
  }
}

class TableScreen extends StatefulWidget {
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<Pedido> pedidos = [];
  int linha = 1;

  Future<List<Pedido>> getPedidos() async {
    final url = Uri.parse('http://192.168.0.167:8080/pedidoprontotabela');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      List<Pedido> listaPedidos =
          List<Pedido>.from(data.map((x) => Pedido.fromJson(x)));
      pedidos.addAll(listaPedidos);
      return listaPedidos;
    } else {
      throw Exception("Falha ao carregar dados");
    }
  }

  List<Usuario> user = [];
  Future<List<Usuario>> getUsuario() async {
    final url = Uri.parse('http://192.168.0.167:8080/usuario');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      List<Usuario> usuarios =
          List<Usuario>.from(data.map((x) => Usuario.fromJson(x)));
      user.addAll(usuarios);
      return usuarios;
    } else {
      throw Exception("Falha ao carregar usuarios");
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        pedidos.clear();
        user.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabela de Pedidos'),
      ),
      body: FutureBuilder(
        future: Future.wait([getPedidos(), getUsuario()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return DataTable(
              columns: [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('ingredientes\n    usados\n      (KG)')),
                DataColumn(label: Text('Cliente')),
              ],
              rows: pedidos.map((pedido) {
                //int linhaAtual = linha;
                linha++;
                Usuario usuario = user.firstWhere((u) => u.ID == pedido.ID);
                return DataRow(cells: [
                  DataCell(Text(pedido.ID.toString())),
                  DataCell(Text(pedido.tipoDoPedido)),
                  DataCell(Text(pedido.somaIngredientes().toString())),
                  DataCell(Text(usuario.getNome())),
                ]);
              }).toList(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<Pedido> pedidos = [];
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getPedidos());
    getPedidos();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> getPedidos() async {
    final url = Uri.parse('http://192.168.0.167:8080/pedidoprontotabela');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      List<Pedido> listaPedidos =
          List<Pedido>.from(data.map((x) => Pedido.fromJson(x)));
      setState(() {
        pedidos = listaPedidos;
      });
    } else {
      throw Exception("Falha ao carregar dados");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico dos Pedidos'),
      ),
      body: pedidos == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: SfCartesianChart(
                legend: Legend(
                  isVisible: true,
                ),
                primaryXAxis: NumericAxis(
                  title: AxisTitle(text: 'Quantidade de pedidos'),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Soma dos ingredientes'),
                ),
                series: <ChartSeries>[
                  LineSeries<Pedido, int>(
                    name: 'Biscoitos',
                    dataSource: pedidos,
                    xValueMapper: (Pedido pedido, index) => index + 1,
                    yValueMapper: (Pedido pedido, _) =>
                        pedido.somaIngredientes(),
                    dataLabelMapper: (Pedido pedido, _) => pedido.tipoDoPedido,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                    ),
                    trendlines: <Trendline>[
                      Trendline(type: TrendlineType.linear, color: Colors.red)
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  void _login() async {
    final url = Uri.parse(
        'http://192.168.0.167:8080/usuarios?usuario=${_usernameController.text}&senha=${_passwordController.text}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final permissao = jsonDecode(response.body)['permissao'];
      if (permissao == 1) {
        // A permissão é 1, ir a=para a tela GERAL
        Navigator.pushNamed(context, '/home');
      } else if (permissao == 2) {
        // A permissão é 2, ir para a tela de SOMENTE envio de pedidos
        Navigator.pushNamed(context, '/home2');
      } else if (permissao == 3) {
        // A permissão é 2, ir para a tela de VISUALIZAÇÃO de pedidos
        Navigator.pushNamed(context, '/home3');
      } else {
        // Se a permissão não for 1, exibir mensagem de erro
        setState(() {
          _errorMessage = 'Usuário ou senha incorretos.';
        });
      }
    } else {
      // Erro na requisição, exibir mensagem de erro
      setState(() {
        _errorMessage =
            'Não foi possível realizar o login. Você não possui permissão';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nome de usuário',
                  labelStyle: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, informe o nome de usuário.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, informe a senha.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? true) {
                      _login();
                    }
                  },
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// TELA PARA QUEM POSSUI PERMISSAO '2' => SOMENTE ENVIO DE PEDIDOS
class MyApp2 extends StatefulWidget {
  @override
  _MyAppState2 createState() => _MyAppState2();
}

class _MyAppState2 extends State<MyApp2> {
  late String _selectedOption = 'Biscoito Simples';
  late double _input1;
  late double _input2;
  late double _input3;
  late String nomeUsuario;

  Future<Map<String, dynamic>> _getStock() async {
    final url = Uri.parse('http://192.168.0.167:8080/estoque');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get stock');
    }
  }

  void _sendData() async {
    try {
      final stock = await _getStock();
      final ingrediente1 = stock['ingrediente1'];
      final ingrediente2 = stock['ingrediente2'];
      final ingrediente3 = stock['ingrediente3'];

      if (_input1 > ingrediente1 ||
          _input2 > ingrediente2 ||
          _input3 > ingrediente3) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erro'),
              content: const Text(
                  'Não há ingredientes suficientes para processar seu pedido.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        var random = Random();
        int randomNum = random.nextInt(1000);
        final url = Uri.parse('http://192.168.0.167:8080/pedidos');
        final url2 = Uri.parse('http://192.168.0.167:8080/usuario');
        Usuario user = Usuario(nomeUsuario, randomNum);
        Pedido pedido =
            Pedido(_selectedOption, _input1, _input2, _input3, randomNum);
        final response = await http.post(url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(pedido.toJson()));
        final response2 = await http.post(url2,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(user.toJson()));

        if (response.statusCode == 200 && response2.statusCode == 200) {
          print('Data sent successfully');
        } else {
          print('Failed to send data');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (BuildContext context) {
                      switch (settings.name) {
                        case '/estoque':
                          return StockScreen();
                        default:
                          return Scaffold(
                            appBar: AppBar(
                              title: Text('Cliente Remoto'),
                            ),
                            body: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    DropdownButton<String>(
                                      items: [
                                        DropdownMenuItem<String>(
                                          child: Text('Biscoito Simples'),
                                          value: 'Biscoito Simples',
                                        ),
                                        DropdownMenuItem<String>(
                                          child: Text('Biscoito Recheado'),
                                          value: 'Biscoito Recheado',
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedOption = value!;
                                        });
                                      },
                                      hint: Text('Select an option'),
                                      value: _selectedOption,
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          nomeUsuario = value;
                                        });
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        labelText: 'Digite seu nome',
                                      ),
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _input1 =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Ingrediente 1',
                                      ),
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _input2 =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Ingrediente 2',
                                      ),
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _input3 =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Ingrediente 3',
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    ElevatedButton(
                                      style: style,
                                      onPressed: _sendData,
                                      child: const Text('Enviar Pedido'),
                                    ),
                                    ElevatedButton(
                                      child: Text(
                                        'Exibir Estoque',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/estoque');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                      }
                    });
              },
            )
      },
    );
  }
}

// TELA PARA QUEM POSSUI PERMISSAO '3' => SOMENTE EXIBIÇÃO DE DADOS
class MyApp3 extends StatefulWidget {
  @override
  _MyAppState3 createState() => _MyAppState3();
}

class _MyAppState3 extends State<MyApp3> {
  late String nomeUsuario;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(
                    settings: settings,
                    builder: (BuildContext context) {
                      switch (settings.name) {
                        case '/tabela':
                          return TableScreen();
                        case '/grafico':
                          return ChartPage();
                        case '/estoque-view':
                          return StockScreenView();
                        default:
                          return Scaffold(
                            appBar: AppBar(
                              title: Text('Visualização de Pedidos'),
                              backgroundColor: Colors.deepPurple,
                            ),
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(32.0),
                                  child: Text(
                                    'Escolha entre exibir a tabela, gráfico ou estoque da produção de pedidos',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                    child: Text(
                                      'Exibir Tabela',
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/tabela');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 32.0, vertical: 16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                    child: Text(
                                      'Exibir Gráfico',
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/grafico');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 32.0, vertical: 16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                    child: Text(
                                      'Exibir Estoque',
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/estoque-view');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 32.0, vertical: 16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                      }
                    });
              },
            )
      },
    );
  }
}

class StockScreen extends StatefulWidget {
  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  Future<Map<String, dynamic>>? _futureStock;
  Map<String, dynamic> _stock = {};

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _getStock().then((stock) {
        setState(() {
          _futureStock = Future.value(stock);
        });
      }).catchError((error) {
        print(error);
      });
    });
  }

  Future<Map<String, dynamic>> _getStock() async {
    final url = Uri.parse('http://192.168.0.167:8080/estoque');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get stock');
    }
  }

  Future<void> _sendStock() async {
    final url = Uri.parse('http://192.168.0.167:8080/estoque');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(_stock),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Estoque atualizado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro ao atualizar estoque'),
          content: Text('Tente novamente mais tarde.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estoque'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureStock,
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            final stock = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Quantidade de Ingredientes em Estoque',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Ingrediente 1: ${stock["ingrediente1"]}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Ingrediente 2: ${stock["ingrediente2"]}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Ingrediente 3: ${stock["ingrediente3"]}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Repor Estoque:',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Ingrediente 1',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _stock['ingrediente1'] = int.tryParse(value) ?? 0;
                      },
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Ingrediente 2',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _stock['ingrediente2'] = int.tryParse(value) ?? 0;
                      },
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Ingrediente 3',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _stock['ingrediente3'] = int.tryParse(value) ?? 0;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _sendStock,
                      child: Text('Enviar'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao obter dados do estoque',
                style: TextStyle(fontSize: 24.0),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class StockScreenView extends StatefulWidget {
  @override
  _StockScreenView createState() => _StockScreenView();
}

class _StockScreenView extends State<StockScreenView> {
  Future<Map<String, dynamic>>? _futureStock;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _getStock().then((stock) {
        setState(() {
          _futureStock = Future.value(stock);
        });
      }).catchError((error) {
        print(error);
      });
    });
  }

  Future<Map<String, dynamic>> _getStock() async {
    final url = Uri.parse('http://192.168.0.167:8080/estoque');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get stock');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estoque'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureStock,
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            final stock = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Quantidade de Ingredientes em Estoque',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Ingrediente 1: ${stock["ingrediente1"]}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Ingrediente 2: ${stock["ingrediente2"]}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Ingrediente 3: ${stock["ingrediente3"]}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao obter dados do estoque',
                style: TextStyle(fontSize: 24.0),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
