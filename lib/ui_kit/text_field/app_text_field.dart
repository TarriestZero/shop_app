import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';

enum AppTextFieldType { text, name, email, phone, address }

/// Поле формы с общей темой, типом ввода и локализованной валидацией.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.type = AppTextFieldType.text,
    this.isRequired = false,
    this.minimumPhoneDigits = 10,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.validator,
    this.formFieldKey,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
  });

  final String label;
  final TextEditingController controller;
  final AppTextFieldType type;
  final bool isRequired;
  final int minimumPhoneDigits;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  /// Позволяет читать isValid внутреннего поля без изменения текста ошибки.
  final GlobalKey<FormFieldState<String>>? formFieldKey;

  /// По умолчанию ошибки показываются после потери фокуса.
  final AutovalidateMode autovalidateMode;

  static final _email = RegExp(
    r'^[^\s@.]+(?:\.[^\s@.]+)*@'
    r'(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = context.colors;
    final keyboard = switch (type) {
      AppTextFieldType.email => TextInputType.emailAddress,
      AppTextFieldType.phone => TextInputType.phone,
      AppTextFieldType.address => TextInputType.streetAddress,
      _ => TextInputType.text,
    };
    final autofill = switch (type) {
      AppTextFieldType.name => AutofillHints.name,
      AppTextFieldType.email => AutofillHints.email,
      AppTextFieldType.phone => AutofillHints.telephoneNumber,
      AppTextFieldType.address => AutofillHints.fullStreetAddress,
      AppTextFieldType.text => null,
    };

    return TextFormField(
      key: formFieldKey,
      controller: controller,
      enabled: enabled,
      keyboardType: keyboard,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofill == null ? null : [autofill],
      textCapitalization: switch (type) {
        AppTextFieldType.name => TextCapitalization.words,
        AppTextFieldType.address => TextCapitalization.sentences,
        _ => TextCapitalization.none,
      },
      autocorrect:
          type != AppTextFieldType.email && type != AppTextFieldType.phone,
      inputFormatters: type == AppTextFieldType.phone
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\-\s]'))]
          : null,
      minLines: type == AppTextFieldType.address ? 2 : 1,
      maxLines: type == AppTextFieldType.address ? 3 : 1,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.surface,
        errorMaxLines: 3,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return isRequired ? strings.fieldRequired : validator?.call(value);
        }
        if (type == AppTextFieldType.email && !_email.hasMatch(text)) {
          return strings.fieldInvalidEmail;
        }
        if (type == AppTextFieldType.phone &&
            text.replaceAll(RegExp(r'\D'), '').length < minimumPhoneDigits) {
          return strings.fieldInvalidPhone(minimumPhoneDigits);
        }
        return validator?.call(value);
      },
    );
  }
}
