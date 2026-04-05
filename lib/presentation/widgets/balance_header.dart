import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khata_book/presentation/controllers/party_controller.dart';
import 'package:khata_book/core/utils/app_colors.dart';
import 'package:khata_book/data/models/party.dart';

class BalanceHeader extends StatelessWidget {
  final Party party;
  final PartyController partyCtrl = Get.find();

  BalanceHeader({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final double balance = partyCtrl.partyBalances[party.id!] ?? 0.0;
      final bool isLoading = !partyCtrl.partyBalances.containsKey(party.id!);

      String label = balance >= 0 ? 'Due' : 'Advance';
      Color color = balance >= 0 ? Colors.red : Colors.green;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.blackLight.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Balance $label',
              style: const TextStyle(fontSize: 18, color: AppColors.textDark),
            ),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Text(
                '₹${balance.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            if (party.phone != null) ...[
              const SizedBox(height: 12),
              Text(
                party.phone!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    });
  }
}
