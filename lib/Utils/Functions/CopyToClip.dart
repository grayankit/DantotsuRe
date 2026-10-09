import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'SnackBar.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';

void copyToClipboard(String text, {String? message}) {
  Clipboard.setData(ClipboardData(text: text));
  debugPrint("Copied to clipboard: $text");
  snackString(message ?? getString.copiedToClipboard, simple: true);
}
