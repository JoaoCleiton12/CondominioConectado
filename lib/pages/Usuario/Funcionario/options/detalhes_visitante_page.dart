import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class DetalhesVisitantePage extends StatefulWidget {
  final int visitanteId;
  final String nomeVisitante;

  const DetalhesVisitantePage({
    super.key,
    required this.visitanteId,
    required this.nomeVisitante,
  });

  @override
  State<DetalhesVisitantePage> createState() => _DetalhesVisitantePageState();
}

class _DetalhesVisitantePageState extends State<DetalhesVisitantePage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _visitas = [];

  // COR DO TEMA DO FUNCIONÁRIO (ROXO)
  final Color funcionarioThemeColor = const Color.fromARGB(255, 128, 0, 128); // ROXO

  @override
  void initState() {
    super.initState();
    _carregarVisitas();
  }

  Future<void> _carregarVisitas() async {
    try {
      final visitas = await dbHelper.buscarVisitasPorVisitante(widget.visitanteId);
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _visitas = visitas;
        });
      }
    } catch (e) {
      // Verifica se o widget ainda está montado antes de usar ScaffoldMessenger
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar visitas: $e')),
        );
      }
    }
  }

  Future<void> _confirmarPresenca(int visitaId) async {
    try {
      await dbHelper.registrarPresenca(visitaId);
      // _carregarVisitas() já tem sua própria verificação de 'mounted'
      _carregarVisitas(); // recarrega
      if (context.mounted) { // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presença confirmada!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar presença: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Visitas de ${widget.nomeVisitante}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: funcionarioThemeColor, // Aplicando a cor roxa
      ),
      body: _visitas.isEmpty
          ? const Center(child: Text('Nenhuma visita registrada.'))
          : ListView.builder(
              itemCount: _visitas.length,
              itemBuilder: (context, index) {
                final visita = _visitas[index];
                final presente = visita['presenca'] == 1;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adicionado margem
                  elevation: 4, // Adicionado elevação
                  child: ListTile(
                    leading: Icon(Icons.event, color: funcionarioThemeColor), // Ícone com a cor do tema
                    title: Text('Data: ${visita['data_visita']}'),
                    subtitle: Text(presente ? 'Presença: Confirmada' : 'Presença: Não confirmada'),
                    trailing: !presente
                        ? ElevatedButton(
                            onPressed: () => _confirmarPresenca(visita['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: funcionarioThemeColor, // Cor do botão com o tema
                              foregroundColor: Colors.white, // Texto branco
                            ),
                            child: const Text('Confirmar'),
                          )
                        : Icon(Icons.check_circle, color: Colors.green, size: 30), // Ícone de confirmado verde
                  ),
                );
              },
            ),
    );
  }
}