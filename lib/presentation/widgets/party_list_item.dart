import 'package:flutter/material.dart';
import 'package:khata_book/core/utils/app_colors.dart';
import '../../data/models/party.dart';
import 'package:get/get.dart';
import '../controllers/party_controller.dart';

/*class PartyListItem extends StatelessWidget {
  final Party party;
  final double balance;
  final VoidCallback onTap;

  PartyListItem({
    required this.party,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String label = balance >= 0 ? 'Due' : 'Advance';
    Color color = balance >= 0 ? AppColors.red : AppColors.green;
    return ListTile(
      leading: CircleAvatar(child: Text(party.name[0])),
      title: Text(party.name, style: TextStyle(color: AppColors.textDark)),
      trailing: Text(
        '₹${balance.abs().toStringAsFixed(0)} $label',
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }
}*/

class PartyListItem extends StatelessWidget {
  final Party party;
  final double balance;
  final VoidCallback onTap;

  const PartyListItem({
    super.key,
    required this.party,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final partyCtrl = Get.find<PartyController>();

    String label = balance >= 0 ? 'Due' : 'Advance';
    Color color = balance >= 0 ? AppColors.red : AppColors.green;

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showDeleteDialog(context, partyCtrl),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                party.name[0].toUpperCase(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    party.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (party.phone != null)
                    Text(
                      party.phone!,
                      style: TextStyle(
                        color: AppColors.grayLight,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${balance.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PartyController partyCtrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.blackLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete ${party.name}?',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${party.name}"?\n'
          'This will permanently remove the party and all related transactions.',
          style: const TextStyle(color: AppColors.textDarkOne),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.grayLight),
            ),
          ),
          TextButton(
            onPressed: () {
              partyCtrl.deleteParty(party.id!);
              Get.back();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
