import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';

class AppGradiantBtn extends StatelessWidget {
  final String btnTitle;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final double height;
  final double width;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double textSize;
  final Color startColor;
  final Color centerColor;
  final Color endColor;

   AppGradiantBtn({super.key,
  required this.btnTitle,
  required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.height = 48,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor = AppColors.black,
    this.startColor = AppColors.white,
    this.centerColor = AppColors.white,
    this.endColor = AppColors.white,
    this.textSize = 14,
    this.width = double.infinity,
  }
);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[
            startColor,
            centerColor,
            endColor,
          ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 5.0,
            ),
          ]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size.copy(Size(280, 40))
        ),
        onPressed: onPressed,
        child: Text(
          btnTitle,
          style: TextStyle(
            color: textColor,
            fontSize: textSize,
          ),
        ),
      ),
    );
  }
}
