import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'package:intl/intl.dart';

class ListarComunicadosPage extends StatefulWidget {
  const ListarComunicadosPage({super.key});

  @override
  State<ListarComunicadosPage> createState() => _ListarComunicadosPageState();
}

class _ListarComunicadosPageState extends State<ListarComunicadosPage> {
  late Future<List<Map<String, dynamic>>> _comunicadosFuture;

  @override
  void initState() {
    super.initState();
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
        title: const Text('Comunicados'),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
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
                  leading: const Icon(Icons.announcement, color: Colors.blue),
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
