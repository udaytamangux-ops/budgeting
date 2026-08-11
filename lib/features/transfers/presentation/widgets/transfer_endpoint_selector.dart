import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:flutter/material.dart';

final class TransferSourceSelector extends StatelessWidget {
  const TransferSourceSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final TransferSource value;
  final bool enabled;
  final ValueChanged<TransferSource> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<TransferSource>(
    key: const ValueKey<String>('transfer_source_selector'),
    initialValue: value,
    isExpanded: true,
    decoration: const InputDecoration(
      labelText: 'From',
      prefixIcon: Icon(Icons.upload_outlined),
    ),
    items: TransferSource.values
        .map(
          (source) => DropdownMenuItem<TransferSource>(
            value: source,
            child: Text(source.label),
          ),
        )
        .toList(growable: false),
    onChanged: enabled
        ? (TransferSource? source) {
            if (source != null) onChanged(source);
          }
        : null,
  );
}

final class TransferDestinationSelector extends StatelessWidget {
  const TransferDestinationSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final TransferDestination value;
  final bool enabled;
  final ValueChanged<TransferDestination> onChanged;

  @override
  Widget build(BuildContext context) =>
      DropdownButtonFormField<TransferDestination>(
        key: const ValueKey<String>('transfer_destination_selector'),
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'To',
          prefixIcon: Icon(Icons.download_outlined),
        ),
        items: TransferDestination.values
            .map(
              (destination) => DropdownMenuItem<TransferDestination>(
                value: destination,
                child: Text(destination.label),
              ),
            )
            .toList(growable: false),
        onChanged: enabled
            ? (TransferDestination? destination) {
                if (destination != null) onChanged(destination);
              }
            : null,
      );
}
