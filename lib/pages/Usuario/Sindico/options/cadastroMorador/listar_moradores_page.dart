import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class ListarMoradoresPage extends StatefulWidget {
  const ListarMoradoresPage({super.key});

  @override
  State<ListarMoradoresPage> createState() => _ListarMoradoresPageState();
}

class _ListarMoradoresPageState extends State<ListarMoradoresPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _moradores = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarMoradores();
  }

  Future<void> _carregarMoradores() async {
    try {
      final moradores = await dbHelper.buscarTodosMoradores();
      setState(() {
        _moradores = moradores;
        _carregando = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar moradores: $e')),
      );
      setState(() => _carregando = false);
    }
  }

  void _confirmarExcluirMorador(int usuarioId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este morador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await dbHelper.deletarMorador(usuarioId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Morador excluído com sucesso!')),
        );
        _carregarMoradores();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir morador: $e')),
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
            'Moradores Cadastrados',
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
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _moradores.isEmpty
              ? const Center(child: Text('Nenhum morador encontrado.'))
              : ListView.builder(
                  itemCount: _moradores.length,
                  itemBuilder: (context, index) {
                    final m = _moradores[index];
                    return ListTile(
                      title: Text(m['nome']),
                      subtitle: Text('Casa: ${m['casa']} | E-mail: ${m['email']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir morador',
                        onPressed: () {
  final usuarioId = m['usuario_id'];
  if (usuarioId != null) {
    _confirmarExcluirMorador(usuarioId);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro: ID do morador inválido')),
    );
  }
},

                      ),
                    );
                  },
                ),
    );
  }
}
