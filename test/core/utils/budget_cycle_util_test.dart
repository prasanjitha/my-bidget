import 'package:flutter_test/flutter_test.dart';
import 'package:bidget/core/utils/budget_cycle_util.dart';

void main() {
  group('BudgetCycleUtil - Basic Calculations', () {
    test('getCurrentCycle returns a valid cycle', () {
      final cycle = BudgetCycleUtil.getCurrentCycle(10);

      expect(cycle.startDate, isNotNull);
      expect(cycle.endDate, isNotNull);
      expect(cycle.cycleString, isNotNull);
      expect(cycle.endDate.isAfter(cycle.startDate), isTrue);
    });

    test('getCycleForDate with date before start day', () {
      // June 5, start day = 10, should give May 10 - June 9
      final date = DateTime(2026, 6, 5);
      final cycle = BudgetCycleUtil.getCycleForDate(date, 10);

      expect(cycle.startDate, DateTime(2026, 5, 10));
      expect(cycle.startDate.day, 10);
      expect(cycle.endDate.day, 9);
    });

    test('getCycleForDate with date on or after start day', () {
      // June 15, start day = 10, should give June 10 - July 9
      final date = DateTime(2026, 6, 15);
      final cycle = BudgetCycleUtil.getCycleForDate(date, 10);

      expect(cycle.startDate, DateTime(2026, 6, 10));
      expect(cycle.endDate.day, 9);
      expect(cycle.endDate.month, 7);
    });

    test('getCycleForDate with start day = 1', () {
      // Should match calendar month
      final date = DateTime(2026, 6, 15);
      final cycle = BudgetCycleUtil.getCycleForDate(date, 1);

      expect(cycle.startDate.day, 1);
      expect(cycle.startDate.month, 6);
      expect(cycle.endDate.day, DateTime(2026, 7, 0).day); // Last day of June
    });
  });

  group('BudgetCycleUtil - Edge Cases', () {
    test('handles start day 31 in February (28 days)', () {
      final date = DateTime(2026, 2, 15); // Non-leap year
      final cycle = BudgetCycleUtil.getCycleForDate(date, 31);

      // February has 28 days, so effective start day is 28
      // Date is Feb 15, which is >= 28? No, so cycle is from January
      expect(cycle.startDate.month, 1); // January
      expect(cycle.startDate.day, 31);
    });

    test('handles start day 31 in February (29 days - leap year)', () {
      final date = DateTime(2024, 2, 15); // Leap year
      final cycle = BudgetCycleUtil.getCycleForDate(date, 31);

      // February 2024 has 29 days, so effective start day is 29
      // Date is Feb 15, which is >= 29? No, so cycle is from January
      expect(cycle.startDate.month, 1); // January
      expect(cycle.startDate.day, 31);
    });

    test('handles start day 31 in April (30 days)', () {
      final date = DateTime(2026, 4, 15);
      final cycle = BudgetCycleUtil.getCycleForDate(date, 31);

      // April has 30 days, so effective start day is 30
      // Date is April 15, which is >= 30? No, so cycle is from March
      expect(cycle.startDate.month, 3); // March
      expect(cycle.startDate.day, 31);
    });

    test('handles year boundary crossing backward', () {
      // January 5, start day = 10, should give Dec 10 - Jan 9
      final date = DateTime(2026, 1, 5);
      final cycle = BudgetCycleUtil.getCycleForDate(date, 10);

      expect(cycle.startDate.year, 2025);
      expect(cycle.startDate.month, 12);
      expect(cycle.startDate.day, 10);
      expect(cycle.endDate.year, 2026);
      expect(cycle.endDate.month, 1);
    });

    test('handles year boundary crossing forward', () {
      // December 15, start day = 10, should give Dec 10 - Jan 9
      final date = DateTime(2026, 12, 15);
      final cycle = BudgetCycleUtil.getCycleForDate(date, 10);

      expect(cycle.startDate.year, 2026);
      expect(cycle.startDate.month, 12);
      expect(cycle.endDate.year, 2027);
      expect(cycle.endDate.month, 1);
    });
  });

  group('BudgetCycleUtil - Formatting', () {
    test('formatCycleString creates correct format', () {
      final start = DateTime(2026, 6, 10);
      final end = DateTime(2026, 7, 9);
      final formatted = BudgetCycleUtil.formatCycleString(start, end);

      expect(formatted, '2026-06-10_2026-07-09');
    });

    test('formatCycleDisplay creates readable format', () {
      final start = DateTime(2026, 6, 10);
      final end = DateTime(2026, 7, 9);
      final formatted = BudgetCycleUtil.formatCycleDisplay(start, end);

      expect(formatted, 'Jun 10, 2026 - Jul 9, 2026');
    });

    test('parseCycleString parses valid cycle string', () {
      final cycleString = '2026-06-10_2026-07-09';
      final cycle = BudgetCycleUtil.parseCycleString(cycleString);

      expect(cycle, isNotNull);
      expect(cycle!.startDate, DateTime(2026, 6, 10));
      expect(cycle.endDate, DateTime(2026, 7, 9));
      expect(cycle.cycleString, cycleString);
    });

    test('parseCycleString returns null for invalid string', () {
      final cycle = BudgetCycleUtil.parseCycleString('invalid');
      expect(cycle, isNull);
    });
  });

  group('BudgetCycleUtil - Multiple Cycles', () {
    test('generateCycleList creates multiple cycles', () {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 6, 30);
      final cycles = BudgetCycleUtil.generateCycleList(from, to, 10);

      expect(cycles.length, greaterThan(0));
      expect(cycles.length, lessThanOrEqualTo(7)); // Max 7 months

      // Check cycles are in sequence
      for (int i = 1; i < cycles.length; i++) {
        expect(
          cycles[i].startDate.isAfter(cycles[i - 1].startDate),
          isTrue,
        );
      }
    });

    test('getPastCycles returns correct number of cycles', () {
      final cycles = BudgetCycleUtil.getPastCycles(5, 10);

      expect(cycles.length, greaterThanOrEqualTo(1));
      expect(cycles.length, lessThanOrEqualTo(5));

      // Most recent cycle should be first
      final now = DateTime.now();
      expect(
        BudgetCycleUtil.isDateInCycle(now, cycles.first),
        isTrue,
      );
    });

    test('getSimpleCycleString returns YYYY-MM format', () {
      final date = DateTime(2026, 6, 15);
      final simple = BudgetCycleUtil.getSimpleCycleString(date, 10);

      expect(simple, '2026-06');
    });

    test('getSimpleCycleString handles previous month', () {
      final date = DateTime(2026, 6, 5);
      final simple = BudgetCycleUtil.getSimpleCycleString(date, 10);

      expect(simple, '2026-05');
    });
  });

  group('BudgetCycleUtil - Date Checks', () {
    test('isDateInCycle returns true for date within cycle', () {
      final cycle = BudgetCycleUtil.getCycleForDate(DateTime(2026, 6, 15), 10);
      final dateInCycle = DateTime(2026, 6, 20);

      expect(BudgetCycleUtil.isDateInCycle(dateInCycle, cycle), isTrue);
    });

    test('isDateInCycle returns false for date outside cycle', () {
      final cycle = BudgetCycleUtil.getCycleForDate(DateTime(2026, 6, 15), 10);
      final dateOutside = DateTime(2026, 7, 20);

      expect(BudgetCycleUtil.isDateInCycle(dateOutside, cycle), isFalse);
    });

    test('isDateInCycle returns true for cycle start date', () {
      final cycle = BudgetCycleUtil.getCycleForDate(DateTime(2026, 6, 15), 10);

      expect(BudgetCycleUtil.isDateInCycle(cycle.startDate, cycle), isTrue);
    });

    test('isDateInCycle returns true for cycle end date', () {
      final cycle = BudgetCycleUtil.getCycleForDate(DateTime(2026, 6, 15), 10);

      expect(BudgetCycleUtil.isDateInCycle(cycle.endDate, cycle), isTrue);
    });
  });

  group('BudgetCycleUtil - All Months Coverage', () {
    test('handles all 12 months correctly', () {
      for (int month = 1; month <= 12; month++) {
        final date = DateTime(2026, month, 15);
        final cycle = BudgetCycleUtil.getCycleForDate(date, 10);

        expect(cycle.startDate, isNotNull);
        expect(cycle.endDate, isNotNull);
        expect(cycle.endDate.isAfter(cycle.startDate), isTrue);
      }
    });

    test('handles all start days 1-31', () {
      for (int startDay = 1; startDay <= 31; startDay++) {
        final date = DateTime(2026, 6, 15);
        final cycle = BudgetCycleUtil.getCycleForDate(date, startDay);

        expect(cycle.startDate, isNotNull);
        expect(cycle.endDate, isNotNull);
        expect(cycle.endDate.isAfter(cycle.startDate), isTrue);
      }
    });
  });
}
