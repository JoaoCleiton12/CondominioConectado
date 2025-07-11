import 'package:flutter/material.dart';
import '../../../database/database_helper.dart'; // ajuste o caminho conforme sua estrutura

class RedefinirSenhaPage extends StatefulWidget {
  const RedefinirSenhaPage({super.key});

  @override
  State<RedefinirSenhaPage> createState() => _RedefinirSenhaPageState();
}

class _RedefinirSenhaPageState extends State<RedefinirSenhaPage> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _tokenEnviado = false;
  bool _tokenValido = false;

  String? _tokenGerado;

  void _enviarToken() async {
    String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira um e-mail válido')),
      );
      return;
    }

    String? token = await DatabaseHelper().gerarTokenPorEmail(email);
    if (token != null) {
      setState(() {
        _tokenGerado = token;
        _tokenEnviado = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail não encontrado')),
      );
    }
  }

  void _verificarToken() {
    if (_tokenController.text.trim() == _tokenGerado) {
      setState(() {
        _tokenValido = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token inválido')),
      );
    }
  }

  void _redefinirSenha() async {
    String novaSenha = _novaSenhaController.text;
    String confirmarSenha = _confirmarSenhaController.text;

    if (novaSenha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A nova senha deve ter pelo menos 6 caracteres')),
      );
      return;
    }

    if (novaSenha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    bool sucesso = await DatabaseHelper().redefinirSenha(_tokenGerado!, novaSenha);
    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha redefinida com sucesso')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao redefinir senha')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      appBar: AppBar(title: const Text('Redefinir Senha'),
      backgroundColor: const Color.fromARGB(255, 61, 96, 178),
      centerTitle: true,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color.fromARGB(255, 142, 164, 214),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _enviarToken,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 89, 117, 190),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar Token'),
              ),
              if (_tokenEnviado && _tokenGerado != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Token gerado (simulação): $_tokenGerado',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (_tokenEnviado) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Token',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(255, 142, 164, 214),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _verificarToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 89, 117, 190),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Verificar Token'),
                ),
              ],
              if (_tokenValido) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: _novaSenhaController,
                  decoration: const InputDecoration(
                    labelText: 'Nova Senha',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(255, 142, 164, 214),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmarSenhaController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(255, 142, 164, 214),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _redefinirSenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 89, 117, 190),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Redefinir Senha'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
