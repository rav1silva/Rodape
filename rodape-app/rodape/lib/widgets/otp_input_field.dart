import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/input_formatters.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Campo de código de verificação (OTP) de N caixas, uma por dígito, com
/// avanço/retrocesso automático de foco — usado no passo "Código por SMS".
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  late final controllers = List.generate(widget.length, (_) => TextEditingController());
  late final focusNodes = List.generate(widget.length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Limpa todas as caixas e devolve o foco para a primeira — usado após
  /// um código incorreto, para o usuário tentar de novo.
  void clear() {
    for (final c in controllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
    widget.onChanged('');
  }

  String get _code => controllers.map((c) => c.text).join();

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      // Colar o código completo em uma caixa: distribui pelos campos.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < controllers.length; i++) {
        controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final lastFilled = (digits.length - 1).clamp(0, controllers.length - 1);
      focusNodes[lastFilled].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      focusNodes[index + 1].requestFocus();
    }

    widget.onChanged(_code);
    if (_code.length == widget.length) {
      widget.onCompleted?.call(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _digitBox(i)),
        ],
      ],
    );
  }

  Widget _digitBox(int index) {
    return Focus(
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controllers[index].text.isEmpty &&
            index > 0) {
          focusNodes[index - 1].requestFocus();
          controllers[index - 1].clear();
          widget.onChanged(_code);
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        height: 58,
        child: TextField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [DigitsOnlyFormatter(maxLength: widget.length)],
          maxLength: widget.length,
          style: AppTextStyles.mono(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surfaceCard,
            contentPadding: EdgeInsets.zero,
            border: _border(AppColors.wood800),
            enabledBorder: _border(widget.hasError ? AppColors.stampRed600 : AppColors.wood800),
            focusedBorder: _border(AppColors.spineOrange, width: 2),
          ),
          onChanged: (value) => _handleChanged(index, value),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(3),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
