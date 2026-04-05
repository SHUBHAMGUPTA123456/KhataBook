import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final TextInputAction textInputAction;
  final Color hintTextColor;
  final int maxLength;
  final double outlineInputBorder;
  final Color outlineBorderColor;
  final double textSize;


  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.textInputAction = TextInputAction.next,
    this.hintTextColor = Colors.black,
    this.maxLength = 100,
    this.outlineInputBorder = 50,
    this.outlineBorderColor = Colors.black,
    this.textSize = 14,

  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(outlineInputBorder),
      shadowColor: AppColors.white,
      elevation: 1,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        textInputAction: textInputAction,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        maxLength: maxLength,
        cursorColor: AppColors.white,
        cursorErrorColor: AppColors.red,
        decoration: InputDecoration(
          hintText: hintText,
          counterText: '',
          hintStyle: TextStyle(color: hintTextColor, fontSize: textSize),
          labelStyle: TextStyle(color: hintTextColor, fontSize: textSize),
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: _defaultBorder(),
          enabledBorder: _defaultBorder(),
          focusedBorder: _focusedBorder(),
          errorBorder: _errorBorder(),
          focusedErrorBorder: _errorBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _defaultBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(outlineInputBorder),
      borderSide: BorderSide(color: outlineBorderColor),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(outlineInputBorder),
      borderSide:  BorderSide(color: outlineBorderColor, width: 1),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(outlineInputBorder),
      borderSide:  BorderSide(color: outlineBorderColor),
    );
  }
}
