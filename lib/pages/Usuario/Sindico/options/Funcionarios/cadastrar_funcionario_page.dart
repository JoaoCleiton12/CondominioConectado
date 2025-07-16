import 'package:condomonioconectado/database/database_helper.dart';
import 'package:flutter/material.dart';
// import 'package:condomonioconectado/pages/Usuario/Sindico/options/Funcionarios/listar_funcionarios_page.dart'; // REMOVA esta importação, pois a página será incorporada

class CadastrarFuncionarioPage extends StatefulWidget {
  const CadastrarFuncionarioPage({super.key});

  @override
  State<CadastrarFuncionarioPage> createState() => _CadastrarFuncionarioPageState();
}

class _CadastrarFuncionarioPageState extends State<CadastrarFuncionarioPage> with SingleTickerProviderStateMixin {
  // --- Variáveis e Controladores para a Aba de Cadastro ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String? _tipoFuncionarioSelecionado;
  bool _carregandoCadastro = false; // Renomeado para clareza

  // --- Variáveis para o Gerenciamento de Abas e Listagem ---
  late TabController _tabController; // Adicione o TabController
  final dbHelper = DatabaseHelper(); // Instância do DatabaseHelper
  List<Map<String, dynamic>> _funcionarios = []; // Para a lista de funcionários
  bool _carregandoLista = true; // Para o estado de carregamento da lista

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Duas abas: Cadastrar e Listar
    
    // Ouve mudanças de aba para recarregar a lista quando a aba "Listar Funcionários" for selecionada
    _tabController.addListener(() {
      if (_tabController.index == 1) { // Se a segunda aba (Listar Funcionários) for selecionada
        _carregarFuncionarios(); // Recarrega a lista
      }
    });

    _carregarFuncionarios(); // Carrega os funcionários na inicialização para a primeira exibição da lista
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // --- Métodos para a Aba de Cadastro ---
  void _cadastrarFuncionario() async {
    if (!_formKey.currentState!.validate() || _tipoFuncionarioSelecionado == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o tipo de funcionário')),
        );
      }
      return;
    }

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
      'tipo_usuario': 'funcionario',
      'token_recuperacao': null,
    };

    try {
      int usuarioId = await dbHelper.inserirUsuario(usuario);
      await dbHelper.inserirFuncionario(usuarioId, _tipoFuncionarioSelecionado!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionário cadastrado com sucesso!')),
        );
      }

      _nomeController.clear();
      _telefoneController.clear();
      _emailController.clear();
      _senhaController.clear();
      setState(() {
        _tipoFuncionarioSelecionado = null;
      });

      // Após cadastrar, navegar para a aba "Listar Funcionários" e recarregar
      _tabController.animateTo(1); // Mudar para a aba de listagem
      _carregarFuncionarios(); // Recarregar a lista para mostrar o novo funcionário
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
  Future<void> _carregarFuncionarios() async {
    setState(() {
      _carregandoLista = true;
    });
    try {
      final funcionarios = await dbHelper.buscarTodosFuncionarios();
      setState(() {
        _funcionarios = funcionarios;
        _carregandoLista = false;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar funcionários: $e')),
        );
      }
      setState(() => _carregandoLista = false);
    }
  }

  void _confirmarExcluirFuncionario(int usuarioId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este funcionário?'),
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
        await dbHelper.deletarFuncionario(usuarioId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionário excluído com sucesso!')),
          );
        }
        _carregarFuncionarios(); // Recarregar a lista após a exclusão
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir funcionário: $e')),
          );
        }
      }
    }
  }

  // --- Widgets das Abas ---

  /// Constrói o formulário para cadastrar um novo funcionário.
  Widget _buildCadastrarFuncionarioForm() {
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoFuncionarioSelecionado,
              decoration: const InputDecoration(labelText: 'Cargo do Funcionário'),
              items: const [
                DropdownMenuItem(value: 'porteiro', child: Text('Porteiro')),
                DropdownMenuItem(value: 'zelador', child: Text('Zelador')),
                // As opções 'faxineiro' e 'manutencao' foram removidas
              ],
              onChanged: (value) {
                setState(() {
                  _tipoFuncionarioSelecionado = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Selecione o cargo do funcionário' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregandoCadastro ? null : _cadastrarFuncionario,
              child: _carregandoCadastro
                  ? const CircularProgressIndicator(color: Colors.white)
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

  /// Constrói a lista de funcionários cadastrados.
  Widget _buildListarFuncionarios() {
    return _carregandoLista
        ? const Center(child: CircularProgressIndicator())
        : _funcionarios.isEmpty
            ? const Center(child: Text('Nenhum funcionário encontrado.'))
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _funcionarios.length,
                itemBuilder: (context, index) {
                  final f = _funcionarios[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.badge, color: Color.fromARGB(255, 61, 96, 178)),
                      title: Text(f['nome']),
                      subtitle: Text('Cargo: ${f['cargo']} | E-mail: ${f['email']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir funcionário',
                        onPressed: () {
                          final usuarioId = f['usuario_id']; // Use 'usuario_id' que vem da query
                          if (usuarioId != null) {
                            _confirmarExcluirFuncionario(usuarioId);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Erro: ID do funcionário inválido')),
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
          'Gerenciar Funcionários', // Título mais genérico para a tela com abas
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
            Tab(text: 'Cadastrar Funcionário', icon: Icon(Icons.person_add)),
            Tab(text: 'Listar Funcionários', icon: Icon(Icons.list)),
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
          _buildCadastrarFuncionarioForm(), // Conteúdo da aba "Cadastrar Funcionário"
          _buildListarFuncionarios(),      // Conteúdo da aba "Listar Funcionários"
        ],
      ),
    );
  }
}