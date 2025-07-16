import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'package:file_picker/file_picker.dart'; // Para selecionar PDFs/arquivos
import 'dart:io'; // Para File
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:open_filex/open_filex.dart'; // Para abrir arquivos locais
import 'package:url_launcher/url_launcher.dart'; // Para abrir links externos

class AtasPage extends StatefulWidget {
  const AtasPage({super.key});

  @override
  State<AtasPage> createState() => _AtasPageState();
}

class _AtasPageState extends State<AtasPage> with SingleTickerProviderStateMixin {
  // --- Variáveis e Controladores para a Aba de Cadastro ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _linkExternoController = TextEditingController();
  TextEditingController _dataAtaController = TextEditingController(); // Para o campo de data
  File? _arquivoAtaLocal; // Para o arquivo PDF/local
  bool _carregandoCadastro = false;

  // --- Variáveis para o Gerenciamento de Abas e Listagem ---
  late TabController _tabController;
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _atas = [];
  bool _carregandoLista = true;

  // COR DO TEMA DO SÍNDICO
  final Color sindicoThemeColor = const Color.fromARGB(255, 34, 139, 34);
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Cadastrar e Listar

    _tabController.addListener(() {
      if (_tabController.index == 1) { // Se a aba de listagem for selecionada
        _carregarAtas(); // Recarrega a lista
      }
    });

    _carregarAtas(); // Carrega as atas na inicialização para a primeira exibição da lista
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    _linkExternoController.dispose();
    _dataAtaController.dispose();
    super.dispose();
  }

  // Método para selecionar a data da ata
  Future<void> _selecionarDataAta(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dataAtaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Método para selecionar um arquivo local (PDF, etc.)
  Future<void> _selecionarArquivoAta() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'], // Pode adicionar outros tipos de documento
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _arquivoAtaLocal = File(result.files.single.path!);
      });
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo selecionado ou seleção cancelada.')),
        );
      }
    }
  }

  // --- Métodos para a Aba de Cadastro ---
  void _cadastrarAta() async {
    if (!_formKey.currentState!.validate()) return;

    // Deve ter ou link externo ou arquivo local, ou ambos. Pelo menos um é obrigatório.
    if (_linkExternoController.text.isEmpty && _arquivoAtaLocal == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, forneça um link externo ou anexe um arquivo da ata.')),
        );
      }
      return;
    }

    setState(() => _carregandoCadastro = true);

    final ata = {
      'titulo': _tituloController.text.trim(),
      'data_ata': DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateFormat('dd/MM/yyyy').parse(_dataAtaController.text)), // Salva em formato ISO
      'link_externo': _linkExternoController.text.isNotEmpty ? _linkExternoController.text.trim() : null,
      'caminho_arquivo_local': _arquivoAtaLocal?.path,
    };

    try {
      await dbHelper.inserirAta(ata);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ata cadastrada com sucesso!')),
        );
      }
      _tituloController.clear();
      _linkExternoController.clear();
      _dataAtaController.clear();
      setState(() {
        _arquivoAtaLocal = null;
      });

      // Navega para a aba de listagem e recarrega
      _tabController.animateTo(1);
      _carregarAtas();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar ata: $e')),
        );
      }
    } finally {
      setState(() => _carregandoCadastro = false);
    }
  }

  // --- Métodos para a Aba de Listagem ---
  Future<void> _carregarAtas() async {
    setState(() {
      _carregandoLista = true;
    });
    final fetchedAtas = await dbHelper.buscarTodasAtas();
    setState(() {
      _atas = fetchedAtas;
      _carregandoLista = false;
    });
  }

  void _confirmarExcluirAta(int ataId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta ata?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await dbHelper.deletarAta(ataId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ata excluída com sucesso!')),
          );
        }
        _carregarAtas(); // Recarregar a lista após a exclusão
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir ata: $e')),
          );
        }
      }
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

  // --- Widgets das Abas ---
  Widget _buildCadastrarAtaForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título da Ata'),
              validator: (value) => value == null || value.isEmpty ? 'Informe o título da ata' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _dataAtaController,
              decoration: const InputDecoration(
                labelText: 'Data da Ata (DD/MM/AAAA)',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true, // Impede digitação manual
              onTap: () => _selecionarDataAta(context), // Abre o date picker
              validator: (value) => value == null || value.isEmpty ? 'Selecione a data da ata' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _linkExternoController,
              decoration: const InputDecoration(labelText: 'Link Externo da Ata (Opcional)'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _selecionarArquivoAta,
              icon: const Icon(Icons.attach_file),
              label: Text(_arquivoAtaLocal == null
                  ? 'Anexar Arquivo da Ata (Opcional)'
                  : 'Arquivo Anexado: ${_arquivoAtaLocal!.path.split('/').last}'),
            ),
            if (_arquivoAtaLocal != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(Icons.file_present, size: 40, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_arquivoAtaLocal!.path.split('/').last, softWrap: true),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregandoCadastro ? null : _cadastrarAta,
              child: _carregandoCadastro
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Cadastrar Ata'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListarAtas() {
    return _carregandoLista
        ? const Center(child: CircularProgressIndicator())
        : _atas.isEmpty
            ? const Center(child: Text('Nenhuma ata cadastrada.'))
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _atas.length,
                itemBuilder: (context, index) {
                  final ata = _atas[index];
                  // Formatar a data para exibição
                  final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(ata['data_ata']));
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.gavel, color: Color.fromARGB(255, 34, 139, 34)),
                      title: Text(ata['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Data: $formattedDate'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ata['link_externo'] != null && ata['link_externo'].isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.link, color: Colors.blue),
                              tooltip: 'Abrir Link Externo',
                              onPressed: () => _launchUrl(ata['link_externo']),
                            ),
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
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Excluir Ata',
                            onPressed: () => _confirmarExcluirAta(ata['id']),
                          ),
                        ],
                      ),
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
          'Atas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 34, 139, 34),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cadastrar Ata', icon: Icon(Icons.add_box)),
            Tab(text: 'Listar Atas', icon: Icon(Icons.list_alt)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCadastrarAtaForm(),
          _buildListarAtas(),
        ],
      ),
    );
  }
}