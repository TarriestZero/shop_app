import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/core/exceptions/user_error_message.dart';
import 'package:shop_app/features/filters/presentation/filters/bloc/filters_controller.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

/// Общая страница фильтров. Создание и закрытие контроллера остаётся у владельца.
class FiltersScreen<T> extends StatelessWidget {
  const FiltersScreen({
    super.key,
    required this.controller,
    required this.filtersBuilder,
    required this.onApply,
  });

  final FiltersController<T> controller;
  final Widget Function(BuildContext context, T filters) filtersBuilder;
  final ValueChanged<T> onApply;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: controller,
      child: BlocConsumer<FiltersController<T>, FiltersState<T>>(
        listenWhen: (previous, current) => current is FiltersApplied<T>,
        listener: (context, state) => onApply(state.filters),
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(strings.filtersTitle),
            actions: [
              AppButton.text(
                onPressed: controller.reset,
                label: strings.filtersReset,
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: filtersBuilder(context, state.filters),
                  ),
                ),
                if (state is FiltersFailure<T>)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          userErrorMessage(
                            state.exception,
                            strings,
                            fallback: strings.filtersCountFailed,
                          ),
                          style: TextStyle(color: context.colors.error),
                          textAlign: TextAlign.center,
                        ),
                        AppButton.text(
                          onPressed: controller.load,
                          label: strings.retry,
                        ),
                      ],
                    ),
                  ),
                if (state is FiltersLoading<T>)
                  LinearProgressIndicator(
                    semanticsLabel: strings.filtersCounting,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      onPressed: state is FiltersReady<T>
                          ? controller.apply
                          : null,
                      label: state.count == null
                          ? strings.filtersApply
                          : strings.filtersShowResults(state.count!),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
