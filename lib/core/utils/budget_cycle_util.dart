import 'package:intl/intl.dart';
import '../../features/home/domain/models/budget_cycle.dart';

/// Utility class for budget cycle calculations
class BudgetCycleUtil {
  /// Get the current budget cycle based on start day
  static BudgetCycle getCurrentCycle(int startDay) {
    return getCycleForDate(DateTime.now(), startDay);
  }

  /// Calculate budget cycle for a specific date
  ///
  /// Rules:
  /// - Cycle runs from start day to (start day - 1) of next month
  /// - If current date < start day: cycle is from previous month
  /// - If current date >= start day: cycle is from current month
  /// - If start day > days in month: use last day of that month
  static BudgetCycle getCycleForDate(DateTime date, int startDay) {
    int year = date.year;
    int month = date.month;

    // Check if start day exceeds days in current month
    final daysInCurrentMonth = _getDaysInMonth(year, month);
    final effectiveStartDay = startDay > daysInCurrentMonth ? daysInCurrentMonth : startDay;

    // If current date is before the effective start day, the cycle started last month
    if (date.day < effectiveStartDay) {
      month -= 1;
      if (month == 0) {
        month = 12;
        year -= 1;
      }
    }

    // Calculate start date (handle edge case where start day > days in month)
    final daysInStartMonth = _getDaysInMonth(year, month);
    final actualStartDay = startDay > daysInStartMonth ? daysInStartMonth : startDay;
    final startDate = DateTime(year, month, actualStartDay);

    // Calculate end date (one day before start day of next month)
    int endMonth = month + 1;
    int endYear = year;
    if (endMonth > 12) {
      endMonth = 1;
      endYear += 1;
    }

    final daysInEndMonth = _getDaysInMonth(endYear, endMonth);
    final actualEndDay = startDay > daysInEndMonth ? daysInEndMonth : startDay;
    final endDate = DateTime(endYear, endMonth, actualEndDay).subtract(const Duration(days: 1));

    // Format cycle string
    final cycleString = formatCycleString(startDate, endDate);

    return BudgetCycle(
      startDate: startDate,
      endDate: endDate,
      cycleString: cycleString,
    );
  }

  /// Format budget cycle as a string
  static String formatCycleString(DateTime startDate, DateTime endDate) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return '${dateFormat.format(startDate)}_${dateFormat.format(endDate)}';
  }

  /// Format budget cycle for display (human-readable)
  static String formatCycleDisplay(DateTime startDate, DateTime endDate) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
  }

  /// Parse cycle string back to BudgetCycle
  static BudgetCycle? parseCycleString(String cycleString) {
    try {
      final parts = cycleString.split('_');
      if (parts.length != 2) return null;

      final dateFormat = DateFormat('yyyy-MM-dd');
      final startDate = dateFormat.parse(parts[0]);
      final endDate = dateFormat.parse(parts[1]);

      return BudgetCycle(
        startDate: startDate,
        endDate: endDate,
        cycleString: cycleString,
      );
    } catch (e) {
      return null;
    }
  }

  /// Generate a list of budget cycles between two dates
  static List<BudgetCycle> generateCycleList(
    DateTime from,
    DateTime to,
    int startDay,
  ) {
    final cycles = <BudgetCycle>[];
    DateTime currentDate = from;

    while (currentDate.isBefore(to) || currentDate.isAtSameMomentAs(to)) {
      final cycle = getCycleForDate(currentDate, startDay);

      // Avoid duplicates
      if (cycles.isEmpty || cycles.last.cycleString != cycle.cycleString) {
        cycles.add(cycle);
      }

      // Move to next month
      int nextMonth = currentDate.month + 1;
      int nextYear = currentDate.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear += 1;
      }
      currentDate = DateTime(nextYear, nextMonth, currentDate.day);
    }

    return cycles;
  }

  /// Get past budget cycles (last N cycles)
  static List<BudgetCycle> getPastCycles(int count, int startDay) {
    final cycles = <BudgetCycle>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final date = DateTime(now.year, now.month - i, now.day);
      final cycle = getCycleForDate(date, startDay);

      // Avoid duplicates
      if (cycles.isEmpty || cycles.last.cycleString != cycle.cycleString) {
        cycles.add(cycle);
      }
    }

    return cycles;
  }

  /// Check if a date falls within a budget cycle
  static bool isDateInCycle(DateTime date, BudgetCycle cycle) {
    return (date.isAfter(cycle.startDate) || date.isAtSameMomentAs(cycle.startDate)) &&
        (date.isBefore(cycle.endDate) || date.isAtSameMomentAs(cycle.endDate));
  }

  /// Get the number of days in a month
  static int _getDaysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    }
    return DateTime(year, month + 1, 0).day;
  }

  /// Get the simplified cycle string (YYYY-MM format)
  /// Used for backward compatibility with existing implementation
  static String getSimpleCycleString(DateTime date, int startDay) {
    int year = date.year;
    int month = date.month;

    if (date.day < startDay) {
      month -= 1;
      if (month == 0) {
        month = 12;
        year -= 1;
      }
    }

    return '$year-${month.toString().padLeft(2, '0')}';
  }
}
