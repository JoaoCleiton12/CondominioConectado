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

    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        idade TEXT NOT NULL,
        dono_id INTEGER NOT NULL,
        FOREIGN KEY(dono_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE comunicados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS visitantes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      idade INTEGER NOT NULL,
      morador_id INTEGER NOT NULL,
      FOREIGN KEY(morador_id) REFERENCES usuarios(id)
    );
  ''');

    await db.execute('''
      CREATE TABLE reservas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        area TEXT NOT NULL,
        data TEXT NOT NULL,       -- formato ISO YYYY‑MM‑DD
        turno TEXT NOT NULL,      -- "manhã", "tarde", "noite"
        usuario_id INTEGER NOT NULL,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS visitas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visitante_id INTEGER NOT NULL,
        data_visita TEXT NOT NULL,
        FOREIGN KEY(visitante_id) REFERENCES visitantes(id)
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

//COMUNICADOS----------------------------------------------------------------------------
  Future<int> inserirComunicado(String titulo, String descricao) async {
    final db = await database;

    return await db.insert('comunicados', {
      'titulo': titulo,
      'descricao': descricao,
    });
  }

  Future<List<Map<String, dynamic>>> listarComunicados() async {
  final db = await database;

  return await db.query(
    'comunicados',
    orderBy: 'data_criacao DESC'
  );
  }
//---------------------------------------------------------------------------------------


Future<int> inserirVisitante(Map<String, dynamic> visitante) async {
  final db = await database;
  return await db.insert('visitantes', visitante);
}

Future<List<Map<String, dynamic>>> buscarTodosVisitantesComMorador() async {
  final db = await database;
  return await db.rawQuery('''
    SELECT v.nome AS nome_visitante, v.idade, u.nome AS nome_morador
    FROM visitantes v
    JOIN usuarios u ON v.morador_id = u.id
    ORDER BY v.nome
  ''');
}


Future<int> registrarVisita(Map<String, dynamic> visita) async {
  final db = await database;
  return await db.insert('visitas', visita);
}

Future<List<Map<String, dynamic>>> buscarVisitantesDoMorador(int moradorId) async {
  final db = await database;
  return await db.query(
    'visitantes',
    where: 'morador_id = ?',
    whereArgs: [moradorId],
  );
}

//AREA DE LAZER--------------------------------------------------------------------------
Future<int> inserirReserva(Map<String, dynamic> reserva) async {
  final db = await database;
  return await db.insert('reservas', reserva);
}

Future<List<Map<String, dynamic>>> buscarReservasPorArea(
    String area, String data, String turno) async {
  final db = await database;
  return await db.query(
    'reservas',
    where: 'area = ? AND data = ? AND turno = ?',
    whereArgs: [area, data, turno],
  );
}

Future<List<Map<String, dynamic>>> buscarTodasReservasPorArea(String area) async {
  final db = await database;
  return await db.query('reservas',
      where: 'area = ?', whereArgs: [area]);
}

Future<List<Map<String, dynamic>>> buscarTodasReservasComUsuarios() async {
  final db = await database;
  return await db.rawQuery('''
    SELECT r.id, r.area, r.data, r.turno, u.nome
    FROM reservas r
    JOIN usuarios u ON r.usuario_id = u.id
    ORDER BY r.data DESC
  ''');
}


Future<int> cancelarReserva(int id) async {
  final db = await database;
  return await db.delete('reservas', where: 'id = ?', whereArgs: [id]);
}
//---------------------------------------------------------------------------------------


//Funcionário----------------------------------------------------------------------------
  Future<void> inserirFuncionario(int usuarioId, String cargo) async {
    final db = await database;
    await db.insert('funcionarios', {
      'usuario_id': usuarioId,
      'cargo': cargo,
    });
  }

  Future<List<Map<String, dynamic>>> buscarTodosFuncionarios() async {
  final db = await database;
  return await db.rawQuery('''
    SELECT u.id AS usuario_id, u.nome, u.email, f.cargo
    FROM usuarios u
    INNER JOIN funcionarios f ON u.id = f.usuario_id
    ORDER BY u.nome
  ''');
}

Future<void> deletarFuncionario(int usuarioId) async {
  final db = await database;

  // Remove primeiro da tabela funcionarios (por causa da chave estrangeira)
  await db.delete('funcionarios', where: 'usuario_id = ?', whereArgs: [usuarioId]);

  // Depois remove da tabela usuarios
  await db.delete('usuarios', where: 'id = ?', whereArgs: [usuarioId]);
}

//---------------------------------------------------------------------------------------


//Funcionário----------------------------------------------------------------------------
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

//Pets-----------------------------------------------------------------------------------
  Future<int> inserirPet(String nome, String idade, int donoId) async {
  final db = await database;

  return await db.insert('pets', {
    'nome': nome,
    'idade': idade,
    'dono_id': donoId,
  });
}

Future<List<Map<String, dynamic>>> buscarPetsDoUsuario(int donoId) async {
  final db = await database;
  return await db.query(
    'pets',
    where: 'dono_id = ?',
    whereArgs: [donoId],
    columns: ['nome', 'idade'],
  );
}

  Future<List<Map<String, dynamic>>> buscarPetsComDonos() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT 
        pets.nome AS nome_pet,
        pets.idade,
        usuarios.nome AS nome_dono,
        moradores.casa AS casa_dono
      FROM pets
      JOIN usuarios ON pets.dono_id = usuarios.id
      JOIN moradores ON moradores.usuario_id = usuarios.id
    ''');
  }
//---------------------------------------------------------------------------------------


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
