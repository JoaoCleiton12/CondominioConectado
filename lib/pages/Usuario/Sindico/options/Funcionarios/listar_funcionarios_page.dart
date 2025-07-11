import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class ListarFuncionariosPage extends StatefulWidget {
  const ListarFuncionariosPage({super.key});

  @override
  State<ListarFuncionariosPage> createState() => _ListarFuncionariosPageState();
}

class _ListarFuncionariosPageState extends State<ListarFuncionariosPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _funcionarios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFuncionarios();
  }

  Future<void> _carregarFuncionarios() async {
    try {
      final funcionarios = await dbHelper.buscarTodosFuncionarios();
      setState(() {
        _funcionarios = funcionarios;
        _carregando = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar funcionários: $e')),
      );
      setState(() => _carregando = false);
    }
  }

  void _confirmarExcluirFuncionario(int usuarioId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este funcionário?'),
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
        await dbHelper.deletarFuncionario(usuarioId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionário excluído com sucesso!')),
        );
        _carregarFuncionarios();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir funcionário: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionários Cadastrados'),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _funcionarios.isEmpty
              ? const Center(child: Text('Nenhum funcionário encontrado.'))
              : ListView.builder(
                  itemCount: _funcionarios.length,
                  itemBuilder: (context, index) {
                    final f = _funcionarios[index];
                    return ListTile(
                      title: Text(f['nome']),
                      subtitle: Text('Cargo: ${f['cargo']} | E-mail: ${f['email']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir funcionário',
                        onPressed: () {
                          final usuarioId = f['usuario_id'];
                          if (usuarioId != null) {
                            _confirmarExcluirFuncionario(usuarioId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Erro: ID inválido')),
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
