import 'package:condomonioconectado/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'pages/Usuario/login_page.dart';

void main() async{
  runApp(const MyApp());

/*
  Comandos para resetar o bd

  adb shell
  run-as com.example.condomonioconectado
  cd databases
  rm condominio.db*
*/
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Condomínio App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
