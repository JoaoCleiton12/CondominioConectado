import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';
import 'package:intl/intl.dart';

class ListarReservasPage extends StatefulWidget {
  final String userType; // NOVO: Campo para receber o tipo de usuário
  const ListarReservasPage({super.key, required this.userType}); // NOVO: Construtor com userType

  @override
  State<ListarReservasPage> createState() => _ListarReservasPageState();
}

class _ListarReservasPageState extends State<ListarReservasPage> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> _reservas = [];
  bool _carregando = true;

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
    _carregarReservas();
  }

  Future<void> _carregarReservas() async {
    try {
      final reservas = await db.buscarTodasReservasComUsuarios();
      setState(() {
        _reservas = reservas;
        _carregando = false;
      });
    } catch (e) {
      if (context.mounted) { // Garante que o contexto ainda está montado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar reservas: $e')),
        );
      }
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Reservas Realizadas',
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
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _reservas.isEmpty
              ? const Center(child: Text('Nenhuma reserva encontrada.'))
              : RefreshIndicator( // Adicionado RefreshIndicator para pull-to-refresh
                  onRefresh: _carregarReservas,
                  color: pageThemeColor, // Cor do indicador de refresh
                  child: ListView.builder(
                    itemCount: _reservas.length,
                    itemBuilder: (context, index) {
                      final r = _reservas[index];
                      return Card( // Adicionado Card para melhor visual
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(Icons.event_available, color: pageThemeColor), // Cor dinâmica
                          title: Text('${r['area']} - ${r['turno']}', style: const TextStyle(fontWeight: FontWeight.bold)), // Negrito no título
                          subtitle: Text('Data: ${r['data']} | Por: ${r['nome']}'),
                          // Você pode adicionar um onTap se houver detalhes da reserva para mostrar
                          // onTap: () { /* Navegar para tela de detalhes da reserva */ },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}