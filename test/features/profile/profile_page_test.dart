import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/home/presentation/cubit/home_cubit.dart';
import 'package:recova/features/profile/presentation/pages/profile_page.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;

  final testUser = User(
    id: '1',
    email: 'test@example.com',
    nickname: 'TestUser',
    dailyCheckinTime: '21:00',
    pornFreeGoal: 30,
    recoveryReason: 'Ingin hidup lebih baik',
  );

  final testStats = Statistics(
    currentStreak: 5,
    longestStreak: 10,
    totalCheckins: 20,
    streakCalendar: const ['2026-10-15'],
  );

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<HomeCubit>.value(value: mockHomeCubit, child: child),
    );
  }

  group('ProfilePage View Tests', () {
    testWidgets('renders loading indicator when state is HomeLoading', (
      tester,
    ) async {
      when(() => mockHomeCubit.state).thenReturn(HomeLoading());

      await tester.pumpWidget(buildTestableWidget(const ProfilePage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message and retry button when HomeLoadFailure', (
      tester,
    ) async {
      when(
        () => mockHomeCubit.state,
      ).thenReturn(const HomeLoadFailure('Koneksi terputus'));

      await tester.pumpWidget(buildTestableWidget(const ProfilePage()));

      expect(
        find.text('Gagal memuat profil: Koneksi terputus'),
        findsOneWidget,
      );
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      verify(() => mockHomeCubit.fetchHomeData()).called(1);
    });

    testWidgets('renders full profile settings dashboard on HomeLoadSuccess', (
      tester,
    ) async {
      when(() => mockHomeCubit.state).thenReturn(
        HomeLoadSuccess(
          user: testUser,
          statistics: testStats,
          relapseCalendar: const [],
        ),
      );

      await tester.pumpWidget(buildTestableWidget(const ProfilePage()));

      expect(find.text('Profil Kamu'), findsOneWidget);
      expect(find.text('Atur Ulang Check-In Time'), findsOneWidget);
      expect(find.text('Atur Ulang Goals Kamu'), findsOneWidget);
      expect(find.text('Tulis Ulang Manifesto'), findsOneWidget);
      expect(find.text('Reminder Time'), findsOneWidget);
    });
  });
}
