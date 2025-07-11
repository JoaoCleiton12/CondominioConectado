import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class CadastrarVisitantePage extends StatefulWidget {
  const CadastrarVisitantePage({super.key});

  @override
  State<CadastrarVisitantePage> createState() => _CadastrarVisitantePageState();
}

class _CadastrarVisitantePageState extends State<CadastrarVisitantePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final dbHelper = DatabaseHelper();

  Future<void> _cadastrarVisitante() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final moradorId = prefs.getInt('usuario_id');

    if (moradorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao identificar o morador logado.')),
      );
      return;
    }

    final visitante = {
      'nome': _nomeController.text.trim(),
      'idade': int.parse(_idadeController.text.trim()),
      'morador_id': moradorId,
    };

    try {
      await dbHelper.inserirVisitante(visitante);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitante cadastrado com sucesso!')),
      );
      _nomeController.clear();
      _idadeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: const Text(
            'Cadastrar Visitante',
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
                decoration: const InputDecoration(labelText: 'Nome do visitante'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a idade';
                  final idade = int.tryParse(value);
                  if (idade == null || idade <= 0) return 'Informe uma idade válida';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cadastrarVisitante,
                child: const Text('Cadastrar',
                style: TextStyle(color: Color.fromARGB(255, 61, 96, 178), fontWeight: FontWeight.bold,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
