import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/app_colors.dart';
import '../../data/models/party.dart';
import '../../data/models/transaction.dart';
import '../controllers/party_controller.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';

class PartyDetailScreen extends StatefulWidget {
  final Party party;

  const PartyDetailScreen({super.key, required this.party});

  @override
  State<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  final TransactionController txnCtrl = Get.find();
  final PartyController partyCtrl = Get.find();
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    txnCtrl.loadTransactions(widget.party.id!);
    partyCtrl.refreshPartyBalance(widget.party.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackLight,
      appBar: AppBar(
        backgroundColor: AppColors.blackLight,
        foregroundColor: AppColors.textDark,
        title: Text(widget.party.name.capitalizeFirst ?? widget.party.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.textDark),
            tooltip: 'Export PDF',
            onPressed: () => _exportToPDF(),
          ),
          IconButton(
            icon: const Icon(
              Icons.table_chart_outlined,
              color: AppColors.textDark,
            ),
            tooltip: 'Export CSV',
            onPressed: () => _exportToCSV(),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textDark),
            onPressed: sendWhatsAppReminder,
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(height: 1, color: AppColors.dividerColor),
          Obx(() {
            final double balance =
                partyCtrl.partyBalances[widget.party.id!] ?? 0.0;
            final bool isLoading = !partyCtrl.partyBalances.containsKey(
              widget.party.id!,
            );

            String label = balance >= 0 ? 'Due' : 'Advance';
            Color color = balance >= 0 ? Colors.red : Colors.green;

            return ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 18,
                  ),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Balance $label',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          height: 36,
                          width: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      else
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              ),
                          child: Text(
                            '₹${balance.abs().toStringAsFixed(0)}',
                            key: ValueKey(balance),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      if (widget.party.phone != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              size: 15,
                              color: AppColors.grayLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.party.phone!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grayLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: searchCtrl,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: AppColors.textDark,
              decoration: const InputDecoration(
                labelText: 'Search Category/Notes/Amount',
                labelStyle: TextStyle(
                  color: AppColors.textDarkOne,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textDark),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textDark),
                ),
              ),
              onChanged: (val) => txnCtrl.search(val, widget.party.id!),
            ),
          ),

          // Transaction List
          Expanded(
            child: Obx(() {
              if (txnCtrl.transactions.isEmpty) {
                return const Center(
                  child: Text(
                    'No transactions yet\nAdd one using the buttons below',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: txnCtrl.transactions.length,
                separatorBuilder: (context, index) => const Divider(
                  color: AppColors.dividerColor,
                  thickness: 1.0,
                  indent: 16.0,
                  endIndent: 16.0,
                ),
                itemBuilder: (ctx, i) {
                  final txn = txnCtrl.transactions[i];
                  return TransactionItem(
                    txn: txn,
                    onEdit: () => Get.to(() => AddTransactionScreen(txn: txn), transition: Transition.leftToRight),
                    onDelete: () => showDeleteConfirmation(txn),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'received',
              backgroundColor: AppColors.green,
              icon: const Icon(Icons.arrow_downward, color: AppColors.textDark),
              label: const Text(
                'Received',
                style: TextStyle(color: AppColors.textDark),
              ),
              onPressed: () => Get.to(
                () => AddTransactionScreen(
                  partyId: widget.party.id!,
                  type: 'received',
                ),
                transition: Transition.leftToRight
              ),
            ),
            const SizedBox(width: 16),
            FloatingActionButton.extended(
              heroTag: 'given',
              backgroundColor: AppColors.red,
              icon: const Icon(Icons.arrow_upward, color: AppColors.textDark),
              label: const Text(
                'Given',
                style: TextStyle(color: AppColors.textDark),
              ),
              onPressed: () => Get.to(
                () => AddTransactionScreen(
                  partyId: widget.party.id!,
                  type: 'given',
                ),
                transition: Transition.leftToRight
              ),
            ),
          ],
        ),
      ),
    );
  }

  //               CSV EXPORT
  Future<void> _exportToCSV() async {
    try {
      final transactions = txnCtrl.transactions;

      if (transactions.isEmpty) {
        Get.snackbar(
          'No Data',
          'No transactions to export',
          backgroundColor: Colors.orange,
        );
        return;
      }

      List<List<dynamic>> rows = [
        ["Date", "Description", "Amount", "Type", "Category"],
      ];

      for (var t in transactions) {
        rows.add([
          t.date,
          t.note ?? "",
          t.amount.toStringAsFixed(2),
          t.type == 0 ? "Given" : "Received",
          t.category ?? "Uncategorized",
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory =
          await getDownloadsDirectory() ?? await getTemporaryDirectory();
      final fileName =
          "${widget.party.name.replaceAll(" ", "_")}_transactions_${DateTime.now().toString().substring(0, 10)}.csv";
      final path = "${directory.path}/$fileName";

      final file = File(path);
      await file.writeAsString(csv);

      await OpenFilex.open(path);

      Get.snackbar(
        'Success',
        'CSV exported to:\n$fileName',
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export CSV: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  //               PDF EXPORT
  Future<void> _exportToPDF() async {
    try {
      final transactions = txnCtrl.transactions;

      if (transactions.isEmpty) {
        Get.snackbar(
          'No Data',
          'No transactions to export',
          backgroundColor: Colors.orange,
        );
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                "${widget.party.name} - Transaction History",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              "Generated: ${DateFormat('dd MMM yyyy • HH:mm').format(DateTime.now())}",
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Description', 'Amount', 'Type', 'Category'],
              data: transactions
                  .map(
                    (t) => [
                      t.date,
                      t.note ?? "-",
                      "₹${t.amount.toStringAsFixed(2)}",
                      t.type == 0 ? "Given" : "Received",
                      t.category ?? "Uncategorized",
                    ],
                  )
                  .toList(),
              border: null,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.center,
                4: pw.Alignment.centerLeft,
              },
            ),
          ],
        ),
      );

      final output = await getTemporaryDirectory();
      final fileName =
          "${widget.party.name.replaceAll(" ", "_")}_report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${output.path}/$fileName");

      await file.writeAsBytes(await pdf.save());
      await OpenFilex.open(file.path);

      Get.snackbar(
        'Success',
        'PDF exported and opened',
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create PDF: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  //               WHATSAPP REMINDER (unchanged)
  void sendWhatsAppReminder() async {
    final double balance =
        partyCtrl.partyBalances[widget.party.id!] ?? 0.0;
    final String label = balance >= 0 ? 'Due' : 'Advance';

    final String message =
        'Hi ${widget.party.name},\n'
        'Your current balance is ₹${balance.abs().toStringAsFixed(0)} $label.\n'
        'Please settle it at your earliest convenience.\n'
        'Thank you!';

    final String phone = widget.party.phone ?? '';

    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Phone number not available',
        backgroundColor: AppColors.red,
      );
      return;
    }

    // MUST include country code, NO +
    final String formattedPhone = phone.startsWith('91')
        ? phone
        : '91$phone';

    final Uri uri = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      Get.snackbar(
        'Warning',
        'Unable to open WhatsApp',
        backgroundColor: AppColors.orange,
      );
    }
  }

  void showDeleteConfirmation(AppTransaction txn) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              txnCtrl.deleteTransaction(txn.id!, widget.party.id!);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
