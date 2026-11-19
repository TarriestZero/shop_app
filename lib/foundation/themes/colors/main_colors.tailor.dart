// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_colors.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$FoundationColorsTailorMixin on ThemeExtension<FoundationColors> {
  Color get primary;
  Color get appBackground;
  Color get surface;
  Color get textPrimary;
  Color get textSecondary;
  Color get border;
  Color get error;
  Color get success;

  @override
  FoundationColors copyWith({
    Color? primary,
    Color? appBackground,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? error,
    Color? success,
  }) {
    return FoundationColors(
      primary: primary ?? this.primary,
      appBackground: appBackground ?? this.appBackground,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  FoundationColors lerp(
    covariant ThemeExtension<FoundationColors>? other,
    double t,
  ) {
    if (other is! FoundationColors) return this as FoundationColors;
    return FoundationColors(
      primary: Color.lerp(primary, other.primary, t)!,
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FoundationColors &&
            const DeepCollectionEquality().equals(primary, other.primary) &&
            const DeepCollectionEquality().equals(
              appBackground,
              other.appBackground,
            ) &&
            const DeepCollectionEquality().equals(surface, other.surface) &&
            const DeepCollectionEquality().equals(
              textPrimary,
              other.textPrimary,
            ) &&
            const DeepCollectionEquality().equals(
              textSecondary,
              other.textSecondary,
            ) &&
            const DeepCollectionEquality().equals(border, other.border) &&
            const DeepCollectionEquality().equals(error, other.error) &&
            const DeepCollectionEquality().equals(success, other.success));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(primary),
      const DeepCollectionEquality().hash(appBackground),
      const DeepCollectionEquality().hash(surface),
      const DeepCollectionEquality().hash(textPrimary),
      const DeepCollectionEquality().hash(textSecondary),
      const DeepCollectionEquality().hash(border),
      const DeepCollectionEquality().hash(error),
      const DeepCollectionEquality().hash(success),
    );
  }
}

extension FoundationColorsBuildContextProps on BuildContext {
  FoundationColors get foundationColors =>
      Theme.of(this).extension<FoundationColors>()!;
  Color get primary => foundationColors.primary;
  Color get appBackground => foundationColors.appBackground;
  Color get surface => foundationColors.surface;
  Color get textPrimary => foundationColors.textPrimary;
  Color get textSecondary => foundationColors.textSecondary;
  Color get border => foundationColors.border;
  Color get error => foundationColors.error;
  Color get success => foundationColors.success;
}
