import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/budget_cycle.dart';
import '../../../../core/utils/budget_cycle_util.dart';

class BudgetCycleSelector extends StatelessWidget {
  final BudgetCycle currentCycle;
  final BudgetCycle? selectedCycle;
  final List<BudgetCycle> cycles;
  final Function(BudgetCycle) onCycleSelected;

  const BudgetCycleSelector({
    super.key,
    required this.currentCycle,
    required this.selectedCycle,
    required this.cycles,
    required this.onCycleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCycle?.cycleString ?? currentCycle.cycleString,
      decoration: const InputDecoration(
        labelText: 'Budget Cycle',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      items: cycles.map((cycle) {
        final isCurrentCycle = cycle.cycleString == currentCycle.cycleString;
        final displayText = BudgetCycleUtil.formatCycleDisplay(
          cycle.startDate,
          cycle.endDate,
        );

        return DropdownMenuItem<String>(
          value: cycle.cycleString,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontWeight: isCurrentCycle ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentCycle ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
              ),
              if (isCurrentCycle)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          final cycle = cycles.firstWhere((c) => c.cycleString == value);
          onCycleSelected(cycle);
        }
      },
    );
  }
}

class BudgetCycleChip extends StatelessWidget {
  final BudgetCycle cycle;

  const BudgetCycleChip({super.key, required this.cycle});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final startText = dateFormat.format(cycle.startDate);
    final endText = dateFormat.format(cycle.endDate);

    return Chip(
      avatar: const Icon(Icons.calendar_today, size: 16),
      label: Text(
        '$startText - $endText',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
