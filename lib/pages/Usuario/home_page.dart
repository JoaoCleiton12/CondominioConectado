import 'package:condomonioconectado/pages/Usuario/Morador/cadastrar_pet_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/cadastrar_funcionario_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Comunicados/cadastrar_comunicado_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Comunicados/listar_comunicados_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/listar_pets_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'Sindico/options/cadastroMorador/cadastrar_morador_page.dart'; 

class HomePage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const HomePage({super.key, required this.usuario});

  List<String> _obterOpcoes(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'morador':
        return ['Opção 1', 'Comunicados', 'Opção 3', 'Opção 4', 'Cadastrar Pet'];
      case 'funcionario':
        return ['Comunicados', 'Opção 2', 'Opção 3', 'Opção 4', 'Opção 5', 'Opção 6', 'Opção 7', 'Opção 8'];
      case 'sindico':
        return ['Morador', 'Listar Pets', 'Cadastrar Comunicado', 'Comunicados', 'Funcionario', 'Opção 6'];
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
                    }
                    if (opcao == 'Cadastrar Pet' && tipoUsuario == 'morador') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastrarPetPage()),
                      );
                    } 
                    if (opcao == 'Listar Pets' && tipoUsuario == 'sindico') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ListarPetsPage()),
                      );
                    }
                    if (opcao == 'Cadastrar Comunicado' && tipoUsuario == 'sindico') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastrarComunicadoPage()),
                      );
                    }
                    if (opcao == 'Comunicados') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ListarComunicadosPage()),
                      );
                    }
                    if (opcao == 'Funcionario') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastrarFuncionarioPage()),
                      );
                    }
                    else {
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
                    child: (opcao == 'Morador' && tipoUsuario == 'sindico')
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
                        : (opcao == 'Listar Pets' && tipoUsuario == 'sindico')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.pets, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Listar Pets',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        : (opcao == 'Cadastrar Comunicado' && tipoUsuario == 'sindico')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.announcement, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Cadastrar Comunicado',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        : (opcao == 'Comunicados')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.announcement, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Comunicados',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        : (opcao == 'Funcionario')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.badge, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Funcionario',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        :  Text(
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
