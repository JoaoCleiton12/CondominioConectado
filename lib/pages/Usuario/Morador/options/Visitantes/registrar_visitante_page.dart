import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class RegistrarVisitaPage extends StatefulWidget {
  const RegistrarVisitaPage({super.key});

  @override
  State<RegistrarVisitaPage> createState() => _RegistrarVisitaPageState();
}

class _RegistrarVisitaPageState extends State<RegistrarVisitaPage> {
  final dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _visitantes = [];
  Map<String, dynamic>? _visitanteSelecionado;
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarVisitantes();
  }

  Future<void> _carregarVisitantes() async {
    final prefs = await SharedPreferences.getInstance();
    final moradorId = prefs.getInt('usuario_id');
    if (moradorId == null) return;

    final lista = await dbHelper.buscarVisitantesDoMorador(moradorId);
    setState(() {
      _visitantes = lista;
    });
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  void _registrar() async {
    if (_visitanteSelecionado == null || _dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione visitante e data')),
      );
      return;
    }

    final visita = {
      'visitante_id': _visitanteSelecionado!['id'],
      'data_visita': _dataSelecionada!.toIso8601String().split('T').first,
    };

    try {
      await dbHelper.registrarVisita(visita);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita registrada com sucesso!')),
      );
      setState(() {
        _visitanteSelecionado = null;
        _dataSelecionada = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Visita'),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _visitanteSelecionado,
                items: _visitantes.map((v) {
                  return DropdownMenuItem(
                    value: v,
                    child: Text('${v['nome']} (idade: ${v['idade']})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _visitanteSelecionado = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Visitante'),
                validator: (value) =>
                    value == null ? 'Selecione um visitante' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: _dataSelecionada == null
                      ? 'Selecione a data da visita'
                      : 'Data: ${_dataSelecionada!.toLocal().toString().split(' ')[0]}',
                ),
                onTap: _selecionarData,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrar,
                child: const Text('Registrar Visita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
