import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:image_picker/image_picker.dart'; // Importe para selecionar imagem
import 'dart:io'; // Para File e File.existsSync
import 'package:open_filex/open_filex.dart'; // Para abrir o arquivo clicável

class SolicitacaoManutencaoPage extends StatefulWidget {
  final String userType; // Para saber o tipo de usuário que acessa a tela
  const SolicitacaoManutencaoPage({super.key, required this.userType});

  @override
  State<SolicitacaoManutencaoPage> createState() => _SolicitacaoManutencaoPageState();
}

class _SolicitacaoManutencaoPageState extends State<SolicitacaoManutencaoPage> with SingleTickerProviderStateMixin {
  // --- Variáveis e Controladores para a Aba de Nova Solicitação ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _carregandoCadastro = false;
  File? _imagemAnexada;
  final ImagePicker _picker = ImagePicker();

  // --- Variáveis para o Gerenciamento de Abas e Listagem ---
  late TabController _tabController;
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _solicitacoes = [];
  bool _carregandoLista = true;
  int? _currentUserId; // Para filtrar minhas solicitações

  // Lista de status disponíveis para atualização (para funcionário/síndico)
  final List<String> _statusParaAtualizacao = ['Pendente', 'Em Andamento', 'Concluída', 'Cancelada'];

  // CORES DO TEMA DINÂMICAS
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

    // O número de abas depende do tipo de usuário
    _tabController = TabController(length: widget.userType == 'morador' ? 2 : 1, vsync: this);

    _getUserId(); // Busca o ID do usuário logado

    _tabController.addListener(() {
      // Recarrega a lista se a aba de listagem (índice 1) for selecionada,
      // e apenas se for morador (que tem 2 abas)
      if (widget.userType == 'morador' && _tabController.index == 1) {
        _carregarSolicitacoes();
      }
    });

    // Se for morador, já carrega as solicitações para a possível aba de listagem.
    // Se não for morador, não há necessidade de carregar solicitacoes na inicialização
    // desta página, pois a aba de listagem não estará visível para eles.
    if (widget.userType == 'morador') {
      _carregarSolicitacoes();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Verifica se o widget ainda está montado antes de chamar setState
    if (mounted) {
      setState(() {
        _currentUserId = prefs.getInt('usuario_id');
      });
    }
  }

  Future<void> _selecionarImagem() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);
    // Verifica se o widget ainda está montado antes de chamar setState
    if (mounted) {
      if (imagem != null) {
        setState(() {
          _imagemAnexada = File(imagem.path);
        });
      } else {
        // Verifica se o widget ainda está montado antes de usar ScaffoldMessenger
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhuma imagem selecionada.')),
          );
        }
      }
    }
  }

  void _enviarSolicitacao() async {
    if (!_formKey.currentState!.validate()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos.')),
        );
      }
      return;
    }

    if (_currentUserId == null) { // Não precisa do context.mounted aqui se a chamada é imediatamente seguida por um return
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não identificado para criar a solicitação.')),
        );
      }
      return;
    }

    // Verifica se o widget ainda está montado antes de chamar setState inicial
    if (!mounted) return;
    setState(() => _carregandoCadastro = true);

    final solicitacao = {
      'titulo': _tituloController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      'prioridade': 'Não Definida',
      'status': 'Pendente',
      'usuario_id': _currentUserId!,
      'caminho_imagem': _imagemAnexada?.path,
    };

    try {
      await dbHelper.inserirSolicitacaoManutencao(solicitacao);

      // Verifica se o widget ainda está montado antes de usar ScaffoldMessenger
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação de manutenção enviada com sucesso!')),
        );
      }
      _tituloController.clear();
      _descricaoController.clear();
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _imagemAnexada = null;
        });
      }

      if (widget.userType == 'morador') {
        _tabController.animateTo(1);
        _carregarSolicitacoes();
      } else {
        if (context.mounted) { // Verifica se o widget ainda está montado antes de usar Navigator
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (context.mounted) { // Verifica se o widget ainda está montado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar solicitação: $e')),
        );
      }
    } finally {
      // Verifica se o widget ainda está montado antes de chamar setState
      if (mounted) {
        setState(() => _carregandoCadastro = false);
      }
    }
  }

  void _mostrarDetalhesSolicitacao(Map<String, dynamic> solicitacao) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? currentStatus = solicitacao['status'];

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(solicitacao['titulo']),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Descrição: ${solicitacao['descricao']}'),
                    Text('Prioridade: ${solicitacao['prioridade']}'),
                    Text('Status: ${solicitacao['status']}'),
                    Text('Solicitado por: ${solicitacao['nome_solicitante']}'),
                    Text('Data da Solicitação: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(solicitacao['data_solicitacao']))}'),
                    if (solicitacao['nome_responsavel'] != null)
                      Text('Responsável: ${solicitacao['nome_responsavel']}'),
                    if (solicitacao['data_conclusao'] != null)
                      Text('Data de Conclusão: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(solicitacao['data_conclusao']))}'),
                    
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
                                  if (dialogContext.mounted) { // Usando dialogContext
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
                    
                    if (widget.userType == 'sindico' || widget.userType == 'funcionario')
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: currentStatus,
                            decoration: InputDecoration(
                              labelText: 'Mudar Status',
                              labelStyle: TextStyle(color: pageThemeColor), // Cor dinâmica
                            ),
                            items: _statusParaAtualizacao
                                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                .toList(),
                            onChanged: (newValue) {
                              setStateModal(() { // Usa setStateModal para atualizar o estado do diálogo
                                currentStatus = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Fechar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: TextButton.styleFrom(foregroundColor: pageThemeColor), // Cor dinâmica
                ),
                if ((widget.userType == 'sindico' || widget.userType == 'funcionario') && currentStatus != solicitacao['status'])
                  ElevatedButton(
                    child: const Text('Salvar Status', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      if (currentStatus != null) {
                        await _atualizarSolicitacao(solicitacao['id'], {'status': currentStatus});
                        Navigator.of(dialogContext).pop();
                      }
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

  Future<void> _carregarSolicitacoes() async {
    if (_currentUserId == null) return;

    // Verifica se o widget ainda está montado antes de chamar setState inicial
    if (!mounted) return;
    setState(() {
      _carregandoLista = true;
    });

    List<Map<String, dynamic>> fetchedSolicitacoes;
    if (widget.userType == 'morador') {
      fetchedSolicitacoes = await dbHelper.buscarTodasSolicitacoesManutencao();
    }
    else {
      fetchedSolicitacoes = await dbHelper.buscarSolicitacoesManutencaoPorUsuario(_currentUserId!);
    }

    // Verifica se o widget ainda está montado antes de chamar setState final
    if (mounted) {
      setState(() {
        _solicitacoes = fetchedSolicitacoes;
        _carregandoLista = false;
      });
    }
  }

  Future<void> _atualizarSolicitacao(int solicitacaoId, Map<String, dynamic> dadosAtualizados) async {
    await dbHelper.atualizarSolicitacaoManutencao(solicitacaoId, dadosAtualizados);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação atualizada com sucesso!')),
      );
    }
    // _carregarSolicitacoes() já tem sua própria verificação de 'mounted'
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

  Widget _buildNovaSolicitacaoForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título da Solicitação',
                labelStyle: TextStyle(color: pageThemeColor), // Cor dinâmica
              ),
              validator: (value) => value == null || value.isEmpty ? 'Informe o título' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição Detalhada',
                labelStyle: TextStyle(color: pageThemeColor), // Cor dinâmica
              ),
              maxLines: 4,
              validator: (value) => value == null || value.isEmpty ? 'Descreva o problema' : null,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _selecionarImagem,
              icon: Icon(Icons.image, color: Colors.white),
              label: Text(_imagemAnexada == null
                  ? 'Anexar Imagem (Opcional)'
                  : 'Imagem Anexada (${_imagemAnexada!.path.split('/').last})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: pageThemeColor, // Cor dinâmica
                foregroundColor: Colors.white,
              ),
            ),
            if (_imagemAnexada != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.file(
                  _imagemAnexada!,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregandoCadastro ? null : _enviarSolicitacao,
              child: _carregandoCadastro
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enviar Solicitação', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: pageThemeColor, // Cor dinâmica
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListagemSolicitacoes() {
    return _currentUserId == null
        ? const Center(child: CircularProgressIndicator())
        : _carregandoLista
            ? const Center(child: CircularProgressIndicator())
            : _solicitacoes.isEmpty
                ? Center(
                    child: Text(
                      widget.userType == 'morador'
                          ? 'Nenhuma solicitação de manutenção encontrada.'
                          : 'Você não tem solicitações de manutenção.',
                    ),
                  )
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
                          trailing: Icon(Icons.arrow_forward_ios, color: pageThemeColor), // Cor dinâmica
                          onTap: () => _mostrarDetalhesSolicitacao(solicitacao),
                        ),
                      );
                    },
                  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manutenção',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: pageThemeColor, // Cor dinâmica
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Nova Solicitação', icon: Icon(Icons.add_task)),
            if (widget.userType == 'morador')
              const Tab(text: 'Solicitações', icon: Icon(Icons.list_alt)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNovaSolicitacaoForm(),
          if (widget.userType == 'morador')
            _buildListagemSolicitacoes(),
        ],
      ),
    );
  }
}