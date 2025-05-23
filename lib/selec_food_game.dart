import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart';

class GameSelectFoodScreen extends StatefulWidget {
  final int tempoInicial;
  final int quantidadeItens;
  const GameSelectFoodScreen({Key? key, required this.tempoInicial, required this.quantidadeItens}) : super(key: key);

  @override
  _GameSelectFoodScreenState createState() => _GameSelectFoodScreenState();
}

class _GameSelectFoodScreenState extends State<GameSelectFoodScreen> {
  late int tempoRestante;
  Timer? _timer;
  bool _telaFinalMostrada = false;

  final List<String> todosOsItens = [
    'pão', 'feijao', 'macarrao', 'leite',
    'cenoura', 'maçã', 'banana', 'café',
    'alface', 'carne', 'farinha', 'milho',
  ];

  late List<String> itensCorretos;
  late List<String> itensVisiveis;
  Set<String> itensNaCesta = {};

  @override
  void initState() {
    super.initState();
    tempoRestante = widget.tempoInicial;
    selecionarItensAleatorios();
    definirItensVisiveis();
    iniciarTemporizador();
  }

  void selecionarItensAleatorios() {
    todosOsItens.shuffle();
    itensCorretos = todosOsItens.take(widget.quantidadeItens).toList();
  }

  void definirItensVisiveis() {
    final List<String> itensRestantes = List.from(todosOsItens);

    // Remove os itens corretos da lista restante para evitar duplicação
    itensRestantes.removeWhere((item) => itensCorretos.contains(item));
    itensRestantes.shuffle();

    // Pegamos itens aleatórios adicionais para completar os 8
    List<String> extras = itensRestantes.take(8 - itensCorretos.length).toList();

    // Junta os corretos com os extras e embaralha
    itensVisiveis = [...itensCorretos, ...extras]..shuffle();
  }

  void iniciarTemporizador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tempoRestante--;
      });

      if (tempoRestante == 0) {
        _timer?.cancel();
        mostrarTelaFinal();
      }
    });
  }

  void _pauseGame() {
    _timer?.cancel();
  }

  void _resumeGame() {
    iniciarTemporizador();
  }

  void mostrarTelaFinal({String mensagem = "Tempo esgotado!"}) {
    if (_telaFinalMostrada) return;
    _telaFinalMostrada = true;
    _pauseGame();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              reiniciarJogo();
            },
            child: const Text("Jogar novamente"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Sair"),
          ),
        ],
      ),
    );
  }

  void reiniciarJogo() {
    setState(() {
      tempoRestante = widget.tempoInicial;
      _telaFinalMostrada = false;
      itensNaCesta.clear();
      selecionarItensAleatorios();
      definirItensVisiveis();
      iniciarTemporizador();
    });
  }

  String _getImagePath(String nome) {
    switch (nome) {
      case 'pão':
        return 'assets/images/jogoComidas/alimentos/Pão.png';
      case 'feijao':
        return 'assets/images/jogoComidas/alimentos/Feijão_enlatado.png';
      case 'macarrao':
        return 'assets/images/jogoComidas/alimentos/Macarrão.png';
      case 'leite':
        return 'assets/images/jogoComidas/alimentos/Leite.png';
      case 'cenoura':
        return 'assets/images/jogoComidas/alimentos/Cenoura.png';
      case 'maçã':
        return 'assets/images/jogoComidas/alimentos/Maçã.png';
      case 'banana':
        return 'assets/images/jogoComidas/alimentos/Banana.png';
      case 'café':
        return 'assets/images/jogoComidas/alimentos/Café.png';
      case 'alface':
        return 'assets/images/jogoComidas/alimentos/Alface.png';
      case 'carne':
        return 'assets/images/jogoComidas/alimentos/Carne.png';
      case 'farinha':
        return 'assets/images/jogoComidas/alimentos/Farinha.png';
      case 'milho':
        return 'assets/images/jogoComidas/alimentos/Milho_enlatado.png';
      default:
        return '';
    }
  }

  Widget _buildItem(String nome) {
    String caminho = _getImagePath(nome);

    return Draggable<String>(
      data: nome,
      feedback: Image.asset(caminho, width: 90, height: 90),
      childWhenDragging: Opacity(opacity: 0.5, child: Image.asset(caminho, width: 90, height: 90)),
      child: Image.asset(caminho, width: 90, height: 90),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> itensParaMostrar = itensVisiveis.where((item) => !itensNaCesta.contains(item)).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Fundo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/jogoComidas/Jogo 1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Itens corretos
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Wrap(
                  spacing: 25,
                  children: itensCorretos.map(
                        (item) => Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4C7A3),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: const Color(0xFF4F2E0D),
                          width: 4,
                        ),
                      ),
                      padding: const EdgeInsets.all(0), // menos padding para imagem maior
                      child: Image.asset(
                        _getImagePath(item),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),



          // Cesta
          Align(
            alignment: Alignment.bottomCenter,
            child: DragTarget<String>(
              onAccept: (item) {
                setState(() {
                  if (itensNaCesta.contains(item)) return;

                  itensNaCesta.add(item);

                  if (itensNaCesta.length == widget.quantidadeItens) {
                    final bool todosCorretos = itensNaCesta.every((item) => itensCorretos.contains(item));
                    if (todosCorretos) {
                      mostrarTelaFinal(mensagem: "Parabéns! Você acertou todos os itens!");
                    }
                  }
                });
              },
              onWillAccept: (item) => itensNaCesta.length < widget.quantidadeItens,
              builder: (context, candidateData, rejectedData) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  width: 350,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.7),
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (itensNaCesta.isEmpty)
                        const Text(
                          'Solte aqui!',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      Wrap(
                        children: itensNaCesta
                            .map((item) => GestureDetector(
                          onTap: () => setState(() => itensNaCesta.remove(item)),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              _getImagePath(item),
                              width: 70,
                              height: 70,
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Itens visíveis (para selecionar)
          Positioned(
            bottom: 125,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: itensParaMostrar.take(4).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildItem(item),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: itensParaMostrar.skip(4).take(4).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildItem(item),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // HUD - Tempo
          Positioned(
            top: -2.5,
            left: 10,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    // Contorno preto (borda)
                    Text(
                      'Tempo: $tempoRestante',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = Colors.black,
                      ),
                    ),
                    // Texto branco por cima
                    Text(
                      'Tempo: $tempoRestante',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),



          // Botão de sair
          Positioned(
            top: 35,
            right: -10,
            child: ElevatedButton(
              onPressed: () {
                _pauseGame();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Sair do Jogo'),
                      content: const Text('Você deseja voltar ao menu anterior?'),
                      actions: [
                        TextButton(
                          child: const Text('Não'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _resumeGame();
                          },
                        ),
                        TextButton(
                          child: const Text('Sim'),
                          onPressed: () {
                            Navigator.of(context).pop();
                              Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => TelaEscolherJogo()),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4C7A3),
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFF4F2E0D), width: 3),
                ),
              ),
              child: const Icon(Icons.close, color: Color(0xFF333333), size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
