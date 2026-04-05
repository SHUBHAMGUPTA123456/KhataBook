import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/services/export_service.dart';
import '../../core/services/import_service.dart';
import '../../core/utils/app_colors.dart';
import '../../data/models/category.dart';
import '../../data/models/party.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/database_repository.dart';

class ReportController extends GetxController {
  final DatabaseRepository dbRepo = Get.find();
  final ExportService exportService = Get.find();
  RxList<Map<String, dynamic>> monthlyReport = <Map<String, dynamic>>[].obs;

  final ImportService _importService = ImportService();
  final RxBool isImporting = false.obs;
  final RxString importStatus = ''.obs;

  Future<void> loadMonthlyReport(DateTime month) async {
    monthlyReport.value = await dbRepo.getMonthlyTransactionsReport(month);
  }

  Future<void> exportMonthlyReport(DateTime month, String format) async {
    final data = await dbRepo.getMonthlyTransactionsReport(month);
    String filename = 'khata_monthly_${DateFormat('yyyyMM').format(month)}';

    String path;
    if (format == 'csv') {
      path = await exportService.exportToCSV(data, filename);
    } else {
      path = await exportService.exportToPDF(data, filename, month: month);
    }

    await exportService.shareFile(path, format);
  }

  Future<void> exportAllTransactions(String format) async {
    final data = await dbRepo.getAllTransactionsReport();
    String filename =
        'khata_all_transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}';

    String path;
    if (format == 'csv') {
      path = await exportService.exportToCSV(data, filename);
    } else {
      path = await exportService.exportToPDF(data, filename);
    }

    await exportService.shareFile(path, format);
  }

  Future<void> importTransactions() async {
    try {
      isImporting.value = true;
      importStatus.value = 'Picking file...';

      final transactions = await _importService.pickAndParseFile();

      if (transactions == null) {
        importStatus.value = 'Import cancelled';
        return;
      }

      if (transactions.isEmpty) {
        importStatus.value = 'No valid transactions found in file';
        Get.snackbar(
          'Import Failed',
          'No valid transactions could be parsed from the file.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red.withValues(alpha: 0.8),
          colorText: AppColors.white,
        );
        return;
      }

      importStatus.value = 'Importing ${transactions.length} transactions...';

      int successCount = 0;
      int skipCount = 0;

      // Cache party name → id to avoid repeated DB lookups
      final Map<String, int> partyCache = {};

      for (final txn in transactions) {
        try {
          final partyName = txn['party_name']?.toString().trim() ?? 'Unknown';

          // Look up or create party
          int partyId;
          if (partyCache.containsKey(partyName)) {
            partyId = partyCache[partyName]!;
          } else {
            partyId = await _getOrCreateParty(partyName);
            partyCache[partyName] = partyId;
          }

          // Parse category safely
          Category? category;
          final categoryStr = txn['category']?.toString().trim().toLowerCase();
          if (categoryStr != null && categoryStr.isNotEmpty) {
            try {
              category = Category.values.byName(categoryStr);
            } catch (_) {
              category = Category.others;
            }
          }

          // Parse date safely
          DateTime date;
          try {
            date = DateTime.parse(txn['date'].toString());
          } catch (_) {
            date = DateTime.now();
          }

          // Parse amount safely
          final amount = (txn['amount'] as num?)?.toDouble() ?? 0.0;
          if (amount <= 0) {
            skipCount++;
            continue;
          }

          // Normalize type
          final rawType =
              txn['transaction_type']?.toString().toLowerCase() ?? '';
          final type = (rawType == 'received' || rawType == 'credit')
              ? 'received'
              : 'given';

          final appTxn = AppTransaction(
            partyId: partyId,
            amount: amount,
            type: type,
            date: date,
            note: txn['note']?.toString(),
            category: category,
          );

          await dbRepo.addTransaction(appTxn);
          successCount++;
        } catch (_) {
          skipCount++;
        }
      }

      // Reload report after import
      await loadMonthlyReport(DateTime.now());

      Get.snackbar(
        'Import Complete',
        '$successCount transactions imported'
            '${skipCount > 0 ? ', $skipCount skipped' : ''}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.green.withValues(alpha: 0.8),
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Import Error',
        'Failed to import: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red.withValues(alpha: 0.8),
        colorText: AppColors.white,
      );
    } finally {
      isImporting.value = false;
      importStatus.value = '';
    }
  }

  /// Looks up a party by name across both types, or creates a new one.
  Future<int> _getOrCreateParty(String name) async {
    // Search in customers first, then suppliers
    for (final type in ['customer', 'supplier']) {
      final parties = await dbRepo.getParties(type);
      final match = parties.where(
        (p) => p.name.trim().toLowerCase() == name.toLowerCase(),
      );
      if (match.isNotEmpty) return match.first.id!;
    }

    // Not found — create as customer
    final newParty = Party(name: name, type: 'customer');
    return await dbRepo.addParty(newParty);
  }
}
