import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khata_book/core/utils/app_colors.dart';
import 'package:khata_book/data/models/party.dart';
import 'package:khata_book/presentation/controllers/party_controller.dart';
import 'package:khata_book/presentation/views/party_detail_screen.dart';
import 'package:khata_book/presentation/widgets/party_list_item.dart';

class PartyTabView extends StatelessWidget {
  final String type;
  final RxList<Party> parties;
  final RxDouble netBalance;
  final PartyController partyCtrl;

  const PartyTabView({
    super.key,
    required this.type,
    required this.parties,
    required this.netBalance,
    required this.partyCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Net Balance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Text(
                  '₹${netBalance.value.abs().toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                netBalance.value >= 0 ? "You Get →" : "You Pay →",
                style: TextStyle(
                  color: netBalance.value >= 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: parties.isEmpty
                ? const Center(child: Text('No parties yet. Add one!', style: TextStyle(color: AppColors.textDark)))
                : ListView.builder(
                    itemCount: parties.length,
                    itemBuilder: (ctx, i) {
                      final party = parties[i];
                      return Obx(() {
                        final balance = partyCtrl.partyBalances[party.id!] ?? 0.0;
                        final bool isLoading = !partyCtrl.partyBalances
                            .containsKey(party.id!);

                        if (isLoading) {
                          return const ListTile(
                            leading: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            title: Text('Calculating balance...', style: TextStyle(color: AppColors.textDark)),
                          );
                        }

                        return PartyListItem(
                          party: party,
                          balance: balance,
                          onTap: () =>
                              Get.to(() => PartyDetailScreen(party: party), transition: Transition.leftToRight),
                        );
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
