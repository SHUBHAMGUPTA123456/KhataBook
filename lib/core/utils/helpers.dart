import 'package:flutter/material.dart';

class Helper {
  
  static double height(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

static double width(BuildContext context){
  return MediaQuery.of(context).size.width;
}

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    return (value as num).toDouble();
  }

}