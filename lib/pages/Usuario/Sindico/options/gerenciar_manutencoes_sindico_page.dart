import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';

class GerenciarManutencoesSindicoPage extends StatefulWidget {
  final String userType; // NOVO: Campo para receber o tipo de usuário
  const GerenciarManutencoesSindicoPage({super.key, required this.userType}); // NOVO: Construtor com userType

  @override
  State<GerenciarManutencoesSindicoPage> createState() => _GerenciarManutencoesSindicoPageState();
}

class _GerenciarManutencoesSindicoPageState extends State<GerenciarManutencoesSindicoPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _solicitacoes = [];
  bool _isLoading = true;

  final List<String> _prioridadesDisponiveis = ['Não Definida', 'Baixa', 'Média', 'Alta'];
  final List<String> _statusDisponiveis = ['Pendente', 'Aprovada', 'Rejeitada', 'Em Andamento', 'Concluída', 'Cancelada'];

  // COR DO TEMA DINÂMICA
  late Color pageThemeColor; // Agora é 'late' e será inicializada no initState

  @override
  void initState() {
    super.initState();
    // Define a cor do tema baseada no tipo de usuário
    if (widget.userType == 'sindico') {
      pageThemeColor = const Color.fromARGB(255, 34, 139, 34); // VERDE para síndico
    } else { // Assumindo que o outro tipo que acessa é funcionário
      pageThemeColor = const Color.fromARGB(255, 128, 0, 128); // ROXO para funcionário
    }
    _carregarSolicitacoes();
  }

  Future<void> _carregarSolicitacoes() async {
    setState(() {
      _isLoading = true;
    });
    final fetchedSolicitacoes = await dbHelper.buscarTodasSolicitacoesManutencao();
    setState(() {
      _solicitacoes = fetchedSolicitacoes;
      _isLoading = false;
    });
  }

  void _mostrarDetalhesEGerenciarSolicitacao(Map<String, dynamic> solicitacao) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? currentStatus = solicitacao['status'];
        String? currentPrioridade = _prioridadesDisponiveis.contains(solicitacao['prioridade'])
            ? solicitacao['prioridade']
            : 'Não Definida';

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text('Gerenciar Solicitação: ${solicitacao['titulo']}'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Descrição: ${solicitacao['descricao']}'),
                    Text('Solicitado por: ${solicitacao['nome_solicitante']}'),
                    Text('Data da Solicitação: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(solicitacao['data_solicitacao']))}'),
                    if (solicitacao['data_conclusao'] != null)
                      Text('Data de Conclusão: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(solicitacao['data_conclusao']))}'),
                    if (solicitacao['nome_responsavel'] != null)
                      Text('Responsável: ${solicitacao['nome_responsavel']}'),
                    
                    const SizedBox(height: 20),
                    if (solicitacao['caminho_imagem'] != null &&
                        solicitacao['caminho_imagem'].isNotEmpty &&
                        File(solicitacao['caminho_imagem']).existsSync())
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Imagem Anexada:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () async {
                              final imagePath = solicitacao['caminho_imagem'];
                              if (imagePath != null && imagePath.isNotEmpty) {
                                try {
                                  await OpenFilex.open(imagePath);
                                } catch (e) {
                                  if (dialogContext.mounted) {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      SnackBar(content: Text('Não foi possível abrir a imagem: $e')),
                                    );
                                  }
                                }
                              }
                            },
                            child: Image.file(
                              File(solicitacao['caminho_imagem']),
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    
                    // Dropdown para Status
                    DropdownButtonFormField<String>(
                      value: currentStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        labelStyle: TextStyle(color: pageThemeColor), // Cor dinâmica
                      ),
                      items: _statusDisponiveis
                          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                          .toList(),
                      onChanged: (newValue) {
                        setStateModal(() {
                          currentStatus = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Dropdown para Prioridade
                    DropdownButtonFormField<String>(
                      value: currentPrioridade,
                      decoration: InputDecoration(
                        labelText: 'Prioridade',
                        labelStyle: TextStyle(color: pageThemeColor), // Cor dinâmica
                      ),
                      items: _prioridadesDisponiveis
                          .map((prioridade) => DropdownMenuItem(value: prioridade, child: Text(prioridade)))
                          .toList(),
                      onChanged: (newValue) {
                        setStateModal(() {
                          currentPrioridade = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: TextButton.styleFrom(foregroundColor: pageThemeColor), // Cor dinâmica
                ),
                ElevatedButton(
                  child: const Text('Salvar Alterações', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    Map<String, dynamic> dadosAtualizados = {
                      'status': currentStatus,
                      'prioridade': currentPrioridade,
                    };
                    await _atualizarSolicitacao(solicitacao['id'], dadosAtualizados);
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: pageThemeColor), // Cor dinâmica
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _atualizarSolicitacao(int solicitacaoId, Map<String, dynamic> dadosAtualizados) async {
    await dbHelper.atualizarSolicitacaoManutencao(solicitacaoId, dadosAtualizados);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação atualizada com sucesso!')),
      );
    }
    _carregarSolicitacoes();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendente':
        return Colors.orange;
      case 'Aprovada':
        return Colors.blueGrey;
      case 'Em Andamento':
        return Colors.blue;
      case 'Concluída':
        return Colors.green;
      case 'Rejeitada':
        return Colors.black;
      case 'Cancelada':
        return Colors.red;
      case 'Não Definida':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gerenciar Manutenções',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: pageThemeColor, // Cor dinâmica
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _solicitacoes.isEmpty
              ? const Center(child: Text('Nenhuma solicitação de manutenção para gerenciar.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _solicitacoes.length,
                  itemBuilder: (context, index) {
                    final solicitacao = _solicitacoes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.build, color: _getStatusColor(solicitacao['status'])),
                        title: Text(solicitacao['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${solicitacao['status']}'),
                            Text('Prioridade: ${solicitacao['prioridade']}'),
                            Text('Solicitado por: ${solicitacao['nome_solicitante']}'),
                            if (solicitacao['nome_responsavel'] != null)
                              Text('Responsável: ${solicitacao['nome_responsavel']}'),
                            Text('Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(solicitacao['data_solicitacao']))}'),
                          ],
                        ),
                        trailing: Icon(Icons.edit, color: pageThemeColor), // Cor dinâmica
                        onTap: () => _mostrarDetalhesEGerenciarSolicitacao(solicitacao),
                      ),
                    );
                  },
                ),
    );
  }
}