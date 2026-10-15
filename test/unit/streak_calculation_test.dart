import 'package:flutter_test/flutter_test.dart';
import 'package:recova/features/routine/domain/streak_calculator.dart';

void main() {
  group('Streak Calculation Domain Logic', () {
    final referenceDate = DateTime(
      2026,
      5,
      10,
      14,
      30,
    ); // Reference: 2026-05-10
    final today = DateTime(2026, 5, 10);
    final yesterday = DateTime(2026, 5, 9);
    final twoDaysAgo = DateTime(2026, 5, 8);
    final threeDaysAgo = DateTime(2026, 5, 7);
    final fourDaysAgo = DateTime(2026, 5, 6);

    test('returns 0 when check-in list is empty', () {
      expect(calculateStreak([], referenceDate), 0);
      expect(calculateStreakFromStrings([], referenceDate), 0);
    });

    test('returns 1 when single check-in is today', () {
      final dates = [today];
      expect(calculateStreak(dates, referenceDate), 1);
      expect(calculateStreakFromStrings(['2026-05-10'], referenceDate), 1);
    });

    test(
      'returns 1 when single check-in was yesterday and today is pending',
      () {
        final dates = [yesterday];
        expect(calculateStreak(dates, referenceDate), 1);
        expect(calculateStreakFromStrings(['2026-05-09'], referenceDate), 1);
      },
    );

    test(
      'returns 0 when most recent check-in is two days ago (missed yesterday)',
      () {
        final dates = [twoDaysAgo];
        expect(calculateStreak(dates, referenceDate), 0);
        expect(calculateStreakFromStrings(['2026-05-08'], referenceDate), 0);
      },
    );

    test('returns correct streak for consecutive days ending today', () {
      final dates = [today, yesterday, twoDaysAgo, threeDaysAgo, fourDaysAgo];
      expect(calculateStreak(dates, referenceDate), 5);
      expect(
        calculateStreakFromStrings([
          '2026-05-10',
          '2026-05-09',
          '2026-05-08',
          '2026-05-07',
          '2026-05-06',
        ], referenceDate),
        5,
      );
    });

    test('returns correct streak for consecutive days ending yesterday', () {
      final dates = [yesterday, twoDaysAgo, threeDaysAgo, fourDaysAgo];
      expect(calculateStreak(dates, referenceDate), 4);
      expect(
        calculateStreakFromStrings([
          '2026-05-09',
          '2026-05-08',
          '2026-05-07',
          '2026-05-06',
        ], referenceDate),
        4,
      );
    });

    test(
      'resets streak to 1 when user checked in today but missed yesterday',
      () {
        final dates = [today, twoDaysAgo, threeDaysAgo];
        expect(calculateStreak(dates, referenceDate), 1);
        expect(
          calculateStreakFromStrings([
            '2026-05-10',
            '2026-05-08',
            '2026-05-07',
          ], referenceDate),
          1,
        );
      },
    );

    test('stops counting streak at first gap in consecutive days', () {
      final dates = [today, yesterday, threeDaysAgo, fourDaysAgo];
      expect(calculateStreak(dates, referenceDate), 2);
    });

    test('handles duplicate check-in timestamps on the same day correctly', () {
      final dates = [
        DateTime(2026, 5, 10, 8, 0),
        DateTime(2026, 5, 10, 18, 30),
        DateTime(2026, 5, 9, 9, 15),
        DateTime(2026, 5, 9, 21, 0),
        twoDaysAgo,
      ];
      expect(calculateStreak(dates, referenceDate), 3);
      expect(
        calculateStreakFromStrings([
          '2026-05-10T08:00:00Z',
          '2026-05-10T18:30:00Z',
          '2026-05-09T09:15:00Z',
          '2026-05-08T12:00:00Z',
        ], referenceDate),
        3,
      );
    });

    test('handles unordered check-in dates properly', () {
      final dates = [twoDaysAgo, today, yesterday];
      expect(calculateStreak(dates, referenceDate), 3);
    });

    test(
      'ignores check-in timestamps in the future relative to reference date',
      () {
        final futureDate = DateTime(2026, 5, 12);
        final dates = [futureDate, today, yesterday];
        expect(calculateStreak(dates, referenceDate), 2);
      },
    );

    test('handles dates across daylight saving time and timezone shifts', () {
      // Simulate timestamps with non-UTC local hour components across midnight
      final shiftDate1 = DateTime(2026, 5, 10, 23, 59, 59);
      final shiftDate2 = DateTime(2026, 5, 9, 0, 0, 1);
      final shiftDate3 = DateTime(2026, 5, 8, 12, 0, 0);

      expect(
        calculateStreak([shiftDate1, shiftDate2, shiftDate3], referenceDate),
        3,
      );
    });
  });
}
