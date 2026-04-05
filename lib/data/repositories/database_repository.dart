import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/party.dart';
import '../models/transaction.dart';

class DatabaseRepository extends GetxService {
  late Database _db;

  Future<DatabaseRepository> init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'khata.db');
    _db = await openDatabase(
      path,
      version: 2,               // ← bumped from 1 to 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,    // ← new
    );
    return this;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE parties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        phone TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        partyId INTEGER,
        amount REAL,
        type TEXT,
        date TEXT,
        note TEXT,
        category TEXT,
        imagePath TEXT
      )
    ''');
  }

  // Runs only when the DB already exists at an older version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN imagePath TEXT',
      );
    }
  }

  Future<int> addParty(Party party) async {
    return await _db.insert('parties', party.toMap());
  }

  Future<List<Party>> getParties(String type) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'parties',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => Party.fromMap(maps[i]));
  }

  Future<double> getPartyBalance(int partyId) async {
    final given = await _db.rawQuery(
      '''SELECT SUM(amount) as total 
       FROM transactions 
       WHERE partyId = ? AND type = ?''',
      [partyId, 'given'],
    );

    final received = await _db.rawQuery(
      '''SELECT SUM(amount) as total 
       FROM transactions 
       WHERE partyId = ? AND type = ?''',
      [partyId, 'received'],
    );

    double givenTotal = 0.0;
    double receivedTotal = 0.0;

    if (given.isNotEmpty && given.first['total'] != null) {
      givenTotal = (given.first['total'] as num).toDouble();
    }

    if (received.isNotEmpty && received.first['total'] != null) {
      receivedTotal = (received.first['total'] as num).toDouble();
    }

    return givenTotal - receivedTotal;
  }

  Future<double> getNetBalance(String type) async {
    final parties = await getParties(type);
    double net = 0.0;
    for (var party in parties) {
      net += await getPartyBalance(party.id!);
    }
    return net;
  }

  Future<int> addTransaction(AppTransaction txn) async {
    return await _db.insert('transactions', txn.toMap());
  }

  Future<List<AppTransaction>> getTransactions(
      int partyId, {
        String? searchQuery,
      }) async {
    String where = 'partyId = ?';
    List<dynamic> args = [partyId];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where +=
      ' AND (note LIKE ? OR category LIKE ? OR CAST(amount AS TEXT) LIKE ?)';
      args.add('%$searchQuery%');
      args.add('%$searchQuery%');
      args.add('%$searchQuery%');
    }

    final List<Map<String, dynamic>> maps = await _db.query(
      'transactions',
      where: where,
      whereArgs: args,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => AppTransaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(AppTransaction txn) async {
    return await _db.update(
      'transactions',
      txn.toMap(),
      where: 'id = ?',
      whereArgs: [txn.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    return await _db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMonthlyTransactionsReportCurrent(
      DateTime month,
      ) async {
    final start = DateTime(month.year, month.month, 1)
        .toIso8601String()
        .split('T')[0];
    final end = DateTime(month.year, month.month + 1, 0)
        .toIso8601String()
        .split('T')[0];

    final result = await _db.rawQuery(
      '''
    SELECT 
      t.id,
      t.date,
      p.name AS party_name,
      p.type AS party_type,
      t.category,
      t.amount,
      t.type AS transaction_type,
      t.note
    FROM transactions t
    INNER JOIN parties p ON t.partyId = p.id
    WHERE DATE(t.date) BETWEEN ? AND ?
    ORDER BY t.date DESC
  ''',
      [start, end],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsReport() async {
    final result = await _db.rawQuery('''
    SELECT 
      t.id, t.date, t.amount, t.type, t.note, t.category,
      p.name AS party_name, p.type AS party_type, p.phone
    FROM transactions t
    LEFT JOIN parties p ON t.partyId = p.id
    ORDER BY t.date DESC
  ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTransactionsReport(
      DateTime month,
      ) async {
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
      999,
    ).toIso8601String();

    final result = await _db.rawQuery('''
    SELECT 
      t.id,
      t.date,
      p.name AS party_name,
      p.type AS party_type,
      t.category,
      t.amount,
      t.type AS transaction_type,
      t.note
    FROM transactions t
    INNER JOIN parties p ON t.partyId = p.id
    WHERE t.date >= ? AND t.date < ?
    ORDER BY t.date DESC
  ''', [start, end]);

    return result;
  }

  Future<void> deleteParty(int id) async {
    await _db.delete('parties', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTransactionsByPartyId(int partyId) async {
    await _db.delete(
      'transactions',
      where: 'partyId = ?',
      whereArgs: [partyId],
    );
  }
}