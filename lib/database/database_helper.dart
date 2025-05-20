import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'condominio.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        senha TEXT NOT NULL,
        tipo_usuario TEXT NOT NULL,
        token_recuperacao TEXT
      )
    ''');

    // Inserindo usuário de teste
    await db.insert('usuarios', {
      'email': 'teste@teste.com',
      'senha': '123456',
      'tipo_usuario': 'morador',
    });
  }

  Future<Map<String, dynamic>?> autenticarUsuario(String email, String senha) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

  /// Gera e armazena um token para o e-mail fornecido, se existir
  Future<String?> gerarTokenPorEmail(String email) async {
    final db = await database;

    final result = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isEmpty) return null;

    final token = _gerarTokenAleatorio();
    await db.update(
      'usuarios',
      {'token_recuperacao': token},
      where: 'email = ?',
      whereArgs: [email],
    );

    return token;
  }

  /// Redefine a senha com base no token informado
  Future<bool> redefinirSenha(String token, String novaSenha) async {
    final db = await database;

    final result = await db.query(
      'usuarios',
      where: 'token_recuperacao = ?',
      whereArgs: [token],
    );

    if (result.isEmpty) return false;

    final id = result.first['id'];
    await db.update(
      'usuarios',
      {
        'senha': novaSenha,
        'token_recuperacao': null, // limpa o token após uso
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    return true;
  }

  /// Gera um token aleatório de 6 dígitos
  String _gerarTokenAleatorio() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
