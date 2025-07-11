import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class ListarVisitantesPage extends StatefulWidget {
  const ListarVisitantesPage({super.key});

  @override
  State<ListarVisitantesPage> createState() => _ListarVisitantesPageState();
}

class _ListarVisitantesPageState extends State<ListarVisitantesPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _visitantes = [];

  @override
  void initState() {
    super.initState();
    _carregarVisitantes();
  }

  Future<void> _carregarVisitantes() async {
    try {
      final resultado = await dbHelper.buscarTodosVisitantesComMorador();
      setState(() {
        _visitantes = resultado;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar visitantes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitantes Cadastrados'),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      ),
      body: _visitantes.isEmpty
          ? const Center(child: Text('Nenhum visitante cadastrado.'))
          : ListView.builder(
              itemCount: _visitantes.length,
              itemBuilder: (context, index) {
                final visitante = _visitantes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(visitante['nome_visitante']),
                    subtitle: Text('Idade: ${visitante['idade']} | Morador: ${visitante['nome_morador']}'),
                  ),
                );
              },
            ),
    );
  }
}
