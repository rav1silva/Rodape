import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Banco SQLite local: catálogo de livros, lista de desejos e fila de envio.
class LocalDb {
  static Database? _db;

  static Future<Database> get db async => _db ??= await _abrir();

  static Future<Database> _abrir() async {
    final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    if (desktop) {
      sqfliteFfiInit();
      final dir = await databaseFactoryFfi.getDatabasesPath();
      return databaseFactoryFfi.openDatabase(
        p.join(dir, 'rodape.db'),
        options: OpenDatabaseOptions(version: 1, onCreate: _criar),
      );
    }

    final dir = await mobile.getDatabasesPath();
    return mobile.openDatabase(
      p.join(dir, 'rodape.db'),
      version: 1,
      onCreate: _criar,
    );
  }

  static Future<void> _criar(Database db, int version) async {
    await db.execute('''
      CREATE TABLE livros (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        autor TEXT NOT NULL,
        descricao TEXT,
        isbn TEXT,
        capa_url TEXT,
        cor_lombada TEXT
      )''');

    await db.execute('''
      CREATE TABLE desejos (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        livro_id TEXT NOT NULL,
        posicao INTEGER NOT NULL DEFAULT 0
      )''');

    // Alterações feitas offline, na ordem, esperando para ir ao Supabase.
    await db.execute('''
      CREATE TABLE fila (
        seq INTEGER PRIMARY KEY AUTOINCREMENT,
        op TEXT NOT NULL,
        payload TEXT NOT NULL
      )''');
  }
}