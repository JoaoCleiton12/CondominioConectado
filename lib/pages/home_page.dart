import 'package:flutter/material.dart';
import 'login_page.dart'; // ajuste o caminho conforme sua estrutura


class HomePage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const HomePage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 85, 216, 80),
        title: const Text('Condomínio Conectado'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Bem-vindo, ${usuario['email']}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Tipo: ${usuario['tipo_usuario']}'),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    print("Opção ${index + 1} selecionada");
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color.fromARGB(255, 85, 216, 80),
                  ),
                  child: Center(
                    child: Text(
                      'Opção ${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
