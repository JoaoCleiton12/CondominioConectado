import 'package:condomonioconectado/pages/Usuario/Morador/options/Pets/cadastrar_pet_page.dart';
import 'package:condomonioconectado/pages/Usuario/Morador/options/Visitantes/cadastrar_visitantes_page.dart';
import 'package:condomonioconectado/pages/Usuario/Morador/options/Visitantes/listar_visitantes_page.dart';
import 'package:condomonioconectado/pages/Usuario/Morador/options/Visitantes/registrar_visitante_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Funcionarios/cadastrar_funcionario_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Comunicados/cadastrar_comunicado_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Comunicados/listar_comunicados_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Pets/listar_pets_page.dart';
import 'package:condomonioconectado/pages/Usuario/options/listar_reservas_page.dart';
import 'package:condomonioconectado/pages/Usuario/options/reservar_area_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'Sindico/options/cadastroMorador/cadastrar_morador_page.dart'; 

class HomePage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const HomePage({super.key, required this.usuario});

  List<String> _obterOpcoes(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'morador':
        return ['Area de Lazer', 'Cadastrar Pet', 'Cadastrar Visitante', 'Comunicados', 'Registrar Visita'];
      case 'funcionario':
        return ['Comunicados', 'Reservas', 'Visitantes'];
      case 'sindico':
        return ['Cadastrar Comunicado', 'Comunicados', 'Funcionario', 'Listar Pets', 'Morador', 'Reservas'];
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
                    //Opções do sindico--------------------------------------------------------------------------------
                    if (opcao == 'Cadastrar Comunicado' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarComunicadoPage()));
                    }
                    if (opcao == 'Funcionario' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarFuncionarioPage()));
                    }
                    if (opcao == 'Listar Pets' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListarPetsPage()));
                    }
                    if (opcao == 'Morador' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarMoradorPage())); 
                    } 
                    //-------------------------------------------------------------------------------------------------


                    //Opções do morador--------------------------------------------------------------------------------
                    if (opcao == 'Cadastrar Pet' && tipoUsuario == 'morador') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarPetPage()));
                    }
                    if (opcao == 'Cadastrar Visitante' && tipoUsuario == 'morador') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarVisitantePage()));
                    }
                    if (opcao == 'Registrar Visita' && tipoUsuario == 'morador') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarVisitaPage()));
                    }
                    //-------------------------------------------------------------------------------------------------


                    //Opções do funcionário----------------------------------------------------------------------------
                    if (opcao == 'Visitantes' && tipoUsuario == 'funcionario') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListarVisitantesPage()));
                    }
                    //-------------------------------------------------------------------------------------------------


                    //Opções para mais de um usuário-------------------------------------------------------------------
                    if (opcao == 'Reservas') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListarReservasPage()));
                    } 
                    if (opcao == 'Comunicados') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListarComunicadosPage()));
                    }
                    if (opcao == 'Area de Lazer') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservarAreaPage()));
                    }
                    //-------------------------------------------------------------------------------------------------

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
                    child
                    //Opções do síndico-----------------------------------------------------------------------------------------------------
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
                        : (opcao == 'Funcionario' && tipoUsuario == 'sindico')
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
                        : (opcao == 'Morador' && tipoUsuario == 'sindico')
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
                        //------------------------------------------------------------------------------------------------------------------
                        

                        //Opções do morador-------------------------------------------------------------------------------------------------
                        : (opcao == 'Cadastrar Pet' && tipoUsuario == 'morador')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.pets, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Cadastrar Pet',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        : (opcao == 'Cadastrar Visitante' && tipoUsuario == 'morador')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.person_add, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Cadastrar Visitante',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ) 
                        : (opcao == 'Registrar Visita' && tipoUsuario == 'morador')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.how_to_reg, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text('Registrar Visita', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                                ],
                              )
                        //------------------------------------------------------------------------------------------------------------------


                        //Opções do funcionário---------------------------------------------------------------------------------------------
                        :(opcao == 'Visitantes' && tipoUsuario == 'funcionario')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.group, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Visitantes',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        //------------------------------------------------------------------------------------------------------------------


                        //Opções para mais de um usuário------------------------------------------------------------------------------------    
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
                        : (opcao == 'Reservas')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.calendar_month, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Reservas',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        : (opcao == 'Area de Lazer')
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.calendar_month, color: Colors.white, size: 60),
                                  SizedBox(height: 8),
                                  Text(
                                    'Area de Lazer',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                        //------------------------------------------------------------------------------------------------------------------
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
