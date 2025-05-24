import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'options/cadastroMorador/cadastrar_morador_page.dart'; 

class HomePage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const HomePage({super.key, required this.usuario});

  List<String> _obterOpcoes(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'morador':
        return ['Opção 1', 'Opção 2', 'Opção 3', 'Opção 4', 'Opção 5'];
      case 'funcionario':
        return ['Opção 1', 'Opção 2', 'Opção 3', 'Opção 4', 'Opção 5', 'Opção 6', 'Opção 7', 'Opção 8'];
      case 'sindico':
        return ['Morador', 'Opção 2', 'Opção 3', 'Opção 4', 'Opção 5', 'Opção 6'];
      default:
        return ['Opção 1']; // padrão para tipos desconhecidos
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipoUsuario = usuario['tipo_usuario'] ?? 'desconhecido';
    final opcoes = _obterOpcoes(tipoUsuario);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
        title: const Text('Condomínio Conectado'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Bem-vindo, ${usuario['nome']}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: opcoes.length,
              itemBuilder: (context, index) {
                final opcao = opcoes[index];
                return ElevatedButton(
                  onPressed: () {
                    if (opcao == 'Morador' && tipoUsuario == 'sindico') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastrarMoradorPage()),
                      );
                    } else {
                      print("$opcao selecionada");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color.fromARGB(255, 61, 96, 178),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // quadrado
                    ),
                  ),
                  child: Center(
                    child: opcao == 'Morador'
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.person_add, color: Colors.white, size: 60),
                              SizedBox(height: 8),
                              Text(
                                'Morador',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Text(
                            opcao,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
