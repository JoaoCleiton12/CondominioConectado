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
  final TextEditingController _idadeController = TextEditingController();

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
      final idade = _idadeController.text;

      final dbHelper = DatabaseHelper();

      await dbHelper.inserirPet(nome, idade, usuarioId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet cadastrado com sucesso!'))
      );

      _nomeController.clear();
      _idadeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: const Text(
            'Cadastrar Pet',
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
                controller: _idadeController,
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo idade vazio' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _cadastrarPet,
                child: const Text('Cadastrar Pet',
                style: TextStyle(color: Color.fromARGB(255, 61, 96, 178), fontWeight: FontWeight.bold,),
                ),
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
                              subtitle: Text('Idade: ${pet['idade']}'),
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
                icon: const Icon(Icons.list),
                label: const Text('Listar Pets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
