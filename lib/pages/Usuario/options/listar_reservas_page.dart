import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class ListarReservasPage extends StatefulWidget {
  const ListarReservasPage({super.key});

  @override
  State<ListarReservasPage> createState() => _ListarReservasPageState();
}

class _ListarReservasPageState extends State<ListarReservasPage> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> _reservas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar reservas: $e')),
      );
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
        backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _reservas.isEmpty
              ? const Center(child: Text('Nenhuma reserva encontrada.'))
              : ListView.builder(
                  itemCount: _reservas.length,
                  itemBuilder: (context, index) {
                    final r = _reservas[index];
                    return ListTile(
                      leading: const Icon(Icons.event_available, color: Colors.green),
                      title: Text('${r['area']} - ${r['turno']}'),
                      subtitle: Text('Data: ${r['data']} | Por: ${r['nome']}'),
                    );
                  },
                ),
    );
  }
}
