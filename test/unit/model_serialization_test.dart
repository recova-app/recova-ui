import 'package:flutter_test/flutter_test.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/models/post_model.dart';
import 'package:recova/models/community_like_data.dart';

void main() {
  group('OpenAPI Envelope Model Deserialization', () {
    test(
      'RoutineCheckInResponseData deserializes check-in, statistics, and relapse solution',
      () {
        final json = {
          'check_in': {
            'id': 'checkin_123',
            'user_id': 'user_123',
            'check_in_date': '2026-05-10',
            'check_in_day_name': 'Sabtu',
            'mood': 'tenang',
            'is_successful': true,
            'commitment': 'Tetap konsisten',
            'relapse_trigger': <String>[],
            'created_at': '2026-05-10T09:00:00Z',
          },
          'statistics': {
            'current_streak': 5,
            'longest_streak': 12,
            'total_checkins': 24,
            'total_attempts': 28,
            'success_rate': 0.86,
            'streak_calendar': ['2026-05-08', '2026-05-09', '2026-05-10'],
            'relapse_calendar': ['2026-05-06', '2026-05-08'],
            'relapse_count': 3,
            'relapse_rate': 0.12,
            'recovery_success_rate': 0.88,
            'checkin_consistency_score': 84.5,
            'weekly_progress': {
              'window_days': 7,
              'current_successful_checkins': 6,
              'previous_successful_checkins': 5,
              'delta': 1,
              'delta_rate': 0.2,
            },
            'monthly_progress': {
              'window_days': 30,
              'current_successful_checkins': 24,
              'previous_successful_checkins': 20,
              'delta': 4,
              'delta_rate': 0.2,
            },
            'mood_trend': [
              {
                'date': '2026-05-10',
                'day_name': 'Sabtu',
                'dominant_mood': 'tenang',
                'successful_ratio': 1.0,
              },
            ],
            'last_check_in_date': '2026-05-10',
            'last_check_in_day_name': 'Sabtu',
          },
          'relapse_solution': {
            'title': 'Tips Mengelola Stres',
            'analysis': 'Stres kerja memicu dorongan impulsif.',
            'summary': 'Lakukan latihan pernapasan dan istirahat sejenak.',
            'generated_at': '2026-05-10T09:00:00Z',
          },
        };

        final response = RoutineCheckInResponseData.fromJson(json);

        expect(response.checkIn.id, 'checkin_123');
        expect(response.checkIn.userId, 'user_123');
        expect(response.checkIn.checkInDate, '2026-05-10');
        expect(response.checkIn.checkInDayName, 'Sabtu');
        expect(response.checkIn.mood, 'tenang');
        expect(response.checkIn.isSuccessful, isTrue);
        expect(response.checkIn.commitment, 'Tetap konsisten');
        expect(response.checkIn.relapseTrigger, isEmpty);

        expect(response.statistics.currentStreak, 5);
        expect(response.statistics.longestStreak, 12);
        expect(response.statistics.totalCheckins, 24);
        expect(response.statistics.totalAttempts, 28);
        expect(response.statistics.successRate, 0.86);
        expect(response.statistics.streakCalendar, hasLength(3));
        expect(response.statistics.relapseCalendar, hasLength(2));
        expect(response.statistics.weeklyProgress?.delta, 1);
        expect(response.statistics.monthlyProgress?.delta, 4);
        expect(response.statistics.moodTrend, hasLength(1));

        expect(response.relapseSolution?.title, 'Tips Mengelola Stres');
        expect(response.relapseSolution?.summary, contains('pernapasan'));

        // CheckInResult adapter parses the exact same response without crashes
        final checkInResult = CheckInResult.fromJson(json);
        expect(checkInResult.id, 'checkin_123');
        expect(checkInResult.isActive, isTrue);
        expect(checkInResult.checkIn?.mood, 'tenang');
        expect(checkInResult.statistics?.currentStreak, 5);
        expect(checkInResult.relapseSolution?.title, 'Tips Mengelola Stres');

        final serialized = response.toJson();
        expect(serialized['check_in']['id'], 'checkin_123');
        expect(serialized['statistics']['current_streak'], 5);
        expect(serialized['relapse_solution']['title'], 'Tips Mengelola Stres');
      },
    );

    test(
      'RoutineCheckInResponseData deserializes with null relapse_solution',
      () {
        final json = {
          'check_in': {
            'id': 'checkin_456',
            'user_id': 'user_456',
            'check_in_date': '2026-05-11',
            'check_in_day_name': 'Minggu',
            'mood': 'bahagia',
            'is_successful': true,
            'commitment': 'Fokus hari ini',
            'relapse_trigger': <String>[],
            'created_at': '2026-05-11T10:00:00Z',
          },
          'statistics': {
            'current_streak': 6,
            'longest_streak': 12,
            'total_checkins': 25,
            'streak_calendar': ['2026-05-11'],
          },
          'relapse_solution': null,
        };

        final response = RoutineCheckInResponseData.fromJson(json);
        expect(response.checkIn.id, 'checkin_456');
        expect(response.relapseSolution, isNull);

        final checkInResult = CheckInResult.fromJson(json);
        expect(checkInResult.id, 'checkin_456');
        expect(checkInResult.relapseSolution, isNull);
      },
    );

    test(
      'RoutineRelapseResponseData deserializes relapse event and recovery solution',
      () {
        final json = {
          'relapse': {
            'id': 'relapse_789',
            'user_id': 'user_123',
            'relapse_date': '2026-05-10',
            'relapse_day_name': 'Sabtu',
            'check_in_id': null,
            'mood': 'cemas',
            'commitment': 'Bangkit kembali dan belajar dari pemicu ini',
            'relapse_trigger': ['kelelahan', 'stres'],
            'created_at': '2026-05-10T22:30:00Z',
          },
          'statistics': {
            'current_streak': 0,
            'longest_streak': 12,
            'total_checkins': 24,
            'streak_calendar': ['2026-05-08', '2026-05-09'],
            'relapse_count': 4,
          },
          'relapse_solution': {
            'title': 'Rencana Pemulihan Segera',
            'analysis':
                'Kelelahan ekstrem menurunkan kendali inhibisi kognitif.',
            'summary': 'Segera istirahat, hindari gadget di tempat tidur.',
            'generated_at': '2026-05-10T22:30:05Z',
          },
        };

        final response = RoutineRelapseResponseData.fromJson(json);

        expect(response.relapse.id, 'relapse_789');
        expect(response.relapse.userId, 'user_123');
        expect(response.relapse.mood, 'cemas');
        expect(
          response.relapse.relapseTrigger,
          containsAll(['kelelahan', 'stres']),
        );
        expect(response.statistics.currentStreak, 0);
        expect(response.statistics.relapseCount, 4);
        expect(response.relapseSolution?.title, 'Rencana Pemulihan Segera');

        final checkInResult = CheckInResult.fromJson(json);
        expect(checkInResult.id, 'relapse_789');
        expect(checkInResult.isActive, isFalse);
        expect(checkInResult.relapse?.mood, 'cemas');

        final serialized = response.toJson();
        expect(serialized['relapse']['id'], 'relapse_789');
        expect(serialized['statistics']['relapse_count'], 4);
      },
    );

    test(
      'UserProfileData deserializes user profile fields matching contract',
      () {
        final json = {
          'id': 'usr_recover_99',
          'email': 'recovery.warrior@example.com',
          'nickname': 'SemangatBaru',
          'recovery_reason': 'Membangun kembali fokus dan kedamaian batin',
          'daily_checkin_time': '20:30',
          'porn_free_goal': 90,
          'onboarding_completed': true,
        };

        final profile = UserProfileData.fromJson(json);

        expect(profile.id, 'usr_recover_99');
        expect(profile.email, 'recovery.warrior@example.com');
        expect(profile.nickname, 'SemangatBaru');
        expect(
          profile.recoveryReason,
          'Membangun kembali fokus dan kedamaian batin',
        );
        expect(profile.dailyCheckinTime, '20:30');
        expect(profile.pornFreeGoal, 90);
        expect(profile.onboardingCompleted, isTrue);

        final serialized = profile.toJson();
        expect(serialized['id'], 'usr_recover_99');
        expect(serialized['nickname'], 'SemangatBaru');
        expect(serialized['porn_free_goal'], 90);
      },
    );

    test(
      'CommunityPostData deserializes community post with author and like details',
      () {
        final json = {
          'id': 'post_888',
          'title': 'Pencapaian 30 Hari',
          'content':
              'Satu hari demi satu hari. Tetap tenang ketika dorongan datang.',
          'category': 'tips',
          'comment_count': 8,
          'like_count': 25,
          'created_at': '2026-05-10T14:00:00Z',
          'author': {
            'id': 'author_123',
            'nickname': 'PejuangTangguh',
            'current_streak': 30,
            'is_author': false,
          },
          'is_liked': true,
        };

        final post = CommunityPostData.fromJson(json);

        expect(post.id, 'post_888');
        expect(post.title, 'Pencapaian 30 Hari');
        expect(post.content, contains('Satu hari demi satu hari'));
        expect(post.category, 'tips');
        expect(post.commentCount, 8);
        expect(post.likeCount, 25);
        expect(post.username, 'PejuangTangguh');
        expect(post.userStreak, 30);
        expect(post.isLiked, isTrue);
      },
    );

    test(
      'Statistics.copyWith preserves existing analytics and progress data',
      () {
        final initialStats = Statistics(
          currentStreak: 3,
          longestStreak: 10,
          totalCheckins: 15,
          totalAttempts: 18,
          successRate: 0.83,
          streakCalendar: ['2026-05-08', '2026-05-09', '2026-05-10'],
          weeklyProgress: WeeklyProgress(
            windowDays: 7,
            currentSuccessfulCheckins: 5,
            previousSuccessfulCheckins: 4,
            delta: 1,
            deltaRate: 0.25,
          ),
        );

        final updated = initialStats.copyWith(
          currentStreak: 4,
          longestStreak: 10,
          totalCheckins: 16,
        );

        expect(updated.currentStreak, 4);
        expect(updated.longestStreak, 10);
        expect(updated.totalCheckins, 16);
        expect(updated.totalAttempts, 18);
        expect(updated.successRate, 0.83);
        expect(updated.weeklyProgress?.delta, 1);
      },
    );

    test(
      'RoutineCheckInData and CheckInResult defensively parse integer booleans and dynamic maps',
      () {
        final dynamicMap = <dynamic, dynamic>{
          'check_in': <dynamic, dynamic>{
            'id': 'checkin_dyn_1',
            'user_id': 'user_dyn_1',
            'check_in_date': '2026-05-10',
            'check_in_day_name': 'Sabtu',
            'mood': 'tenang',
            'is_successful': 1,
            'commitment': 'Bertahan',
          },
          'statistics': <dynamic, dynamic>{
            'current_streak': 1,
            'longest_streak': 1,
            'total_checkins': 1,
            'streak_calendar': <dynamic>['2026-05-10'],
          },
        };

        final parsed = RoutineCheckInResponseData.fromJson(
          Map<String, dynamic>.from(dynamicMap),
        );
        expect(parsed.checkIn.isSuccessful, isTrue);
        expect(parsed.statistics.currentStreak, 1);

        final checkInResult = CheckInResult.fromJson(
          Map<String, dynamic>.from(dynamicMap),
        );
        expect(checkInResult.isActive, isTrue);
      },
    );

    test(
      'CommunityLikeData deserializes OpenAPI payload and handles dynamic types',
      () {
        final json = {'liked_count': 14, 'is_liked': true};

        final data = CommunityLikeData.fromJson(json);
        expect(data.likedCount, 14);
        expect(data.isLiked, isTrue);
        expect(data.toJson(), {'liked_count': 14, 'is_liked': true});

        final copy = data.copyWith(likedCount: 15, isLiked: false);
        expect(copy.likedCount, 15);
        expect(copy.isLiked, isFalse);

        final dynamicJson = <dynamic, dynamic>{
          'liked_count': '7',
          'is_liked': 1,
        };
        final parsedDynamic = CommunityLikeData.fromJson(
          Map<String, dynamic>.from(dynamicJson),
        );
        expect(parsedDynamic.likedCount, 7);
        expect(parsedDynamic.isLiked, isTrue);
      },
    );
  });
}
