import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'dart:io'; // Para exibir a imagem/arquivo do comprovante
import 'package:intl/intl.dart'; // Para formatar datas e moedas
import 'package:open_filex/open_filex.dart'; // Importe a nova biblioteca

class ListarComprovantesPage extends StatefulWidget {
  const ListarComprovantesPage({super.key});

  @override
  State<ListarComprovantesPage> createState() => _ListarComprovantesPageState();
}

class _ListarComprovantesPageState extends State<ListarComprovantesPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _comprovantes = [];
  bool _isLoading = true;

  // COR DO TEMA DO SÍNDICO
  final Color sindicoThemeColor = const Color.fromARGB(255, 34, 139, 34); // VERDE

  @override
  void initState() {
    super.initState();
    _carregarComprovantes();
  }

  Future<void> _carregarComprovantes() async {
    setState(() {
      _isLoading = true;
    });
    final comprovantes = await dbHelper.buscarTodosComprovantesComMoradores();
    setState(() {
      _comprovantes = comprovantes;
      _isLoading = false;
    });
  }

  // Função para exibir os detalhes do comprovante em um modal
  void _mostrarDetalhesComprovante(Map<String, dynamic> comprovante) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Comprovante de ${comprovante['nome_morador']}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Mês de Referência: ${comprovante['mes_referencia']}'),
                Text('Tipo: ${comprovante['tipo']}'),
                Text('Valor: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(comprovante['valor'])}'),
                Text('Status: ${comprovante['status']}'),
                Text('Comentário: ${comprovante['comentario'] ?? 'Nenhum'}'),
                Text('Data de Envio: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(comprovante['data_envio']))}'),
                const SizedBox(height: 10),
                Text('Morador: ${comprovante['nome_morador']} (Casa: ${comprovante['casa_morador']})'),
                Text('Email: ${comprovante['email_morador']}'),
                const SizedBox(height: 20),
                if (comprovante['caminho_arquivo'] != null &&
                    File(comprovante['caminho_arquivo']).existsSync())
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Comprovante Anexado:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () async {
                          final filePath = comprovante['caminho_arquivo'];
                          if (filePath != null) {
                            try {
                              await OpenFilex.open(filePath);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Não foi possível abrir o arquivo: $e')),
                                );
                              }
                            }
                          }
                        },
                        child: comprovante['caminho_arquivo'].toLowerCase().endsWith('.pdf')
                            ? const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red)
                            : Image.file(
                                File(comprovante['caminho_arquivo']),
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Arquivo de comprovante não encontrado ou não anexado.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                const SizedBox(height: 20),
                if (comprovante['status'] == 'pendente')
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _atualizarStatus(comprovante['id'], 'confirmado');
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: sindicoThemeColor), // Corrigido
                        child: const Text('Confirmar Comprovante', style: TextStyle(color: Colors.white)), // Texto branco
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _atualizarStatus(comprovante['id'], 'rejeitado');
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Rejeitar Comprovante', style: TextStyle(color: Colors.white)), // Texto branco
                      ),
                    ],
                  )
                else
                  Text(
                    'Este comprovante já foi ${comprovante['status']}.',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _atualizarStatus(int comprovanteId, String novoStatus) async {
    await dbHelper.atualizarStatusComprovante(comprovanteId, novoStatus);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comprovante ${novoStatus} com sucesso!')),
      );
    }
    _carregarComprovantes();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'confirmado':
        return Colors.green;
      case 'rejeitado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comprovantes de Moradores',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: sindicoThemeColor, // Corrigido
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _comprovantes.isEmpty
              ? const Center(child: Text('Nenhum comprovante enviado ainda.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _comprovantes.length,
                  itemBuilder: (context, index) {
                    final comprovante = _comprovantes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.receipt, color: _getStatusColor(comprovante['status'])),
                        title: Text(
                          '${comprovante['mes_referencia']} - ${comprovante['tipo']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Morador: ${comprovante['nome_morador']} (Casa: ${comprovante['casa_morador']})'),
                            Text('Valor: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(comprovante['valor'])}'),
                            Text('Status: ${comprovante['status']}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _mostrarDetalhesComprovante(comprovante),
                      ),
                    );
                  },
                ),
    );
  }
}