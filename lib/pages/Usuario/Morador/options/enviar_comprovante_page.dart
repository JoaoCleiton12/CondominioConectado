import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'package:flutter/services.dart'; // Importe esta linha para usar Clipboard

class EnviarComprovantePage extends StatefulWidget {
  const EnviarComprovantePage({super.key});

  @override
  State<EnviarComprovantePage> createState() => _EnviarComprovantePageState();
}

class _EnviarComprovantePageState extends State<EnviarComprovantePage> with SingleTickerProviderStateMixin {
  // --- Variáveis e Controladores para a Aba de Envio ---
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _comentarioController = TextEditingController();
  String? _mesSelecionado;
  String? _tipoSelecionado;
  File? _comprovante; // Agora pode ser imagem ou PDF

  final List<String> _meses = List.generate(12, (index) {
    return DateFormat('MMMM yyyy').format(DateTime(DateTime.now().year, index + 1));
  });
  final List<String> _tipos = ['Condomínio', 'Água', 'Taxa Extra'];

  // --- Dados Bancários Fixos (para demonstração) ---
  final String _nomeBanco = 'Banco do Condomínio S.A.';
  final String _agencia = '0001';
  final String _contaCorrente = '123456-7';
  final String _nomeFavorecido = 'Condomínio XYZ';
  final String _cnpjFavorecido = 'XX.XXX.XXX/YYYY-ZZ';
  final String _chavePix = 'seupix@email.com.br'; // Exemplo: pode ser CPF/CNPJ, e-mail, telefone, chave aleatória
  // --- Fim dos Dados Bancários Fixos ---


  // --- Variáveis e Controladores para o Gerenciamento de Abas e Dados ---
  late TabController _tabController;
  final dbHelper = DatabaseHelper();
  // --- Fim das Variáveis de Gerenciamento ---


  @override
  void initState() {
    super.initState();
    // Inicializa o TabController com 3 abas agora
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Descarte os controladores quando o widget for removido da árvore
    _tabController.dispose();
    _valorController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  // --- Métodos para a Aba de Envio de Comprovante ---

  /// Permite ao usuário selecionar uma imagem ou PDF da galeria/arquivos.
  Future<void> _selecionarComprovante() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _comprovante = File(result.files.single.path!);
      });
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo selecionado ou seleção cancelada.')),
        );
      }
    }
  }

  /// Envia o comprovante para o banco de dados.
  Future<void> _enviarComprovante() async {
    if (!_formKey.currentState!.validate() || _comprovante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e anexe o comprovante.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final moradorId = prefs.getInt('usuario_id');
    if (moradorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID do morador não encontrado. Faça login novamente.')),
      );
      return;
    }

    final comprovante = {
      'morador_id': moradorId,
      'mes_referencia': _mesSelecionado,
      'valor': double.parse(_valorController.text.trim()),
      'tipo': _tipoSelecionado,
      'caminho_arquivo': _comprovante!.path,
      'status': 'pendente',
      'comentario': _comentarioController.text.trim(),
      'data_envio': DateTime.now().toIso8601String(),
    };

    await dbHelper.inserirComprovante(comprovante);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comprovante enviado com sucesso!')),
    );
    _valorController.clear();
    _comentarioController.clear();
    setState(() {
      _mesSelecionado = null;
      _tipoSelecionado = null;
      _comprovante = null;
    });

    // Mudar para a aba "Meus Comprovantes" (agora índice 2) após o envio bem-sucedido
    _tabController.animateTo(2); // Ajustado para o novo índice da aba "Meus Comprovantes"
  }

  /// Copia o texto para a área de transferência e mostra um SnackBar.
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiado!')),
    );
  }

  // --- Métodos para a Aba de Listagem de Meus Comprovantes ---
  Future<List<Map<String, dynamic>>> _getComprovantesDoMorador() async {
    final prefs = await SharedPreferences.getInstance();
    final moradorId = prefs.getInt('usuario_id');
    if (moradorId == null) {
      return [];
    }
    return await dbHelper.buscarComprovantesPorMorador(moradorId);
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

  void _mostrarDetalhesComprovanteMorador(Map<String, dynamic> comprovante) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalhes do Seu Comprovante'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Mês de Referência: ${comprovante['mes_referencia']}'),
                Text('Tipo: ${comprovante['tipo']}'),
                Text('Valor: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(comprovante['valor'])}'),
                Text('Status: ${comprovante['status']}'),
                Text('Comentário: ${comprovante['comentario'] ?? 'Nenhum'}'),
                Text('Data de Envio: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(comprovante['data_envio']))}'),
                const SizedBox(height: 20),
                if (comprovante['caminho_arquivo'] != null &&
                    File(comprovante['caminho_arquivo']).existsSync())
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Comprovante Anexado:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      if (comprovante['caminho_arquivo'].toLowerCase().endsWith('.pdf'))
                        const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red)
                      else
                        Image.file(
                          File(comprovante['caminho_arquivo']),
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                    ],
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

  // --- Widgets das Abas ---

  /// Constrói o formulário para emitir um novo débito.
  Widget _buildEmitirDebitosForm() { // Renomeado de _buildEnviarComprovanteForm
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Preencher e Emitir Débito', // Título atualizado
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 61, 96, 178),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _mesSelecionado,
              items: _meses
                  .map((mes) => DropdownMenuItem(
                        value: mes,
                        child: Text(mes),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _mesSelecionado = value),
              decoration: const InputDecoration(labelText: 'Mês de Referência'),
              validator: (value) => value == null ? 'Selecione o mês' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Valor do Débito (R\$)'), // Label atualizado
              validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o valor' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              items: _tipos
                  .map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _tipoSelecionado = value),
              decoration: const InputDecoration(labelText: 'Tipo de Débito'),
              validator: (value) => value == null ? 'Selecione o tipo' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _comentarioController,
              decoration: const InputDecoration(labelText: 'Comentário (opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _selecionarComprovante,
              icon: const Icon(Icons.attach_file),
              label: Text(_comprovante == null
                  ? 'Anexar Comprovante (Opcional)' // Texto atualizado, já que agora é um 'débito' que o morador vai enviar comprovante
                  : 'Comprovante Anexado (${_comprovante!.path.split('/').last})'),
            ),
            if (_comprovante != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _comprovante!.path.toLowerCase().endsWith('.pdf')
                    ? const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red)
                    : Image.file(_comprovante!, height: 150),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviarComprovante,
              child: const Text(
                'Emitir Débito', // Texto atualizado
                style: TextStyle(
                  color: Color.fromARGB(255, 61, 96, 178),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a lista dos comprovantes enviados pelo morador.
  Widget _buildListarMeusComprovantes() {
    return Builder(
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getComprovantesDoMorador(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar comprovantes: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Você não enviou nenhum comprovante ainda.'));
            } else {
              final meusComprovantes = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: meusComprovantes.length,
                itemBuilder: (context, index) {
                  final comprovante = meusComprovantes[index];
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
                          Text('Valor: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(comprovante['valor'])}'),
                          Text('Status: ${comprovante['status']}'),
                          Text('Enviado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(comprovante['data_envio']))}'),
                          if (comprovante['comentario'] != null && comprovante['comentario'].isNotEmpty)
                            Text('Comentário: ${comprovante['comentario']}'),
                        ],
                      ),
                      onTap: () {
                         _mostrarDetalhesComprovanteMorador(comprovante);
                      },
                    ),
                  );
                },
              );
            }
          },
        );
      }
    );
  }

  /// Constrói a tela com os dados bancários e chave PIX para cópia.
  Widget _buildDadosParaPagamento() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'Dados para Pagamento',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 61, 96, 178),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          // Dados da Conta Bancária
          _buildCopyableField('Banco', _nomeBanco, _nomeBanco),
          _buildCopyableField('Agência', _agencia, _agencia),
          _buildCopyableField('Conta Corrente', _contaCorrente, _contaCorrente),
          _buildCopyableField('Favorecido', _nomeFavorecido, _nomeFavorecido),
          _buildCopyableField('CNPJ/CPF', _cnpjFavorecido, _cnpjFavorecido),
          const SizedBox(height: 30),

          // Chave PIX
          const Text(
            'Chave PIX',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 61, 96, 178),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          _buildCopyableField('PIX', _chavePix, _chavePix),
          const SizedBox(height: 20),
          
          const Text(
            'Copie os dados desejados e utilize-os para fazer seu pagamento.',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget auxiliar para criar um campo com valor e botão de copiar
  Widget _buildCopyableField(String label, String value, String textToCopy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 17),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 22),
            color: Colors.grey[700],
            onPressed: () => _copyToClipboard(textToCopy, label),
            tooltip: 'Copiar $label',
          ),
        ],
      ),
    );
  }


  // --- Método Build Principal ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Débitos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            // Nova ordem das abas: Dados para Pagamento primeiro
            Tab(text: 'Dados para Pagamento', icon: Icon(Icons.account_balance)),
            Tab(text: 'Emitir Débitos', icon: Icon(Icons.post_add)), // Texto e ícone atualizados
            Tab(text: 'Meus Comprovantes', icon: Icon(Icons.list_alt)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // A ordem dos children deve corresponder à ordem das tabs
          _buildDadosParaPagamento(),       // Conteúdo da primeira aba
          _buildEmitirDebitosForm(),        // Conteúdo da segunda aba (renomeado)
          _buildListarMeusComprovantes(),   // Conteúdo da terceira aba
        ],
      ),
    );
  }
}