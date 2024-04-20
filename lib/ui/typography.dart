import 'package:flutter/material.dart';
import 'package:openspot/ui/theme_provider.dart';
import 'package:provider/provider.dart';

class DynamicColorText extends Text {
  const DynamicColorText(
    super.data, {
    super.key,
    super.style,
    super.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvier(),
      builder: (context, child) => super.build(context),
    );
  }
}
