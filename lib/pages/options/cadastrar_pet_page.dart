import 'package:condomonioconectado/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastrarPetPage extends StatefulWidget {
  const CadastrarPetPage({super.key});

  @override
  State<CadastrarPetPage> createState() => _CadastrarPetPageState();
}

class _CadastrarPetPageState extends State<CadastrarPetPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _casaController = TextEditingController();


  // #TODO cadastrar Pet function
  void _cadastrarPet() async {
  if (_formKey.currentState!.validate()) {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id');

    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.'))
      );
      return;
    }

    final nome = _nomeController.text;
    final casa = _casaController.text;

    final dbHelper = DatabaseHelper();

    await dbHelper.inserirPet(nome, casa, usuarioId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet cadastrado com sucesso!'))
    );

    _nomeController.clear();
    _casaController.clear();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Pet'),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Pet'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo nome vazio' : null,
              ),
              TextFormField(
                controller: _casaController,
                decoration: const InputDecoration(labelText: 'Casa'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo casa vazio' : null,
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _cadastrarPet,
                icon: const Icon(Icons.add),
                label: const Text("Cadastrar Pet"),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final usuarioId = prefs.getInt('usuario_id');

                  if (usuarioId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuário não autenticado.'))
                    );
                    return;
                  }

                  final dbHelper = DatabaseHelper();
                  final pets = await dbHelper.buscarPetsDoUsuario(usuarioId);

                  if (pets.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Seus pets'),
                        content: const Text('Nenhum pet cadastrado.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Seus pets'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: pets.map((pet) {
                            return ListTile(
                              leading: const Icon(Icons.pets),
                              title: Text(pet['nome']),
                              subtitle: Text('Casa: ${pet['casa']}'),
                            );
                          }).toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.pets),
                label: const Text('Listar seus pets'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


