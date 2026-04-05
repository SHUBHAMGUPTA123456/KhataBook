// lib/repositories/transaction_repository.dart

import 'package:get/get.dart';
import '../models/transaction.dart';
import 'database_helper.dart';

class TransactionRepository extends GetxService {
  final DatabaseHelper dbHelper = Get.find();

  Future<int> insertTransaction(AppTransaction transaction) async {
    return await dbHelper.addTransaction(transaction);
  }

  Future<List<AppTransaction>> getTransactionsByParty(int partyId, {String? searchQuery}) async {
    return await dbHelper.getTransactions(partyId, searchQuery: searchQuery);
  }

  Future<int> updateTransaction(AppTransaction transaction) async {
    return await dbHelper.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(int id) async {
    return await dbHelper.deleteTransaction(id);
  }

  Future<List<Map<String, dynamic>>> getMonthlyReportByCategory(DateTime month) async {
    return await dbHelper.getMonthlyReportByCategory(month);
  }
}