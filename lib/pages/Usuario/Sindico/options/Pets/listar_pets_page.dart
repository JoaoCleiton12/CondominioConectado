import 'package:flutter/material.dart';
import 'package:condomonioconectado/database/database_helper.dart';

class ListarPetsPage extends StatefulWidget {
  const ListarPetsPage({super.key});

  @override
  State<ListarPetsPage> createState() => _ListarPetsPageState();
}

class _ListarPetsPageState extends State<ListarPetsPage> {
  late Future<List<Map<String, dynamic>>> _petsFuture;

  // COR DO TEMA DO SÍNDICO
  final Color sindicoThemeColor = const Color.fromARGB(255, 34, 139, 34); // VERDE

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
        backgroundColor: sindicoThemeColor, // Corrigido
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
            padding: const EdgeInsets.all(8.0),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return Card( // Adicionado Card para melhor visual
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.pets, color: sindicoThemeColor), // Corrigido
                  title: Text(pet['nome_pet'], style: const TextStyle(fontWeight: FontWeight.bold)), // Adicionado negrito
                  subtitle: Text(
                      'Idade: ${pet['idade']} | Dono: ${pet['nome_dono']} (Casa: ${pet['casa_dono']})'), // Melhorado o subtítulo
                ),
              );
            },
          );
        },
      ),
    );
  }
}