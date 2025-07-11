import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class ListarPetsPage extends StatefulWidget {
  const ListarPetsPage({super.key});

  @override
  State<ListarPetsPage> createState() => _ListarPetsPageState();
}

class _ListarPetsPageState extends State<ListarPetsPage> {
  late Future<List<Map<String, dynamic>>> _petsFuture;

  @override
  void initState() {
    super.initState();
    _petsFuture = DatabaseHelper().buscarPetsComDonos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: const Text(
            'Lista de Pets',
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum pet cadastrado.'));
          }

          final pets = snapshot.data!;

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return ListTile(
                leading: const Icon(Icons.pets),
                title: Text(pet['nome_pet']),
                subtitle: Text(
                    'Idade: ${pet['idade']} anos\nCasa do dono: ${pet['casa_dono']}'),
              );
            },
          );
        },
      ),
    );
  }
}
