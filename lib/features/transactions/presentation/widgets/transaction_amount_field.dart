import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class TransactionAmountField extends StatefulWidget {
  const TransactionAmountField({
    required this.controller,
    required this.focusNode,
    required this.isEnabled,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEnabled;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<TransactionAmountField> createState() => _TransactionAmountFieldState();
}

final class _TransactionAmountFieldState extends State<TransactionAmountField> {
  late bool _hasAmount;

  @override
  void initState() {
    super.initState();
    _hasAmount = widget.controller.text.isNotEmpty;
    widget.focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleAmountPresenceChange);
  }

  @override
  void didUpdateWidget(TransactionAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleAmountPresenceChange);
      widget.controller.addListener(_handleAmountPresenceChange);
      _hasAmount = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleAmountPresenceChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    final Color borderColor = hasError
        ? AppColors.destructiveAction
        : widget.focusNode.hasFocus
        ? AppColors.brandCobalt
        : AppColors.borderStrong;

    return Semantics(
      textField: true,
      label: 'Amount in Nepalese rupees',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedContainer(
            duration: AppMotion.accessibleDuration(context, AppMotion.fast),
            curve: AppMotion.emphasized,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: widget.focusNode.hasFocus
                  ? AppColors.brandSoft
                  : AppColors.surfacePrimary,
              border: Border.all(
                color: borderColor,
                width: widget.focusNode.hasFocus || hasError ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.signatureSurface),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Amount',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: widget.focusNode.hasFocus
                        ? AppColors.brandCobalt
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'NPR',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontFeatures: AppTypography.tabularFigures,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: TextField(
                          key: const ValueKey<String>('amount_input'),
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          enabled: widget.isEnabled,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          inputFormatters: <TextInputFormatter>[
                            const TransactionAmountInputFormatter(),
                          ],
                          onChanged: widget.onChanged,
                          scrollPadding: const EdgeInsets.only(
                            bottom: AppSpacing.navigationClearance,
                          ),
                          cursorColor: AppColors.brandCobalt,
                          style: AppTypography.financialDisplay(context)
                              .copyWith(
                                fontWeight: _hasAmount
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: AppMotion.accessibleDuration(context, AppMotion.fast),
            child: widget.errorText == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      left: AppSpacing.sm,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        widget.errorText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.destructiveAction,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleAmountPresenceChange() {
    final bool hasAmount = widget.controller.text.isNotEmpty;
    if (_hasAmount != hasAmount && mounted) {
      setState(() => _hasAmount = hasAmount);
    }
  }
}

final class TransactionAmountInputFormatter extends TextInputFormatter {
  const TransactionAmountInputFormatter();

  static final RegExp _validInput = RegExp(r'^\d{0,9}(?:\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _validInput.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
