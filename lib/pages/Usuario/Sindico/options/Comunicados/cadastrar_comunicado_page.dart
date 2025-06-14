import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class CadastrarComunicadoPage extends StatefulWidget {
  const CadastrarComunicadoPage({super.key});

  @override
  State<CadastrarComunicadoPage> createState() => _CadastrarComunicadoPageState();
}

class _CadastrarComunicadoPageState extends State<CadastrarComunicadoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  void _cadastrarComunicado() async {
    if (_formKey.currentState!.validate()) {
      final titulo = _tituloController.text;
      final descricao = _descricaoController.text;

      final dbHelper = DatabaseHelper();
      await dbHelper.inserirComunicado(titulo, descricao);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comunicado cadastrado com sucesso!')),
      );

      _tituloController.clear();
      _descricaoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Comunicado'),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _cadastrarComunicado,
                icon: const Icon(Icons.send),
                label: const Text('Publicar Comunicado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
