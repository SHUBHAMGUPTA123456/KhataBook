import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/repositories/database_repository.dart';

class ExportService extends GetxService {
  final DatabaseRepository dbRepo = Get.find();

  // Generate CSV file
  Future<String> exportToCSV(List<Map<String, dynamic>> data, String filename) async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/$filename.csv';

    List<List<dynamic>> csvData = [
      ['ID', 'Date', 'Party Name', 'Category', 'Type', 'Amount (₹)', 'Note', 'Phone'],
      ...data.map((row) => [
        row['id'],
        DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(row['date'])),
        row['party_name'] ?? 'N/A',
        row['category'] ?? 'Uncategorized',
        row['type'] == 'received' ? 'Credit' : 'Debit',
        row['amount'],
        row['note'] ?? '',
        row['phone'] ?? '',
      ]),
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  Future<String> exportToPDF(
      List<Map<String, dynamic>> data,
      String filename, {
        DateTime? month,
      }) async {
    final pdf = pw.Document();

    final fontData = await DefaultAssetBundle.of(Get.context!).load(
      'assets/fonts/Roboto-Regular.ttf',
    );
    final ttf = pw.Font.ttf(fontData);
    final ttfBold = ttf;

    // Summary totals
    double totalCredit = 0;
    double totalDebit = 0;
    for (final row in data) {
      final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;
      final type = row['transaction_type']?.toString() ?? row['type']?.toString() ?? '';
      if (type == 'received') {
        totalCredit += amount;
      } else {
        totalDebit += amount;
      }
    }
    final net = totalCredit - totalDebit;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape, // landscape for more width
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          // ── Header ──
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Khata Book Report',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    month != null
                        ? 'Month: ${DateFormat('MMMM yyyy').format(month)}'
                        : 'All Transactions',
                    style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.Text(
                'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),

          pw.SizedBox(height: 12),
          pw.Divider(thickness: 1, color: PdfColors.grey400),
          pw.SizedBox(height: 10),

          // ── Summary Cards ──
          pw.Row(
            children: [
              _summaryBox('Total Credit', '₹ ${totalCredit.toStringAsFixed(2)}', PdfColors.green700, ttf, ttfBold),
              pw.SizedBox(width: 12),
              _summaryBox('Total Debit', '₹ ${totalDebit.toStringAsFixed(2)}', PdfColors.red700, ttf, ttfBold),
              pw.SizedBox(width: 12),
              _summaryBox(
                'Net Balance',
                '₹ ${net.abs().toStringAsFixed(2)} ${net >= 0 ? '(You Get)' : '(You Owe)'}',
                net >= 0 ? PdfColors.blue700 : PdfColors.orange700,
                ttf,
                ttfBold,
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // ── Transactions Table ──
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(100), // Date
              1: const pw.FixedColumnWidth(80),  // Party
              2: const pw.FixedColumnWidth(70),  // Category
              3: const pw.FixedColumnWidth(45),  // Type
              4: const pw.FixedColumnWidth(65),  // Amount
              5: const pw.FlexColumnWidth(),     // Note (takes remaining space)
            },
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                children: [
                  _headerCell('Date', ttfBold),
                  _headerCell('Party', ttfBold),
                  _headerCell('Category', ttfBold),
                  _headerCell('Type', ttfBold),
                  _headerCell('Amount (₹)', ttfBold),
                  _headerCell('Note', ttfBold),
                ],
              ),

              // Data Rows
              ...data.asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;

                final String txnType =
                    row['transaction_type']?.toString() ?? row['type']?.toString() ?? 'given';
                final bool isCredit = txnType == 'received';
                final double amount = (row['amount'] as num?)?.toDouble() ?? 0.0;
                final PdfColor rowColor = i.isEven ? PdfColors.white : PdfColors.grey100;
                final PdfColor typeColor = isCredit ? PdfColors.green700 : PdfColors.red700;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: rowColor),
                  children: [
                    _cell(
                      DateFormat('dd/MM/yyyy\nhh:mm a').format(
                        DateTime.parse(row['date'] as String),
                      ),
                      ttf,
                      fontSize: 8,
                    ),
                    _cell(row['party_name']?.toString() ?? 'N/A', ttf),
                    _cell(row['category']?.toString() ?? 'Uncategorized', ttf),
                    _cell(
                      isCredit ? 'Credit' : 'Debit',
                      ttfBold,
                      color: typeColor,
                      fontSize: 8,
                    ),
                    _cell(
                      '₹ ${amount.toStringAsFixed(2)}',
                      ttfBold,
                      color: typeColor,
                      align: pw.Alignment.centerRight,
                    ),
                    _cell(row['note']?.toString() ?? '', ttf, fontSize: 8),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 8),
          pw.Text(
            'Total ${data.length} transactions',
            style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }

// ── Helper: Summary Box ──
  pw.Widget _summaryBox(
      String label,
      String value,
      PdfColor color,
      pw.Font ttf,
      pw.Font ttfBold,
      ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.white)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 12,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

// ── Helper: Header Cell ──
  pw.Widget _headerCell(String text, pw.Font ttfBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttfBold,
          fontSize: 9,
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

// ── Helper: Data Cell ──
  pw.Widget _cell(
      String text,
      pw.Font ttf, {
        double fontSize = 9,
        PdfColor color = PdfColors.black,
        pw.Alignment align = pw.Alignment.centerLeft,
      }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: ttf, fontSize: fontSize, color: color),
      ),
    );
  }

  // Share/Preview file (call after generating)
  Future<void> shareFile(String path, String type) async {
    await Printing.sharePdf(bytes: await File(path).readAsBytes(), filename: path.split('/').last);
  }
}