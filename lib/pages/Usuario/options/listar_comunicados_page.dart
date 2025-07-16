import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'package:intl/intl.dart';

class ListarComunicadosPage extends StatefulWidget {
  final String userType; // NOVO: Campo para receber o tipo de usuário
  const ListarComunicadosPage({super.key, required this.userType}); // NOVO: Construtor com userType

  @override
  State<ListarComunicadosPage> createState() => _ListarComunicadosPageState();
}

class _ListarComunicadosPageState extends State<ListarComunicadosPage> {
  late Future<List<Map<String, dynamic>>> _comunicadosFuture;

  // CORES DO TEMA
  final Color moradorThemeColor = const Color.fromARGB(255, 61, 96, 178); // AZUL
  final Color sindicoThemeColor = const Color.fromARGB(255, 34, 139, 34); // VERDE
  final Color funcionarioThemeColor = const Color.fromARGB(255, 128, 0, 128); // ROXO

  late Color pageThemeColor; // Variável para a cor do tema da página

  @override
  void initState() {
    super.initState();
    // Define a cor do tema baseada no tipo de usuário
    switch (widget.userType) {
      case 'sindico':
        pageThemeColor = sindicoThemeColor;
        break;
      case 'funcionario':
        pageThemeColor = funcionarioThemeColor;
        break;
      case 'morador':
      default:
        pageThemeColor = moradorThemeColor;
        break;
    }
    _comunicadosFuture = DatabaseHelper().listarComunicados();
  }

  String formatarData(String data) {
    final date = DateTime.parse(data);
    return DateFormat('dd/MM/yyyy – HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Comunicados',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: pageThemeColor, // Cor dinâmica
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _comunicadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os comunicados.'));
          }
          final comunicados = snapshot.data!;
          if (comunicados.isEmpty) {
            return const Center(child: Text('Nenhum comunicado disponível.'));
          }
          return ListView.builder(
            itemCount: comunicados.length,
            itemBuilder: (context, index) {
              final comunicado = comunicados[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(Icons.announcement, color: pageThemeColor), // Cor dinâmica
                  title: Text(comunicado['titulo']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comunicado['descricao']),
                      const SizedBox(height: 6),
                      Text(
                        'Publicado em: ${formatarData(comunicado['data_criacao'])}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}