import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transacao.dart';

class DBHelper {
  static const _nomeBanco = 'gestor.db';
  static const _versaoBanco = 1;


  static Future<Database> _abrirBanco() async {
    final path = join(await getDatabasesPath(), _nomeBanco);
    return openDatabase(
      path,
      version: _versaoBanco,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT,
            categoria TEXT,
            valor REAL,
            descricao TEXT,
            data TEXT
          )
        ''');
      },
    );
  }


  static Future<int> inserirTransacao(Transacao transacao) async {
    final db = await _abrirBanco();
    return db.insert('transacoes', transacao.toMap());
  }


  static Future<List<Transacao>> obterTransacoes() async {
    final db = await _abrirBanco();
    final maps = await db.query('transacoes', orderBy: 'data DESC');
    return maps.map((map) => Transacao.fromMap(map)).toList();
  }


  static Future<int> deletarTransacao(int id) async {
    final db = await _abrirBanco();
    return db.delete('transacoes', where: 'id = ?', whereArgs: [id]);
  }


  static Future<int> atualizarTransacao(Transacao transacao) async {
    final db = await _abrirBanco();
    return db.update(
      'transacoes',
      transacao.toMap(),
      where: 'id = ?',
      whereArgs: [transacao.id],
    );
  }
}
