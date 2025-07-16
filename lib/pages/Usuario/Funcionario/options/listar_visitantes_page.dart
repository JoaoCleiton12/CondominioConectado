import 'package:condomonioconectado/pages/Usuario/Funcionario/options/detalhes_visitante_page.dart';
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

  // COR DO TEMA DO FUNCIONÁRIO (ROXO)
  final Color funcionarioThemeColor = const Color.fromARGB(255, 128, 0, 128); // ROXO

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
      if (context.mounted) { // Garante que o contexto ainda está montado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar visitantes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Visitantes Cadastrados',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: funcionarioThemeColor, // Aplicando a cor roxa
      ),
      body: _visitantes.isEmpty
          ? const Center(child: Text('Nenhum visitante cadastrado.'))
          : ListView.builder(
              itemCount: _visitantes.length,
              itemBuilder: (context, index) {
                final visitante = _visitantes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4, // Adicionado elevação ao Card para um visual melhor
                  child: ListTile(
                    leading: Icon(Icons.person, color: funcionarioThemeColor), // Ícone com a cor do tema
                    title: Text(visitante['nome_visitante']),
                    subtitle: Text('Idade: ${visitante['idade']} | Morador: ${visitante['nome_morador']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalhesVisitantePage(
                            visitanteId: visitante['id'],
                            nomeVisitante: visitante['nome_visitante'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}