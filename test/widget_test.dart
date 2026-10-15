import 'package:flutter_test/flutter_test.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/models/post_model.dart';

void main() {
  group('Core model serialization smoke test', () {
    test('User.fromJson deserializes valid payload correctly', () {
      final userJson = {
        'id': 'usr-101',
        'email': 'recovery.user@example.com',
        'nickname': 'ResilientWarrior',
        'recovery_reason': 'Mental clarity and emotional stability',
        'daily_checkin_time': '21:00',
        'porn_free_goal': 90,
        'onboarding_completed': true,
      };

      final user = User.fromJson(userJson);

      expect(user.id, 'usr-101');
      expect(user.email, 'recovery.user@example.com');
      expect(user.nickname, 'ResilientWarrior');
      expect(user.recoveryReason, 'Mental clarity and emotional stability');
      expect(user.dailyCheckinTime, '21:00');
      expect(user.pornFreeGoal, 90);
      expect(user.onboardingCompleted, isTrue);

      final serialized = user.toJson();
      expect(serialized['id'], 'usr-101');
      expect(serialized['email'], 'recovery.user@example.com');
      expect(serialized['onboarding_completed'], isTrue);
    });

    test('Post.fromJson deserializes backend format with author metadata', () {
      final postJson = {
        'id': 'post-501',
        'title': 'Day 30 Milestone Reached',
        'content':
            'Taking it one day at a time. The urges pass if you stay present.',
        'category': 'saran',
        'comment_count': 12,
        'like_count': 34,
        'created_at': '2026-10-15T10:00:00.000Z',
        'user_id': 'usr-101',
        'author': {'nickname': 'ResilientWarrior', 'current_streak': 30},
        'isLiked': true,
      };

      final post = Post.fromJson(postJson);

      expect(post.id, 'post-501');
      expect(post.title, 'Day 30 Milestone Reached');
      expect(post.content, contains('one day at a time'));
      expect(post.category, 'saran');
      expect(post.commentCount, 12);
      expect(post.likeCount, 34);
      expect(post.userId, 'usr-101');
      expect(post.username, 'ResilientWarrior');
      expect(post.userStreak, 30);
      expect(post.isLiked, isTrue);
    });
  });
}
