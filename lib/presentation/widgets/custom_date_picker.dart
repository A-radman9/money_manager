import 'package:flutter/material.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../l10n/app_localizations.dart';

class CustomDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: enabled ? () => _selectDate(context) : null,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(12.0),
              color: enabled ? theme.cardColor : theme.disabledColor.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: enabled ? theme.primaryColor : theme.disabledColor,
                  size: 20.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? date_utils.DateUtils.formatDisplayDate(selectedDate!, Localizations.localeOf(context).languageCode)
                        : label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selectedDate != null
                          ? (enabled ? null : theme.disabledColor)
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: enabled ? theme.textTheme.bodyLarge?.color : theme.disabledColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      locale: Localizations.localeOf(context),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }
}

class DateRangePicker extends StatelessWidget {
  final String label;
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime?, DateTime?) onDateRangeSelected;
  final bool enabled;

  const DateRangePicker({
    super.key,
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: enabled ? () => _selectDateRange(context) : null,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(12.0),
              color: enabled ? theme.cardColor : theme.disabledColor.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: enabled ? theme.primaryColor : theme.disabledColor,
                  size: 20.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    _getDateRangeText(context),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: (startDate != null && endDate != null)
                          ? (enabled ? null : theme.disabledColor)
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: enabled ? theme.textTheme.bodyLarge?.color : theme.disabledColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDateRangeText(BuildContext context) {
    if (startDate != null && endDate != null) {
      final locale = Localizations.localeOf(context).languageCode;
      return '${date_utils.DateUtils.formatDisplayDate(startDate!, locale)} - ${date_utils.DateUtils.formatDisplayDate(endDate!, locale)}';
    }
    return 'Select date range';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: (startDate != null && endDate != null)
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      locale: Localizations.localeOf(context),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }
}
