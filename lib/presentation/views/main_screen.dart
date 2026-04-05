import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:khata_book/core/utils/app_colors.dart';
import 'package:khata_book/presentation/widgets/app_gradiant_btn.dart';
import 'package:khata_book/presentation/widgets/app_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/party.dart';
import '../controllers/party_controller.dart';
import '../widgets/party_list_item.dart';
import 'party_detail_screen.dart';
import 'report_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {

  late TabController _tabController;
  final PartyController partyCtrl = Get.find<PartyController>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  String selectedType = 'customer';
  final regexPhone = RegExp(r'^(?:91)?[6-9]\d{9}$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    partyCtrl.loadParties();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackLight,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text(
          'My Khata Book',
          style: TextStyle(color: AppColors.textDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: AppColors.textDark),
            onPressed: () => Get.to(() => ReportScreen(), transition: Transition.leftToRight),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textDark,
          indicatorColor: AppColors.white,
          unselectedLabelColor: AppColors.textDisable,
          tabs: const [
            Tab(text: 'Customer'),
            Tab(text: 'Supplier'),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.blackLight,
                AppColors.blackLight,
                AppColors.blackLight,
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTab(
            'customer',
            partyCtrl.customers,
            partyCtrl.customerNetBalance,
          ),
          buildTab(
            'supplier',
            partyCtrl.suppliers,
            partyCtrl.supplierNetBalance,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddPartyDialog(),
        heroTag: null,
        tooltip: 'Add Party',
        backgroundColor: AppColors.white,
        child: const Icon(Icons.add, color: AppColors.black),
      ),
    );
  }

  Widget buildTab(String type, RxList<Party> parties, RxDouble netBalance) {
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
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
                ? const Center(
                    child: Text(
                      'No parties yet. Add one!',
                      style: TextStyle(color: AppColors.textDarkOne),
                    ),
                  )
                : ListView.builder(
                 /*   separatorBuilder: (context, index) {
                      return const Divider(
                        color: AppColors.dividerColor,
                        thickness: 1.0,
                        indent: 16.0,
                        endIndent: 16.0,
                      );
                    },*/
                    itemCount: parties.length,
                    itemBuilder: (ctx, i) {
                      final party = parties[i];
                      return Obx(() {
                        final balance =
                            partyCtrl.partyBalances[party.id!] ?? 0.0;
                        final bool isLoading = !partyCtrl.partyBalances
                            .containsKey(party.id!);

                        if (isLoading) {
                          return const ListTile(
                            leading: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            title: Text('Calculating balance...'),
                          );
                        }

                        String label = balance >= 0 ? 'Due' : 'Advance';
                        Color color = balance >= 0
                            ? AppColors.red
                            : AppColors.green;

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

  void showAddPartyDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.blackLight,
        insetPadding: EdgeInsets.all(4),
        contentTextStyle: TextStyle(color: AppColors.white),
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
              style: TextStyle(color: AppColors.white),
              cursorColor: AppColors.white,
              cursorErrorColor: AppColors.red,
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              decoration: getInputDecoration('Name', false),
            ),
            TextField(
              controller: phoneCtrl,
              style: TextStyle(color: AppColors.white),
              decoration: getInputDecoration('Phone', true),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              cursorColor: AppColors.white,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              style: TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                labelText: 'Type',
                focusColor: AppColors.black,
                hoverColor: AppColors.black,
                fillColor: AppColors.black,
                labelStyle: TextStyle(color: AppColors.grayLight),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.white),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: UnderlineInputBorder(
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
                        style: TextStyle(color: AppColors.white),
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
              if (nameCtrl.text.trim().isEmpty){
                Get.snackbar("Can't be empty", "Please enter a name", backgroundColor: AppColors.red, colorText: AppColors.white);
                return;
              }
              if (phoneCtrl.text.trim().isEmpty){
                Get.snackbar("Can't be empty", "Please enter a Phone Number", backgroundColor: AppColors.red, colorText: AppColors.white);
                return;
              }
              if(nameCtrl.text.trim().isNotEmpty){
                if(!regexPhone.hasMatch(phoneCtrl.text.trim())){
                  Get.snackbar("Invalid Phone Number", "Please enter a valid phone number", backgroundColor: AppColors.red, colorText: AppColors.white);
                  return;
                }
              }

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
      ),
    );
  }

  InputDecoration getInputDecoration(String labelText, bool showSuffixIcon) {
    return InputDecoration(
      labelText: labelText,
      focusColor: AppColors.white,
      hoverColor: AppColors.white,
      fillColor: AppColors.white,
      labelStyle: TextStyle(color: AppColors.grayLight),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.white),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.white),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.red),
      ),
      counterText: '',
      suffixIcon: showSuffixIcon
          ? IconButton(
              onPressed: () {
                pickContact();
              },
              icon: Icon(
                Icons.perm_contact_calendar_rounded,
                color: AppColors.white,
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Future<void> pickContact() async {
    PermissionStatus status = await Permission.contacts.status;

    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      final contact = await FlutterContacts.openExternalPick();

      if (contact != null && contact.phones.isNotEmpty) {
        String phone = contact.phones.first.number;

        // Remove spaces, +, -, etc
        phone = phone.replaceAll(RegExp(r'\D'), '');

        // Take last 10 digits (removes +91, 0, etc)
        if (phone.length > 10) {
          phone = phone.substring(phone.length - 10);
        }

        phoneCtrl.text = phone;
      }
    } else if (status.isDenied) {
      Get.snackbar("Permission Denied", "Please allow contacts permission");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

}