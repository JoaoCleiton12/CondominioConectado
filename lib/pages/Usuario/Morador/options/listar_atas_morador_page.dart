import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'dart:io'; // Para File
import 'package:open_filex/open_filex.dart'; // Para abrir arquivos locais
import 'package:url_launcher/url_launcher.dart'; // Para abrir links externos

class ListarAtasMoradorPage extends StatefulWidget {
  const ListarAtasMoradorPage({super.key});

  @override
  State<ListarAtasMoradorPage> createState() => _ListarAtasMoradorPageState();
}

class _ListarAtasMoradorPageState extends State<ListarAtasMoradorPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _atas = [];
  bool _carregandoLista = true;

  @override
  void initState() {
    super.initState();
    _carregarAtas();
  }

  Future<void> _carregarAtas() async {
    setState(() {
      _carregandoLista = true;
    });
    try {
      final fetchedAtas = await dbHelper.buscarTodasAtas();
      setState(() {
        _atas = fetchedAtas;
        _carregandoLista = false;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar atas: $e')),
        );
      }
      setState(() => _carregandoLista = false);
    }
  }

  // Método para abrir link externo
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atas de Assembleia', // Título para o morador
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
        centerTitle: true,
      ),
      body: _carregandoLista
          ? const Center(child: CircularProgressIndicator())
          : _atas.isEmpty
              ? const Center(child: Text('Nenhuma ata cadastrada ainda.'))
              : RefreshIndicator( // Permite "puxar para atualizar"
                  onRefresh: _carregarAtas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _atas.length,
                    itemBuilder: (context, index) {
                      final ata = _atas[index];
                      final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(ata['data_ata']));
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        child: ListTile(
                          leading: const Icon(Icons.gavel, color: Color.fromARGB(255, 61, 96, 178)),
                          title: Text(ata['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Data: $formattedDate'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Ícone para link externo
                              if (ata['link_externo'] != null && ata['link_externo'].isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.link, color: Colors.blue),
                                  tooltip: 'Abrir Link Externo',
                                  onPressed: () => _launchUrl(ata['link_externo']),
                                ),
                              // Ícone para arquivo local
                              if (ata['caminho_arquivo_local'] != null && File(ata['caminho_arquivo_local']).existsSync())
                                IconButton(
                                  icon: const Icon(Icons.file_copy, color: Colors.green),
                                  tooltip: 'Abrir Arquivo Local',
                                  onPressed: () async {
                                    try {
                                      await OpenFilex.open(ata['caminho_arquivo_local']);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Não foi possível abrir o arquivo: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              // NOTA: O botão de exclusão foi removido daqui para o morador
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}