import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khata_book/core/utils/app_colors.dart';
import '../../data/models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final AppTransaction txn;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.txn,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = txn.type == 'given'
        ? Icons.arrow_circle_up
        : Icons.arrow_circle_down_sharp;
    Color color = txn.type == 'given' ? Colors.red : Colors.green;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        '₹${txn.amount.toStringAsFixed(0)}',
        style: const TextStyle(color: AppColors.textDark),
      ),
      subtitle: Text(
        DateFormat('dd MMM yyyy hh:mm a').format(txn.date),
        style: const TextStyle(color: AppColors.textDarkOne, fontSize: 12),
      ),
      trailing: PopupMenuButton<String>(
        iconColor: AppColors.textDark,
        color: AppColors.darkGray,
        onSelected: (value) {
          if (value == 'edit') {
            onEdit();
          } else if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: AppColors.green),
                SizedBox(width: 8),
                Text("Edit", style: TextStyle(color: AppColors.textDark)),
              ],
            ),
          ),
          PopupMenuDivider(
            height: 1,
            color: AppColors.dividerColor,
            indent: 8,
            endIndent: 8,
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text("Delete", style: TextStyle(color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
