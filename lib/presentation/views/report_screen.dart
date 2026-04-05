import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:khata_book/presentation/widgets/app_gradiant_btn.dart';
import '../../core/utils/app_colors.dart';
import '../controllers/report_controller.dart';

class ReportScreen extends StatelessWidget {
  final ReportController reportCtrl = Get.find();
  DateTime selectedMonth = DateTime.now();

  ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    reportCtrl.loadMonthlyReport(selectedMonth);

    return Scaffold(
      backgroundColor: AppColors.blackLight,
      appBar: AppBar(
        foregroundColor: AppColors.textDark,
        title: const Text('Monthly Transactions'),
        backgroundColor: AppColors.blackLight,
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: AppColors.dividerColor),
          ListTile(
            title: Text(
              'Month: ${DateFormat('MMM yyyy').format(selectedMonth)}',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.calendar_today, color: AppColors.white),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedMonth,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                selectedMonth = picked;
                reportCtrl.loadMonthlyReport(selectedMonth);
              }
            },
          ),

          // Export Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.file_download, size: 18),
                    label: const Text(
                      'Monthly',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green.withValues(alpha: 0.7),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showExportDialog('monthly'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.all_inclusive, size: 18),
                    label: const Text(
                      'All Time',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue.withValues(alpha: 0.8),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showExportDialog('all'),
                  ),
                ),
              ],
            ),
          ),
// Import Button Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() => ElevatedButton.icon(
              icon: reportCtrl.isImporting.value
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.file_upload, size: 18),
              label: Text(
                reportCtrl.isImporting.value
                    ? reportCtrl.importStatus.value
                    : 'Import Transactions',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.withValues(alpha: 0.75),
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: reportCtrl.isImporting.value
                  ? null
                  : () => _showImportDialog(),
            )),
          ),
          // Transactions List
          Expanded(
            child: Obx(() {
              if (reportCtrl.monthlyReport.isEmpty) {
                return const Center(
                  child: Text(
                    'No transactions this month',
                    style: TextStyle(
                      color: AppColors.textDarkOne,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: reportCtrl.monthlyReport.length,
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: AppColors.dividerColor,
                    thickness: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                  );
                },
                itemBuilder: (context, index) {
                  final txn = reportCtrl.monthlyReport[index];

                  final String txnType =
                      txn['transaction_type']?.toString() ?? 'given';
                  final bool isCredit = txnType == 'received';
                  final double amount =
                      (txn['amount'] as num?)?.toDouble() ?? 0.0;
                  final String displayAmount =
                      '₹${amount.abs().toStringAsFixed(0)}';
                  final String typeLabel = isCredit ? 'Credit' : 'Debit';
                  final Color color = isCredit
                      ? AppColors.green
                      : AppColors.red;
                  final IconData icon = isCredit
                      ? Icons.arrow_circle_up
                      : Icons.arrow_circle_down;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          txn['party_name']?.toString().capitalizeFirst ??
                              'Unknown',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Center(
                              child: Text(
                                txn['category']?.toString().capitalizeFirst ??
                                    'Uncategorized',
                                style: TextStyle(
                                  color: AppColors.textDarkOne,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (txn['note']?.toString().isNotEmpty ?? false)
                              Expanded(
                                child: Text(
                                  '• ${txn['note']}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat(
                          'dd MMM yyyy • hh:mm a',
                        ).format(DateTime.parse(txn['date'] as String)),
                        style: TextStyle(
                          color: AppColors.textDarkOne,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          displayAmount,
                          style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          typeLabel,
                          style: TextStyle(
                            color: color.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(String type) {
    Get.dialog(
      AlertDialog(
        title: Text(
          '${type == 'monthly' ? 'Monthly' : 'All Transactions'} Export',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.blackLight,
        insetPadding: EdgeInsets.all(4),
        contentTextStyle: TextStyle(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose format:'),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.green),
              title: const Text(
                'CSV (Excel/Google Sheets)',
                style: TextStyle(color: AppColors.white),
              ),
              onTap: () {
                Get.back();
                if (type == 'monthly') {
                  reportCtrl.exportMonthlyReport(selectedMonth, 'csv');
                } else {
                  reportCtrl.exportAllTransactions('csv');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.red),
              title: const Text(
                'PDF (Printable/Shareable)',
                style: TextStyle(color: AppColors.white),
              ),
              onTap: () {
                Get.back();
                if (type == 'monthly') {
                  reportCtrl.exportMonthlyReport(selectedMonth, 'pdf');
                } else {
                  reportCtrl.exportAllTransactions('pdf');
                }
              },
            ),
          ],
        ),
        actions: [
          AppGradiantBtn(
            btnTitle: 'Cancel',
            onPressed: () => Get.back(),
            height: 35,
            startColor: AppColors.white,
            centerColor: AppColors.white,
            endColor: AppColors.white,
          ),
        ],
      ),
    );
  }
  void _showImportDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.blackLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Import Transactions',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Import a CSV or PDF file exported from this app.\n\n'
              'Transactions will be merged with your existing data.\n\n'
              '⚠️ Make sure the file was exported from Khata Book for best results.',
          style: TextStyle(color: AppColors.textDarkOne, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textDarkOne)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Choose File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.back();
              reportCtrl.importTransactions();
            },
          ),
        ],
      ),
    );
  }
}
