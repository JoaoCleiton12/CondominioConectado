import 'package:shared_preferences/shared_preferences.dart';
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
        nome TEXT,
        telefone TEXT,
        email TEXT NOT NULL,
        senha TEXT NOT NULL,
        tipo_usuario TEXT NOT NULL,
        token_recuperacao TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE moradores (
        usuario_id INTEGER PRIMARY KEY,
        casa TEXT NOT NULL,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE funcionarios (
        usuario_id INTEGER PRIMARY KEY,
        cargo TEXT NOT NULL,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
      )
    ''');

    // Usuários de teste
    await db.insert('usuarios', {
      'nome': 'Joao',
      'telefone': '0000-0000',
      'email': 'teste@teste.com',
      'senha': '123456',
      'tipo_usuario': 'sindico',
    });
  }

  // INSERIR USUARIO, RETORNANDO O ID GERADO
  Future<int> inserirUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario);
  }

  // INSERIR MORADOR USANDO O ID DO USUARIO
  Future<int> inserirMorador(int usuarioId, String casa) async {
    final db = await database;
    return await db.insert('moradores', {
      'usuario_id': usuarioId,
      'casa': casa,
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
        'token_recuperacao': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    return true;
  }

Future<List<Map<String, dynamic>>> buscarTodosMoradores() async {
  final db = await database;
  return await db.rawQuery('''
    SELECT u.id AS usuario_id, u.nome, u.email, u.telefone, u.senha, u.tipo_usuario, u.token_recuperacao, m.casa
    FROM usuarios u
    INNER JOIN moradores m ON u.id = m.usuario_id
  ''');
}


Future<void> deletarMorador(int usuarioId) async {
  final db = await database;
  await db.delete('moradores', where: 'usuario_id = ?', whereArgs: [usuarioId]);
  await db.delete('usuarios', where: 'id = ?', whereArgs: [usuarioId]);
}



    /// Verifica se já existe um usuário com o email informado
  Future<bool> emailExiste(String email) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<bool> verificarSenhaUsuarioLogado(String senhaInformada) async {
    final db = await database;

    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id'); // ou o nome que você usou para salvar

    if (usuarioId == null) return false;

    final result = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );

    if (result.isEmpty) return false;

    final senhaAtual = result.first['senha'] as String;

    return senhaAtual == senhaInformada;
  }
  
  String _gerarTokenAleatorio() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
