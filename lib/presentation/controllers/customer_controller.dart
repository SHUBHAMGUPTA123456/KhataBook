// CustomerController
import 'package:get/get.dart';

import '../../data/models/party.dart';
import '../../data/repositories/customer_repository.dart';

// CustomerController
class CustomerController extends GetxController {
  final CustomerRepository customerRepo = Get.find();

  RxList<Party> customers = <Party>[].obs;
  RxDouble netBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    customers.value = await customerRepo.getCustomers();
    netBalance.value = await customerRepo.getNetBalance('customer');
  }
}