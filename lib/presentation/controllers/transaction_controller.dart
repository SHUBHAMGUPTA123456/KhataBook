
import 'package:get/get.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/database_repository.dart';
import '../../presentation/controllers/party_controller.dart';

class TransactionController extends GetxController {
  final DatabaseRepository dbRepo = Get.find();
  RxList<AppTransaction> transactions = <AppTransaction>[].obs;
  String searchQuery = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadTransactions(int partyId) async {
    transactions.value = await dbRepo.getTransactions(partyId, searchQuery: searchQuery);
  }

  void search(String query, int partyId) {
    searchQuery = query;
    loadTransactions(partyId);
  }
  // In addTransaction, updateTransaction, deleteTransaction

  Future<void> addTransaction(AppTransaction txn) async {
     await dbRepo.addTransaction(txn);
    await loadTransactions(txn.partyId);

    // Trigger immediate balance update
    Get.find<PartyController>().refreshPartyBalance(txn.partyId);
  }

  Future<void> updateTransaction(AppTransaction txn) async {
    await dbRepo.updateTransaction(txn);
    await loadTransactions(txn.partyId);
    Get.find<PartyController>().refreshPartyBalance(txn.partyId);
  }

  Future<void> deleteTransaction(int id, int partyId) async {
    await dbRepo.deleteTransaction(id);
    await loadTransactions(partyId);
    Get.find<PartyController>().refreshPartyBalance(partyId);
  }
}