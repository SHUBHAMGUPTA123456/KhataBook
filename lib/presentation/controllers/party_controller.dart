// presentation/controllers/party_controller.dart

import 'package:get/get.dart';
import '../../core/utils/app_colors.dart';
import '../../data/models/party.dart';
import '../../data/repositories/database_repository.dart';

class PartyController extends GetxController {
  final DatabaseRepository dbRepo = Get.find();

  RxList<Party> customers = <Party>[].obs;
  RxList<Party> suppliers = <Party>[].obs;
  RxDouble customerNetBalance = 0.0.obs;
  RxDouble supplierNetBalance = 0.0.obs;

  // NEW: Reactive map to store live balance for each party
  final RxMap<int, double> partyBalances = <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadParties();
  }

  Future<void> loadParties() async {
    customers.value = await dbRepo.getParties('customer');
    suppliers.value = await dbRepo.getParties('supplier');

    // Pre-calculate all balances once
    await refreshAllBalances();

    // Calculate net balances
    customerNetBalance.value = await dbRepo.getNetBalance('customer');
    supplierNetBalance.value = await dbRepo.getNetBalance('supplier');
  }

  // NEW: Refresh balance for a single party and update reactive map
  Future<void> refreshPartyBalance(int partyId) async {
    double balance = await dbRepo.getPartyBalance(partyId);
    partyBalances[partyId] = balance;

    // Also update net balances if needed
    customerNetBalance.value = await dbRepo.getNetBalance('customer');
    supplierNetBalance.value = await dbRepo.getNetBalance('supplier');
  }

  // NEW: Refresh all balances (used on load or full refresh)
  Future<void> refreshAllBalances() async {
    for (var party in customers) {
      partyBalances[party.id!] = await dbRepo.getPartyBalance(party.id!);
    }
    for (var party in suppliers) {
      partyBalances[party.id!] = await dbRepo.getPartyBalance(party.id!);
    }
  }

  Future<void> addParty(Party party) async {
    int id = await dbRepo.addParty(party);
    party.id = id;
    if (party.type == 'customer') {
      customers.add(party);
      partyBalances[id] = 0.0; // New party starts at 0
    } else {
      suppliers.add(party);
      partyBalances[id] = 0.0;
    }
    refreshNetBalances();
  }

  Future<void> refreshNetBalances() async {
    customerNetBalance.value = await dbRepo.getNetBalance('customer');
    supplierNetBalance.value = await dbRepo.getNetBalance('supplier');
  }

  Future<double> getBalance(int partyId) async {
    return await dbRepo.getPartyBalance(partyId);
  }

  Future<void> deleteParty(int partyId) async {
    try {
      // Step 1: Delete all transactions for this party (important!)
      await dbRepo.deleteTransactionsByPartyId(partyId);

      // Step 2: Delete the party
      await dbRepo.deleteParty(partyId);

      // Step 3: Refresh UI
      loadParties();               // reload customers & suppliers
      partyBalances.remove(partyId); // remove balance cache
      refreshAllBalances();        // recalculate if needed
      refreshNetBalances();        // update total net balance

      Get.snackbar(
        'Deleted',
        'Party and all transactions removed',
        backgroundColor: AppColors.green,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete party: $e',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }
}