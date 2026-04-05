import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khata_book/core/utils/app_colors.dart';
import 'package:khata_book/data/models/party.dart';
import 'package:khata_book/presentation/controllers/party_controller.dart';
import 'package:khata_book/presentation/widgets/app_gradiant_btn.dart';
import 'package:khata_book/presentation/widgets/app_text.dart';

class AddPartyDialog extends StatefulWidget {
  const AddPartyDialog({super.key});

  @override
  State<AddPartyDialog> createState() => _AddPartyDialogState();
}

class _AddPartyDialogState extends State<AddPartyDialog> {
  final PartyController partyCtrl = Get.find<PartyController>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  String selectedType = 'customer';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.blackLight,
      insetPadding: const EdgeInsets.all(4),
      contentTextStyle: const TextStyle(color: AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: AppText(
        'Add ${selectedType.capitalizeFirst}',
        color: AppColors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            style: const TextStyle(color: AppColors.white),
            cursorColor: AppColors.white,
            cursorErrorColor: AppColors.red,
            controller: nameCtrl,
            decoration: getInputDecoration('Name'),
          ),
          TextField(
            controller: phoneCtrl,
            style: const TextStyle(color: AppColors.white),
            decoration: getInputDecoration('Phone (optional)'),
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedType,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              labelText: 'Type',
              focusColor: AppColors.black,
              hoverColor: AppColors.black,
              fillColor: AppColors.black,
              labelStyle: const TextStyle(color: AppColors.grayLight),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.white),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.white),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.red),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.red),
              ),
            ),
            dropdownColor: AppColors.darkGray,
            items: ['customer', 'supplier']
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(
                      type.capitalizeFirst!,
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedType = val!),
          ),
        ],
      ),
      actions: [
        AppGradiantBtn(
          btnTitle: 'Add',
          height: 35,
          startColor: AppColors.white,
          centerColor: AppColors.white,
          endColor: AppColors.white,
          onPressed: () {
            if (nameCtrl.text.trim().isEmpty) return;

            final party = Party(
              name: nameCtrl.text.trim(),
              type: selectedType,
              phone: phoneCtrl.text.trim().isEmpty
                  ? null
                  : phoneCtrl.text.trim(),
            );

            partyCtrl.addParty(party);
            nameCtrl.clear();
            phoneCtrl.clear();
            Get.back();
          },
        ),
      ],
    );
  }

  InputDecoration getInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      focusColor: AppColors.white,
      hoverColor: AppColors.white,
      fillColor: AppColors.white,
      labelStyle: const TextStyle(color: AppColors.grayLight),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.white),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.white),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.red),
      ),
      counterText: '',
    );
  }
}
