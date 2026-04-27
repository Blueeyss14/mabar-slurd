import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/custom_colors.dart';
import 'package:mabar_slurd/shared/buttons/mabar_button.dart';

class CalendarPop extends StatelessWidget {
  final bool isCalendarPoping;
  final void Function(DateTime) onDateChanged;
  final VoidCallback onClose;

  const CalendarPop({
    super.key,
    required this.isCalendarPoping,
    required this.onClose,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCalendarPoping) return const SizedBox();

    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withAlpha(200),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomColors.mabarSurfaceInput,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withAlpha(200)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select Date",
                      style: TextStyle(
                        color: CustomColors.mabarTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close,
                        color: CustomColors.mabarTextPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: CustomColors.mabarSurfaceInput,
                      onPrimary: CustomColors.mabarBorderFocus,
                      onSurface: CustomColors.mabarTextPrimary,
                    ),
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(color: Colors.black),
                      titleMedium: TextStyle(color: Colors.black),
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    onDateChanged: onDateChanged,
                  ),
                ),

                const SizedBox(height: 12),

                MabarButton(onTap: onClose, text: "Pilih"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
