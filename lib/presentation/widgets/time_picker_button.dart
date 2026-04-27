import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerButton extends StatelessWidget {
  final DateTime? scheduledTime;
  final ValueChanged<DateTime> onTimeSelected;

  const TimePickerButton({
    super.key,
    this.scheduledTime,
    required this.onTimeSelected,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: scheduledTime ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(scheduledTime ?? DateTime.now()),
    );

    if (time == null) return;

    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    onTimeSelected(scheduled);
  }

  @override
  Widget build(BuildContext context) {
    final hasTime = scheduledTime != null;
    final formattedTime = hasTime
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(scheduledTime!)
        : 'Select time';

    return InkWell(
      onTap: () => _pickDateTime(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasTime ? Colors.blue : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 18,
              color: hasTime ? Colors.blue : Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              formattedTime,
              style: TextStyle(
                color: hasTime ? Colors.blue : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
