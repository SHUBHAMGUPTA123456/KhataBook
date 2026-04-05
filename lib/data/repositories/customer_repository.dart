// lib/repositories/customer_repository.dart

import 'package:get/get.dart';
import '../models/party.dart';
import 'database_helper.dart';

class CustomerRepository extends GetxService {
  final DatabaseHelper dbHelper = Get.find();

  Future<List<Party>> getCustomers() async {
    return await dbHelper.getParties('customer');
  }

  Future<List<Party>> getSuppliers() async {
    return await dbHelper.getParties('supplier');
  }

  Future<int> insertParty(Party party) async {
    return await dbHelper.addParty(party);
  }

  Future<double> getPartyBalance(int partyId) async {
    return await dbHelper.getPartyBalance(partyId);
  }

  Future<double> getNetBalance(String type) async {
    return await dbHelper.getNetBalance(type);
  }
}