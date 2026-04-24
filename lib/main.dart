import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: SplashScreen(),
    );
  }
}



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  TextEditingController controller = TextEditingController();

  late AnimationController _controllerAnim;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controllerAnim = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controllerAnim, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controllerAnim, curve: Curves.easeOutBack),
    );

    _controllerAnim.forward();
  }

  @override
  void dispose() {
    _controllerAnim.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: AnimatedBuilder(
        animation: _controllerAnim,
        builder: (context, child) {
          return Opacity(
            opacity: _fade.value,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          );
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Quiz de Matemática",
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),

                SizedBox(height: 20),

                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Digite seu nome",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPage(nome: controller.text),
                      ),
                    );
                  },
                  child: Text("Começar"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class QuizPage extends StatefulWidget {
  final String nome;

  QuizPage({required this.nome});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List perguntas = [];
  int index = 0;
  int pontos = 0;
  int? selecionada;
  bool respondeu = false;

  @override
  void initState() {
    super.initState();
    carregarJson();
  }

  Future<void> carregarJson() async {
    String data =
        await rootBundle.loadString('assets/mockup/perguntas.json');
    setState(() {
      perguntas = json.decode(data);
    });
  }

  void proxima() async {
    if (selecionada == null) return;

    setState(() {
      respondeu = true;
    });

    if (selecionada == perguntas[index]['correta']) {
      pontos++;
    }

    await Future.delayed(Duration(seconds: 1));

    if (index < perguntas.length - 1) {
      setState(() {
        index++;
        selecionada = null;
        respondeu = false;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultadoPage(
            nome: widget.nome,
            pontos: pontos,
            total: perguntas.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (perguntas.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var pergunta = perguntas[index];

    return Scaffold(
      appBar: AppBar(
        title: Text("Questão ${index + 1}"),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              pergunta['pergunta'],
              style: TextStyle(fontSize: 20),
            ),

            SizedBox(height: 20),

            ...List.generate(pergunta['respostas'].length, (i) {
              Color? cor;

              if (respondeu) {
                if (i == pergunta['correta']) {
                  cor = Colors.green;
                } else if (i == selecionada) {
                  cor = Colors.red;
                }
              }

              return Card(
                color: cor ?? Colors.pink[100],
                child: RadioListTile(
                  title: Text(pergunta['respostas'][i]),
                  value: i,
                  groupValue: selecionada,
                  onChanged: respondeu
                      ? null
                      : (value) {
                          setState(() {
                            selecionada = value as int;
                          });
                        },
                ),
              );
            }),

            Spacer(),

            ElevatedButton(
              onPressed: selecionada == null ? null : proxima,
              child: Text("Próxima"),
            )
          ],
        ),
      ),
    );
  }
}



class ResultadoPage extends StatelessWidget {
  final String nome;
  final int pontos;
  final int total;

  ResultadoPage({
    required this.nome,
    required this.pontos,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Parabéns, $nome!",
                style: TextStyle(fontSize: 24)),

            SizedBox(height: 20),

            Text(
              "Você acertou $pontos de $total",
              style: TextStyle(fontSize: 20),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SplashScreen()),
                  (route) => false,
                );
              },
              child: Text("Voltar"),
            )
          ],
        ),
      ),
    );
  }
}