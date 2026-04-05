import 'package:get/get.dart';

import '../../data/repositories/database_repository.dart';
import '../../data/repositories/transaction_repository.dart';  // ✅ Add this import
import '../../presentation/controllers/party_controller.dart';
import '../../presentation/controllers/report_controller.dart';
import '../../presentation/controllers/transaction_controller.dart';
import '../services/export_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DatabaseRepository>(() => DatabaseRepository(), fenix: true);

    Get.lazyPut<TransactionRepository>(() => TransactionRepository(), fenix: true);

    Get.lazyPut<PartyController>(() => PartyController(), fenix: true);
    Get.lazyPut<TransactionController>(() => TransactionController(), fenix: true);
    Get.lazyPut<ReportController>(() => ReportController(), fenix: true);
    Get.lazyPut<ExportService>(() => ExportService());
  }
}