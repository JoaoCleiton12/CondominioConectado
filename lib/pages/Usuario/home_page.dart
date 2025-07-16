import 'package:condomonioconectado/pages/Usuario/Morador/options/Pets/cadastrar_pet_page.dart';
import 'package:condomonioconectado/pages/Usuario/Morador/options/Visitantes/cadastrar_visitantes_page.dart';
import 'package:condomonioconectado/pages/Usuario/Funcionario/options/listar_visitantes_page.dart';
import 'package:condomonioconectado/pages/Usuario/Morador/options/Visitantes/registrar_visitante_page.dart';
import 'package:condomonioconectado/pages/Usuario/Morador/options/enviar_comprovante_page.dart';

import 'package:condomonioconectado/pages/Usuario/Morador/options/listar_atas_morador_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Funcionarios/cadastrar_funcionario_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Comunicados/cadastrar_comunicado_page.dart';
import 'package:condomonioconectado/pages/Usuario/options/listar_comunicados_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/Pets/listar_pets_page.dart';

import 'package:condomonioconectado/pages/Usuario/Sindico/options/atas_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/gerenciar_manutencoes_sindico_page.dart';
import 'package:condomonioconectado/pages/Usuario/Sindico/options/listar_comprovantes_page.dart';
import 'package:condomonioconectado/pages/Usuario/options/listar_reservas_page.dart';
import 'package:condomonioconectado/pages/Usuario/options/reservar_area_page.dart';
import 'package:condomonioconectado/pages/Usuario/solicitacao_manutencao_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'Sindico/options/cadastroMorador/cadastrar_morador_page.dart'; 

class HomePage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const HomePage({super.key, required this.usuario});

  // Cores do tema por tipo de usuário
  final Color moradorThemeColor = const Color.fromARGB(255, 61, 96, 178); // AZUL
  final Color sindicoThemeColor = const Color.fromARGB(255, 34, 139, 34); // VERDE
  final Color funcionarioThemeColor = const Color.fromARGB(255, 128, 0, 128); // ROXO

  List<String> _obterOpcoes(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'morador':
        return ['Area de Lazer', 'Cadastrar Pet', 'Cadastrar Visitante', 'Comunicados', 'Registrar Visita', 'Emitir Debitos', 'Manutenção', 'Listar Atas', 'Reservas'];
      case 'funcionario':
        return ['Comunicados', 'Reservas', 'Visitantes', 'Manutenção', 'Gerenciar Manutenções'];
      case 'sindico':
        return ['Cadastrar Comunicado', 'Comunicados', 'Funcionario', 'Listar Pets', 'Morador', 'Reservas', 'Comprovantes', 'Manutenção', 'Gerenciar Manutenções', 'Atas'];
      default:
        return ['Opção 1'];
    }
  }

  // Método auxiliar para obter a cor do tema com base no tipo de usuário
  Color _getThemeColor(String userType) {
    switch (userType) {
      case 'sindico':
        return sindicoThemeColor;
      case 'funcionario':
        return funcionarioThemeColor;
      case 'morador':
      default:
        return moradorThemeColor; // Padrão para morador
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipoUsuario = usuario['tipo_usuario'] ?? 'desconhecido';
    final opcoes = _obterOpcoes(tipoUsuario);
    final Color currentThemeColor = _getThemeColor(tipoUsuario); // Obtém a cor do tema atual

    return Scaffold(
      appBar: AppBar(
        backgroundColor: currentThemeColor, // Corrigido para cor dinâmica
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.apartment, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Condomínio Conectado',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
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
            style: TextStyle(color: currentThemeColor, fontSize: 24, fontWeight: FontWeight.bold), // Corrigido
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
                    // Opções do síndico
                    if (opcao == 'Cadastrar Comunicado' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarComunicadoPage()));
                    } else if (opcao == 'Funcionario' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarFuncionarioPage()));
                    } else if (opcao == 'Listar Pets' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListarPetsPage()));
                    } else if (opcao == 'Morador' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarMoradorPage())); 
                    } else if (opcao == 'Comprovantes' && tipoUsuario == 'sindico') { 
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListarComprovantesPage()));
                    } else if (opcao == 'Gerenciar Manutenções' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => GerenciarManutencoesSindicoPage(userType: tipoUsuario)));
                    } else if (opcao == 'Atas' && tipoUsuario == 'sindico') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AtasPage()));
                    } 
                    // Opções do morador
                    else if (opcao == 'Cadastrar Pet' && tipoUsuario == 'morador') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarPetPage()));
                    } else if (opcao == 'Cadastrar Visitante' && tipoUsuario == 'morador') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarVisitantePage()));
                    } else if (opcao == 'Registrar Visita' && tipoUsuario == 'morador') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarVisitaPage()));
                    } else if (opcao == 'Emitir Debitos' && tipoUsuario == 'morador') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EnviarComprovantePage()));
                    } else if (opcao == 'Listar Atas' && tipoUsuario == 'morador') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListarAtasMoradorPage()));
                    }
                    // Opções do funcionário
                    else if (opcao == 'Visitantes' && tipoUsuario == 'funcionario') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ListarVisitantesPage()));
                    } else if (opcao == 'Gerenciar Manutenções' && tipoUsuario == 'funcionario') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => GerenciarManutencoesSindicoPage(userType: tipoUsuario)));
                    } 
                    // Opções para mais de um usuário (comum a todos que tiverem a opção no _obterOpcoes)
                    else if (opcao == 'Reservas') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ListarReservasPage(userType: tipoUsuario)));
                    } else if (opcao == 'Comunicados') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ListarComunicadosPage(userType: tipoUsuario)));
                    } else if (opcao == 'Area de Lazer') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ReservarAreaPage(userType: tipoUsuario)));
                    } else if (opcao == 'Manutenção') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SolicitacaoManutencaoPage(userType: tipoUsuario)));
                    }
                    else {
                      print("$opcao selecionada");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: currentThemeColor, // Corrigido para cor dinâmica
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // quadrado
                    ),
                  ),
                  child: Center(
                    child: // Opções do síndico
                    (opcao == 'Cadastrar Comunicado' && tipoUsuario == 'sindico')
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
                                    : (opcao == 'Comprovantes' && tipoUsuario == 'sindico')
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.description, color: Colors.white, size: 60),
                                              SizedBox(height: 8),
                                              Text(
                                                'Comprovantes',
                                                style: TextStyle(color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          )
                                        : (opcao == 'Gerenciar Manutenções' && tipoUsuario == 'sindico')
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.settings, color: Colors.white, size: 60),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Gerenciar Manutenções',
                                                    style: TextStyle(color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              )
                                            : (opcao == 'Atas' && tipoUsuario == 'sindico')
                                                ? Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: const [
                                                      Icon(Icons.gavel, color: Colors.white, size: 60),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Atas',
                                                        style: TextStyle(color: Colors.white),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  )
                                                // Opções do morador
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
                                                            : (opcao == 'Emitir Debitos' && tipoUsuario == 'morador')
                                                                ? Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: const [
                                                                      Icon(Icons.attach_file, color: Colors.white, size: 60),
                                                                      SizedBox(height: 8),
                                                                      Text(
                                                                        'Emitir Debitos',
                                                                        style: TextStyle(color: Colors.white),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ],
                                                                  )
                                                                : (opcao == 'Listar Atas' && tipoUsuario == 'morador')
                                                                    ? Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: const [
                                                                          Icon(Icons.gavel, color: Colors.white, size: 60),
                                                                          SizedBox(height: 8),
                                                                          Text(
                                                                            'Listar Atas',
                                                                            style: TextStyle(color: Colors.white),
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    // Opções do funcionário
                                                                    : (opcao == 'Visitantes' && tipoUsuario == 'funcionario')
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
                                                                        : (opcao == 'Gerenciar Manutenções' && tipoUsuario == 'funcionario')
                                                                            ? Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: const [
                                                                                  Icon(Icons.settings, color: Colors.white, size: 60),
                                                                                  SizedBox(height: 8),
                                                                                  Text(
                                                                                    'Gerenciar Manutenções',
                                                                                    style: TextStyle(color: Colors.white),
                                                                                    textAlign: TextAlign.center,
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            // Opções para mais de um usuário
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
                                                                                        : (opcao == 'Manutenção')
                                                                                            ? Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                children: const [
                                                                                                  Icon(Icons.build, color: Colors.white, size: 60),
                                                                                                  SizedBox(height: 8),
                                                                                                  Text(
                                                                                                    'Manutenção',
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