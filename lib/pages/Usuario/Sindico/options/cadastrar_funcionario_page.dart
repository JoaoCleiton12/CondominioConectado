import 'package:condomonioconectado/database/database_helper.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/listar_funcionarios_page.dart';
import 'package:flutter/material.dart';

class CadastrarFuncionarioPage extends StatefulWidget {
  const CadastrarFuncionarioPage({super.key});

  @override
  State<CadastrarFuncionarioPage> createState() => _CadastrarFuncionarioPageState();
}

class _CadastrarFuncionarioPageState extends State<CadastrarFuncionarioPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String? _tipoFuncionarioSelecionado;
  bool _carregando = false;

  final dbHelper = DatabaseHelper();

  void _cadastrarFuncionario() async {
    if (!_formKey.currentState!.validate() || _tipoFuncionarioSelecionado == null) {
      if (_tipoFuncionarioSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o tipo de funcionário')),
        );
      }
      return;
    }

    setState(() => _carregando = true);

    final email = _emailController.text.trim();
    final emailJaExiste = await dbHelper.emailExiste(email);
    if (emailJaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail já cadastrado.')),
      );
      setState(() => _carregando = false);
      return;
    }

    final usuario = {
      'nome': _nomeController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'email': email,
      'senha': _senhaController.text.trim(),
      'tipo_usuario': 'funcionario',
      'token_recuperacao': null,
    };

    try {
      int usuarioId = await dbHelper.inserirUsuario(usuario);
      await dbHelper.inserirFuncionario(usuarioId, _tipoFuncionarioSelecionado!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionário cadastrado com sucesso!')),
      );

      _nomeController.clear();
      _telefoneController.clear();
      _emailController.clear();
      _senhaController.clear();
      setState(() {
        _tipoFuncionarioSelecionado = null;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Funcionário'),
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
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome';
                  }
                  if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
                    return 'Use apenas letras no nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o telefone';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Use apenas números no telefone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o e-mail';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a senha' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoFuncionarioSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo de Funcionário'),
                items: const [
                  DropdownMenuItem(value: 'porteiro', child: Text('Porteiro')),
                  DropdownMenuItem(value: 'zelador', child: Text('Zelador')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoFuncionarioSelecionado = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione o tipo de funcionário' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _carregando ? null : _cadastrarFuncionario,
                child: _carregando
                    ? const CircularProgressIndicator()
                    : const Text('Adicionar'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListarFuncionariosPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('Listar Funcionários'),
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
