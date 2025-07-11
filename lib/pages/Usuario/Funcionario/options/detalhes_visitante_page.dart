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

  @override
  void initState() {
    super.initState();
    _carregarVisitas();
  }

  Future<void> _carregarVisitas() async {
    try {
      final visitas = await dbHelper.buscarVisitasPorVisitante(widget.visitanteId);
      setState(() {
        _visitas = visitas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar visitas: $e')),
      );
    }
  }

  Future<void> _confirmarPresenca(int visitaId) async {
    try {
      await dbHelper.registrarPresenca(visitaId);
      _carregarVisitas(); // recarrega
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar presença: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         centerTitle: true,
        title: Text('Visitas de ${widget.nomeVisitante}', 
        textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
        ),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      ),
      body: _visitas.isEmpty
          ? const Center(child: Text('Nenhuma visita registrada.'))
          : ListView.builder(
              itemCount: _visitas.length,
              itemBuilder: (context, index) {
                final visita = _visitas[index];
                final presente = visita['presenca'] == 1;

                return Card(
                  child: ListTile(
                    title: Text('Data: ${visita['data_visita']}'),
                    subtitle: Text(presente ? 'Presença: Confirmada' : 'Presença: Não confirmada'),
                    trailing: !presente
                        ? ElevatedButton(
                            onPressed: () => _confirmarPresenca(visita['id']),
                            child: const Text('Confirmar'),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
