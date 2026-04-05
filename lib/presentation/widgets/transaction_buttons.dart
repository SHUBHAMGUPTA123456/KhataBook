import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khata_book/core/utils/app_colors.dart';
import 'package:khata_book/presentation/views/add_transaction_screen.dart';

class TransactionButtons extends StatelessWidget {
  final int partyId;

  const TransactionButtons({super.key, required this.partyId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: null,
            backgroundColor: AppColors.green,
            icon: const Icon(
              Icons.arrow_downward,
              color: AppColors.textDark,
            ),
            label: const Text(
              'Received',
              style: TextStyle(color: AppColors.textDark),
            ),
            onPressed: () => Get.to(
              () => AddTransactionScreen(partyId: partyId, type: 'received'),
              transition: Transition.leftToRight,
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: null,
            backgroundColor: AppColors.red,
            icon: const Icon(
              Icons.arrow_upward,
              color: AppColors.textDark,
            ),
            label: const Text(
              'Given',
              style: TextStyle(color: AppColors.textDark),
            ),
            onPressed: () => Get.to(
              () => AddTransactionScreen(partyId: partyId, type: 'given'),
              transition: Transition.leftToRight
            ),
          ),
        ],
      ),
    );
  }
}
