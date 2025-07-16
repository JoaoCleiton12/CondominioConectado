import 'package:condomonioconectado/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastrarPetPage extends StatefulWidget {
  const CadastrarPetPage({super.key});

  @override
  State<CadastrarPetPage> createState() => _CadastrarPetPageState();
}

class _CadastrarPetPageState extends State<CadastrarPetPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  
  // Certifique-se de que esta linha esteja presente e correta
  late TabController _tabController; 
  final dbHelper = DatabaseHelper(); // Instância do DatabaseHelper

  @override
  void initState() {
    super.initState();
    // ESSA É A LINHA CRÍTICA: Certifique-se de que _tabController seja inicializado aqui
    _tabController = TabController(length: 2, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  void _cadastrarPet() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuario_id');

      if (usuarioId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário não autenticado.'))
          );
        }
        return;
      }

      final nome = _nomeController.text;
      final idade = _idadeController.text;

      await dbHelper.inserirPet(nome, idade, usuarioId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet cadastrado com sucesso!'))
        );
      }

      _nomeController.clear();
      _idadeController.clear();
      
      // Após cadastrar, navegar para a aba "Meus Pets"
      _tabController.animateTo(1); 
    }
  }

  // --- Widget para a aba "Cadastrar Pet" ---
  Widget _buildCadastrarPetForm() {
    return Padding(
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cadastrarPet,
              child: const Text(
                'Cadastrar Pet',
                style: TextStyle(color: Color.fromARGB(255, 61, 96, 178), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget para a aba "Meus Pets" ---
  Widget _buildListarMeusPets() {
    // Usamos um Builder aqui para garantir que o FutureBuilder tenha um BuildContext válido
    // para o ScaffoldMessenger (se você adicionasse SnackBar aqui futuramente).
    return Builder(
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getMeusPets(), // Função para buscar os pets do usuário logado
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar seus pets: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Você não tem pets cadastrados.'));
            } else {
              final meusPets = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: meusPets.length,
                itemBuilder: (context, index) {
                  final pet = meusPets[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.pets, color: Color.fromARGB(255, 61, 96, 178)),
                      title: Text(pet['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Idade: ${pet['idade']}'),
                      // Você pode adicionar mais ações aqui, como editar ou excluir o pet
                      // trailing: IconButton(
                      //   icon: const Icon(Icons.delete, color: Colors.red),
                      //   onPressed: () {
                      //     // Implementar lógica de exclusão aqui
                      //   },
                      // ),
                    ),
                  );
                },
              );
            }
          },
        );
      }
    );
  }

  // --- Função auxiliar para buscar os pets do usuário logado ---
  Future<List<Map<String, dynamic>>> _getMeusPets() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id');
    if (usuarioId == null) {
      return []; // Retorna lista vazia se o ID do usuário não for encontrado
    }
    return await dbHelper.buscarPetsDoUsuario(usuarioId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Gerenciar Pets', // Título mais genérico para a tela com abas
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
            Tab(text: 'Cadastrar Pet', icon: Icon(Icons.add_circle_outline)),
            Tab(text: 'Meus Pets', icon: Icon(Icons.pets)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: false, // Duas abas geralmente não precisam de scroll
        ),
      ),
      body: TabBarView( // Adicione o TabBarView ao body
        controller: _tabController,
        children: [
          _buildCadastrarPetForm(), // Conteúdo da aba "Cadastrar Pet"
          _buildListarMeusPets(),    // Conteúdo da aba "Meus Pets"
        ],
      ),
    );
  }
}