import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class ImportService {
  Future<List<Map<String, dynamic>>?> pickAndParseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.first.path;
    if (path == null) return null;

    return await _parseCSV(path);
  }

  Future<List<Map<String, dynamic>>> _parseCSV(String path) async {
    final input = File(path).readAsStringSync();

    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(input);

    if (rows.length < 2) return [];

    // Your ExportService writes these exact headers at index:
    // 0: ID | 1: Date | 2: Party Name | 3: Category | 4: Type | 5: Amount (₹) | 6: Note | 7: Phone

    final transactions = <Map<String, dynamic>>[];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;

      try {
        // --- Amount (index 5) ---
        // Exported as raw number e.g. "5.0" or "25.0"
        final amountStr = row[5]
            .toString()
            .replaceAll(RegExp(r'[₹,\s]'), '')
            .trim();
        final amount = double.tryParse(amountStr) ?? 0.0;
        if (amount <= 0) continue;

        // --- Type (index 4) ---
        // Exported as 'Credit' or 'Debit'
        final rawType = row[4].toString().trim().toLowerCase();
        final type = rawType == 'credit' ? 'received' : 'given';

        // --- Date (index 1) ---
        // Exported as 'dd/MM/yyyy hh:mm a' e.g. '18/03/2026 03:15 AM'
        final dateStr = row[1].toString().trim();
        DateTime date;
        try {
          final parts = dateStr.split(' ');
          // parts[0] = '18/03/2026', parts[1] = '03:15', parts[2] = 'AM'
          final dateParts = parts[0].split('/');
          final timeParts = parts[1].split(':');
          final isPM =
              parts.length > 2 && parts[2].toUpperCase() == 'PM';

          int hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;

          date = DateTime(
            int.parse(dateParts[2]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[0]), // day
            hour,
            minute,
          );
        } catch (_) {
          date = DateTime.now();
        }

        // --- Party Name (index 2) ---
        final partyName = row[2].toString().trim();
        if (partyName.isEmpty || partyName == 'N/A') continue;

        // --- Category (index 3) ---
        final categoryStr = row[3].toString().trim();

        // --- Note (index 6, optional) ---
        final note = row.length > 6 ? row[6].toString().trim() : '';

        transactions.add({
          'party_name': partyName,
          'date': date.toIso8601String(),
          'amount': amount,
          'transaction_type': type,
          'category': categoryStr,
          'note': note,
        });
      } catch (_) {
        continue;
      }
    }

    return transactions;
  }
}