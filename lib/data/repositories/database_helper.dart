// lib/repositories/database_helper.dart

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/party.dart';
import '../models/transaction.dart';

class DatabaseHelper extends GetxService {
  late Database _db;

  Future<DatabaseHelper> init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'khata.db');

    _db = await openDatabase(
      path,
      version: 2, // bumped from 1 → 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // NEW
    );
    return this;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE parties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
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
    imagePath TEXT          -- NEW: local path to attached image
  )
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN imagePath TEXT');
    }
  }

  // === PARTY METHODS ===
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

  // === TRANSACTION METHODS (THESE WERE MISSING!) ===
  Future<int> addTransaction(AppTransaction transaction) async {
    return await _db.insert('transactions', transaction.toMap());
  }

  Future<List<AppTransaction>> getTransactions(
    int partyId, {
    String? searchQuery,
  }) async {
    String where = 'partyId = ?';
    List<dynamic> args = [partyId];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where += ' AND (note LIKE ? OR category LIKE ?)';
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

  Future<int> updateTransaction(AppTransaction transaction) async {
    return await _db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    return await _db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // === BALANCE CALCULATIONS ===
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

    double givenTotal = (given.first['total'] as num?)?.toDouble() ?? 0.0;
    double receivedTotal = (received.first['total'] as num?)?.toDouble() ?? 0.0;

    // Positive = Customer owes you (Due), Negative = You owe (Advance)
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

  // === REPORT ===
  Future<List<Map<String, dynamic>>> getMonthlyReportByCategory(
    DateTime month,
  ) async {
    String start = DateTime(
      month.year,
      month.month,
      1,
    ).toIso8601String().split('T').first;
    String end = DateTime(
      month.year,
      month.month + 1,
      0,
    ).toIso8601String().split('T').first;

    return await _db.rawQuery(
      '''SELECT category, SUM(amount) as total 
         FROM transactions 
         WHERE date >= ? AND date <= ? 
         GROUP BY category''',
      [start, end],
    );
  }
}
