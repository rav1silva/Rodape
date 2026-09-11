import 'package:flutter/services.dart';

/// Formata dígitos livres como CEP: `00000-000`.
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '').substring(
      0,
      newValue.text.replaceAll(RegExp(r'\D'), '').length.clamp(0, 8),
    );

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 5) buffer.write('-');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Formata dígitos livres como número de celular brasileiro sem DDD:
/// `90000-0000`.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '').substring(
      0,
      newValue.text.replaceAll(RegExp(r'\D'), '').length.clamp(0, 9),
    );

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 5) buffer.write('-');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Só dígitos, até [maxLength] caracteres — usado nas caixas do código OTP.
class DigitsOnlyFormatter extends TextInputFormatter {
  DigitsOnlyFormatter({this.maxLength = 1});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.substring(0, digits.length.clamp(0, maxLength));
    return TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );
  }
}
