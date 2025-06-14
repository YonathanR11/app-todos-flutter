import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBDatasource {
  static final LocalDBDatasource _instance = LocalDBDatasource._internal();

  factory LocalDBDatasource() => _instance;

  LocalDBDatasource._internal();

  static Database? _database;

  String? _dbPath;

  /// Inicializa la base de datos (llámalo desde el main antes de usar)
  Future<void> init() async {
    if (_database != null) return;

    final path = join(await getDatabasesPath(), 'app_database.db');
    _dbPath = path; // <- Guarda la ruta
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  String get databasePath {
    if (_dbPath == null) {
      throw Exception('DB not initialized. Call init() first.');
    }
    return _dbPath!;
  }

  /// Devuelve la instancia activa de la base de datos
  Future<Database> get database async {
    if (_database == null) {
      throw Exception(
        'DB not initialized. Call LocalDBDatasource().init() first.',
      );
    }
    return _database!;
  }

  /// Crea las tablas al crear la base de datos
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE todos (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      done INTEGER NOT NULL
    )
  ''');
  }

  /// Cierra la base de datos (opcional)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
