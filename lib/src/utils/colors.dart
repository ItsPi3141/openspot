import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  if (hex.startsWith("#")) hex = hex.substring(1);
  return Color(int.parse(hex, radix: 16));
}
