import 'package:flutter/services.dart';

/// Custom TextInputFormatter to add thousand separators
/// Formats numbers as: 30000 → 30,000 or 1234567.89 → 1,234,567.89
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters except decimal point
    String text = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Prevent multiple decimal points
    if (text.split('.').length > 2) {
      return oldValue;
    }

    // Split by decimal point
    final parts = text.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Limit decimal places to 2
    if (decimalPart != null && decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    // Add thousand separators to integer part
    String formattedInteger = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formattedInteger = ',$formattedInteger';
      }
      formattedInteger = integerPart[i] + formattedInteger;
      count++;
    }

    // Combine integer and decimal parts
    String formattedText = formattedInteger;
    if (decimalPart != null) {
      formattedText += '.$decimalPart';
    } else if (text.endsWith('.')) {
      formattedText += '.';
    }

    // Calculate new cursor position
    int selectionIndex = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
