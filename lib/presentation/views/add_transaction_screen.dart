import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/utils/app_colors.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../controllers/transaction_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  final int? partyId;
  final String? type;
  final AppTransaction? txn;

  const AddTransactionScreen({super.key, this.partyId, this.type, this.txn});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TransactionController txnCtrl = Get.find();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();

  late Rx<Category> selectedCategory;
  late Rx<DateTime> selectedDate;
  final Rx<String?> selectedImagePath = Rx<String?>(null); // NEW

  @override
  void initState() {
    super.initState();

    final AppTransaction? existing = widget.txn;

    amountCtrl.text = existing?.amount.toString() ?? '';
    noteCtrl.text = existing?.note ?? '';

    selectedCategory = (existing?.category ?? Category.grocery).obs;
    selectedDate = (existing?.date ?? DateTime.now()).obs;
    selectedImagePath.value = existing?.imagePath; // NEW
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  // NEW: Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compress to save storage
    );
    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  // NEW: Remove selected image
  void _removeImage() {
    selectedImagePath.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackLight,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        foregroundColor: AppColors.textDark,
        title: Text(
          widget.txn == null ? 'Add Transaction' : 'Edit Transaction',
        ),
        backgroundColor: AppColors.blackLight,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(height: 1, color: AppColors.dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount Field
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}$'),
                      ),
                      LengthLimitingTextInputFormatter(12),
                    ],
                    style: TextStyle(color: AppColors.textDark),
                    cursorColor: AppColors.textDark,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      labelStyle: TextStyle(color: AppColors.textDark),
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(color: AppColors.grayLight),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.textDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.textDark,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
        
                  // Note Field
                  TextField(
                    controller: noteCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(color: AppColors.textDark),
                    maxLength: 100,
                    cursorColor: AppColors.textDark,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      labelStyle: TextStyle(color: AppColors.textDark),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.textDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.textDark,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
        
                  // Category Dropdown (Reactive)
                  Obx(
                    () => DropdownButtonFormField<Category>(
                      initialValue: selectedCategory.value,
                      style: TextStyle(color: AppColors.blue),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: AppColors.textDark),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.textDark,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.white,
                      ),
                      elevation: 8,
                      dropdownColor: AppColors.darkGray,
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      onChanged: (Category? newValue) {
                        if (newValue != null) {
                          selectedCategory.value = newValue;
                        }
                      },
                      items: Category.values.map<DropdownMenuItem<Category>>((
                        Category category,
                      ) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                category.icon,
                                size: 20,
                                color: AppColors.textDark,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                category.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
        
                  // Date Picker (Fully Reactive)
                  Obx(
                    () => ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.textDark),
                      ),
                      tileColor: AppColors.blackLight,
                      title: Text(
                        DateFormat(
                          'dd MMM yyyy • hh:mm a',
                        ).format(selectedDate.value),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        _getRelativeDateLabel(selectedDate.value),
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      trailing: const Icon(
                        Icons.calendar_today,
                        color: AppColors.textDark,
                      ),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.value,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.green,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          if (!context.mounted) return;
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              selectedDate.value,
                            ),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.green,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
        
                          if (time != null) {
                            selectedDate.value = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
        
                  // ── NEW: Attach Image Section ──────────────────────────────
                  Obx(() {
                    final path = selectedImagePath.value;
                    if (path == null) {
                      // Show "Add Image" button when no image is selected
                      return OutlinedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.textDark,
                        ),
                        label: const Text(
                          'Attach Image',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.textDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
        
                    // Show thumbnail + remove/change options when image is selected
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.textDark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Thumbnail — tappable to view full image
                          GestureDetector(
                            onTap: () => _showFullImage(path),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(11),
                              ),
                              child: Image.file(
                                File(path),
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Action row below thumbnail
                          Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: _pickImageFromGallery,
                                  icon: const Icon(
                                    Icons.swap_horiz,
                                    size: 18,
                                    color: AppColors.textDark,
                                  ),
                                  label: const Text(
                                    'Change',
                                    style: TextStyle(color: AppColors.textDark),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: AppColors.dividerColor,
                              ),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: _removeImage,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.red,
                                  ),
                                  label: const Text(
                                    'Remove',
                                    style: TextStyle(color: AppColors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
        
                  // ── END: Attach Image Section ──────────────────────────────
                  const SizedBox(height: 32),
        
                  // Save Button
                  ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.txn == null
                          ? 'Add Transaction'
                          : 'Update Transaction',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Full-screen image preview
  void _showFullImage(String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (amountCtrl.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an amount',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }

    double amount = double.tryParse(amountCtrl.text) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'Amount must be greater than 0',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }

    AppTransaction newTxn = AppTransaction(
      id: widget.txn?.id,
      partyId: widget.partyId ?? widget.txn!.partyId,
      amount: amount,
      type: widget.type ?? widget.txn!.type,
      date: selectedDate.value,
      note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
      category: selectedCategory.value,
      imagePath: selectedImagePath.value, // NEW
    );

    if (widget.txn == null) {
      txnCtrl.addTransaction(newTxn);
    } else {
      txnCtrl.updateTransaction(newTxn);
    }

    Get.back();
  }

  String _getRelativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == yesterday) return 'Yesterday';
    return DateFormat('EEEE').format(date);
  }
}
