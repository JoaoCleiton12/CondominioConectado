import 'package:flutter/material.dart';

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
                onPressed: () {
                  print('<button pressed> Cadastrar seus pets');
                },
                icon: const Icon(Icons.add),
                label: const Text("Cadastrar Pet"),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  print('<button pressed> Listar seus pets');
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


