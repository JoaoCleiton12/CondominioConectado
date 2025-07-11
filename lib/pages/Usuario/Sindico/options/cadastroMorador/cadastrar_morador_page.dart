import 'package:condomonioconectado/database/database_helper.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/cadastroMorador/listar_moradores_page.dart';
import 'package:flutter/material.dart';

class CadastrarMoradorPage extends StatefulWidget {
  const CadastrarMoradorPage({super.key});

  @override
  State<CadastrarMoradorPage> createState() => _CadastrarMoradorPageState();
}

class _CadastrarMoradorPageState extends State<CadastrarMoradorPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _casaController = TextEditingController();

  bool _carregando = false;
  final dbHelper = DatabaseHelper();

  void _cadastrarMorador() async {
    if (!_formKey.currentState!.validate()) return;

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
      'tipo_usuario': 'morador',
      'token_recuperacao': null,
    };

    try {
      int usuarioId = await dbHelper.inserirUsuario(usuario);
      await dbHelper.inserirMorador(usuarioId, _casaController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Morador cadastrado com sucesso!')),
      );

      _nomeController.clear();
      _telefoneController.clear();
      _emailController.clear();
      _senhaController.clear();
      _casaController.clear();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _listarMoradores() async {
    try {
      final moradores = await dbHelper.buscarTodosMoradores();

      if (moradores.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Moradores'),
            content: const Text('Nenhum morador encontrado.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Moradores Cadastrados'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: moradores.length,
              itemBuilder: (context, index) {
                final m = moradores[index];
                return ListTile(
                  title: Text(m['nome']),
                  subtitle: Text('Casa: ${m['casa']} | E-mail: ${m['email']}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar moradores: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: const Text(
            'Cadastrar Morador',
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
              TextFormField(
                controller: _casaController,
                decoration: const InputDecoration(labelText: 'Casa'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a casa' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _carregando ? null : _cadastrarMorador,
                child: _carregando
                    ? const CircularProgressIndicator()
                    : const Text('Adicionar'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListarMoradoresPage()),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('Listar Moradores'),
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


