import 'package:condomonioconectado/database/database_helper.dart';
import 'package:flutter/material.dart';
// import 'package:condomonioconectado/pages/Usuario/Sindico/options/cadastroMorador/listar_moradores_page.dart'; // REMOVA esta importação, pois a página será incorporada

class CadastrarMoradorPage extends StatefulWidget {
  const CadastrarMoradorPage({super.key});

  @override
  State<CadastrarMoradorPage> createState() => _CadastrarMoradorPageState();
}

class _CadastrarMoradorPageState extends State<CadastrarMoradorPage> with SingleTickerProviderStateMixin { // ADICIONE 'with SingleTickerProviderStateMixin'
  // --- Variáveis e Controladores para a Aba de Cadastro ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _casaController = TextEditingController();
  bool _carregandoCadastro = false; // Renomeado para clareza
  
  // --- Variáveis para o Gerenciamento de Abas e Listagem ---
  late TabController _tabController; // Adicione o TabController
  final dbHelper = DatabaseHelper(); // Instância do DatabaseHelper
  List<Map<String, dynamic>> _moradores = []; // Para a lista de moradores
  bool _carregandoLista = true; // Para o estado de carregamento da lista

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Duas abas: Cadastrar e Listar
    
    // Ouve mudanças de aba para recarregar a lista quando a aba "Listar Moradores" for selecionada
    _tabController.addListener(() {
      if (_tabController.index == 1) { // Se a segunda aba (Listar Moradores) for selecionada
        _carregarMoradores(); // Recarrega a lista
      }
    });

    _carregarMoradores(); // Carrega os moradores na inicialização para a primeira exibição da lista
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

  // --- Métodos para a Aba de Cadastro ---
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

      // Após cadastrar, navegar para a aba "Listar Moradores" e recarregar
      _tabController.animateTo(1); // Mudar para a aba de listagem
      _carregarMoradores(); // Recarregar a lista para mostrar o novo morador
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

  // --- Métodos para a Aba de Listagem ---
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
        _carregarMoradores(); // Recarregar a lista após a exclusão
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir morador: $e')),
          );
        }
      }
    }
  }

  // --- Widgets das Abas ---

  /// Constrói o formulário para cadastrar um novo morador.
  Widget _buildCadastrarMoradorForm() {
    return Padding(
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
              onPressed: _carregandoCadastro ? null : _cadastrarMorador,
              child: _carregandoCadastro
                  ? const CircularProgressIndicator(color: Colors.white) // Corrigi a cor
                  : const Text('Cadastrar',
                      style: TextStyle(
                          color: Color.fromARGB(255, 61, 96, 178),
                          fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a lista de moradores cadastrados.
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
                  // Você pode envolver com Card para um visual melhor
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Color.fromARGB(255, 61, 96, 178)),
                      title: Text(m['nome']),
                      subtitle: Text('Casa: ${m['casa']} | E-mail: ${m['email']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir morador',
                        onPressed: () {
                          final usuarioId = m['id']; // Use 'id' do usuário para exclusão
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
          'Gerenciar Moradores', // Título mais genérico para a tela com abas
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
        bottom: TabBar( // Adicione a TabBar aqui
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cadastrar Morador', icon: Icon(Icons.person_add)),
            Tab(text: 'Listar Moradores', icon: Icon(Icons.list)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: false, // Geralmente não é necessário para 2 abas
        ),
      ),
      body: TabBarView( // Adicione o TabBarView ao body
        controller: _tabController,
        children: [
          _buildCadastrarMoradorForm(), // Conteúdo da aba "Cadastrar Morador"
          _buildListarMoradores(),      // Conteúdo da aba "Listar Moradores"
        ],
      ),
    );
  }
}