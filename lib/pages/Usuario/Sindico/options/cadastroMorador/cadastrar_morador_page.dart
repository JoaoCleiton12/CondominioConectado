import 'package:condomonioconectado/database/database_helper.dart';
import 'package:flutter/material.dart';
// import 'package:condomonioconectado/pages/Usuario/Sindico/options/cadastroMorador/listar_moradores_page.dart'; // REMOVA esta importação, pois a página será incorporada

class CadastrarMoradorPage extends StatefulWidget {
  const CadastrarMoradorPage({super.key});

  @override
  State<CadastrarMoradorPage> createState() => _CadastrarMoradorPageState();
}

class _CadastrarMoradorPageState extends State<CadastrarMoradorPage> with SingleTickerProviderStateMixin {
  // --- Variáveis e Controladores para a Aba de Cadastro ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _casaController = TextEditingController();
  bool _carregandoCadastro = false;
  
  // --- Variáveis para o Gerenciamento de Abas e Listagem ---
  late TabController _tabController;
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _moradores = [];
  bool _carregandoLista = true;

  // COR DO TEMA DO SÍNDICO
  final Color sindicoThemeColor = const Color.fromARGB(255, 34, 139, 34); // VERDE

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _carregarMoradores();
      }
    });

    _carregarMoradores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _casaController.dispose();
    super.dispose();
  }

  void _cadastrarMorador() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregandoCadastro = true);

    final email = _emailController.text.trim();

    final emailJaExiste = await dbHelper.emailExiste(email);
    if (emailJaExiste) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail já cadastrado.')),
        );
      }
      setState(() => _carregandoCadastro = false);
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Morador cadastrado com sucesso!')),
        );
      }

      _nomeController.clear();
      _telefoneController.clear();
      _emailController.clear();
      _senhaController.clear();
      _casaController.clear();

      _tabController.animateTo(1);
      _carregarMoradores();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: $e')),
        );
      }
    } finally {
      setState(() => _carregandoCadastro = false);
    }
  }

  Future<void> _carregarMoradores() async {
    setState(() {
      _carregandoLista = true;
    });
    try {
      final moradores = await dbHelper.buscarTodosMoradores();
      setState(() {
        _moradores = moradores;
        _carregandoLista = false;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar moradores: $e')),
        );
      }
      setState(() => _carregandoLista = false);
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Morador excluído com sucesso!')),
          );
        }
        _carregarMoradores();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir morador: $e')),
          );
        }
      }
    }
  }

  Widget _buildCadastrarMoradorForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(color: sindicoThemeColor), // Corrigido
              ),
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
              decoration: InputDecoration(
                labelText: 'Telefone',
                labelStyle: TextStyle(color: sindicoThemeColor), // Corrigido
              ),
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
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: sindicoThemeColor), // Corrigido
              ),
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
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: sindicoThemeColor), // Corrigido
              ),
              obscureText: true,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Informe a senha' : null,
            ),
            TextFormField(
              controller: _casaController,
              decoration: InputDecoration(
                labelText: 'Casa',
                labelStyle: TextStyle(color: sindicoThemeColor), // Corrigido
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Informe a casa' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregandoCadastro ? null : _cadastrarMorador,
              style: ElevatedButton.styleFrom(
                backgroundColor: sindicoThemeColor, // Corrigido
              ),
              child: _carregandoCadastro
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Cadastrar',
                      style: TextStyle(
                          color: Colors.white, // Texto do botão branco
                          fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListarMoradores() {
    return _carregandoLista
        ? const Center(child: CircularProgressIndicator())
        : _moradores.isEmpty
            ? const Center(child: Text('Nenhum morador encontrado.'))
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _moradores.length,
                itemBuilder: (context, index) {
                  final m = _moradores[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(Icons.person, color: sindicoThemeColor), // Corrigido
                      title: Text(m['nome']),
                      subtitle: Text('Casa: ${m['casa']} | E-mail: ${m['email']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir morador',
                        onPressed: () {
                          final usuarioId = m['id'];
                          if (usuarioId != null) {
                            _confirmarExcluirMorador(usuarioId);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Erro: ID do morador inválido')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Gerenciar Moradores',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: sindicoThemeColor, // Corrigido
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cadastrar Morador', icon: Icon(Icons.person_add)),
            Tab(text: 'Listar Moradores', icon: Icon(Icons.list)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: false,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCadastrarMoradorForm(),
          _buildListarMoradores(),
        ],
      ),
    );
  }
}