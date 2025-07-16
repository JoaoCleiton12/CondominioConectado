import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class ReservarAreaPage extends StatefulWidget {
  final String userType; // NOVO: Campo para receber o tipo de usuário
  const ReservarAreaPage({super.key, required this.userType}); // NOVO: Construtor com userType

  @override
  State<ReservarAreaPage> createState() => _ReservarAreaPageState();
}

class _ReservarAreaPageState extends State<ReservarAreaPage> {
  final _formKey = GlobalKey<FormState>();
  String? _areaSelecionada;
  DateTime? _dataSelecionada;
  String? _turnoSelecionado;

  final db = DatabaseHelper();

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
  }

  Future<void> _selecionarData() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) { // Define o tema do DatePicker com a cor da página
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: pageThemeColor,
            colorScheme: ColorScheme.light(primary: pageThemeColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  void _reservar() async {
    if (!_formKey.currentState!.validate() || _dataSelecionada == null) {
      if (context.mounted) { // Garante que o contexto ainda está montado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos e selecione uma data')),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id');
    if (usuarioId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não autenticado.')),
        );
      }
      return;
    }

    final data = _dataSelecionada!.toIso8601String().split('T').first;

    // Verificar se já há reserva para mesma área, data E turno
    final reservas = await db.buscarReservasPorArea(_areaSelecionada!, data, _turnoSelecionado!);
    if (reservas.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este turno já está reservado para essa área.')),
        );
      }
      return;
    }

    final reserva = {
      'area': _areaSelecionada,
      'data': data,
      'turno': _turnoSelecionado,
      'usuario_id': usuarioId,
    };

    await db.inserirReserva(reserva);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva realizada com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Reservar Espaço',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Área',
                  labelStyle: TextStyle(color: pageThemeColor), // Cor dinâmica
                ),
                value: _areaSelecionada,
                items: const [
                  DropdownMenuItem(value: 'Piscina', child: Text('Piscina')),
                  DropdownMenuItem(value: 'Quadra Esportiva', child: Text('Quadra Esportiva')),
                  DropdownMenuItem(value: 'Área de Lazer', child: Text('Área de Lazer')),
                ],
                onChanged: (value) {
                  setState(() {
                    _areaSelecionada = value;
                  });
                },
                validator: (value) => value == null ? 'Selecione a área' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: _dataSelecionada == null
                      ? 'Selecione uma data'
                      : 'Data selecionada: ${_dataSelecionada!.toLocal().toString().split(' ')[0]}',
                  labelStyle: TextStyle(color: pageThemeColor), // Cor dinâmica
                  suffixIcon: Icon(Icons.calendar_today, color: pageThemeColor), // Cor dinâmica
                ),
                onTap: _selecionarData,
                validator: (value) => _dataSelecionada == null ? 'Selecione a data' : null, // Valida a data selecionada
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Turno',
                  labelStyle: TextStyle(color: pageThemeColor), // Cor dinâmica
                ),
                value: _turnoSelecionado,
                items: const [
                  DropdownMenuItem(value: 'manhã', child: Text('Manhã')),
                  DropdownMenuItem(value: 'tarde', child: Text('Tarde')),
                  DropdownMenuItem(value: 'noite', child: Text('Noite')),
                ],
                onChanged: (value) {
                  setState(() {
                    _turnoSelecionado = value;
                  });
                },
                validator: (value) => value == null ? 'Selecione o turno' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _reservar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pageThemeColor, // Cor dinâmica
                ),
                child: const Text('Reservar',
                  style: TextStyle(
                    color: Colors.white, // Texto do botão branco
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}