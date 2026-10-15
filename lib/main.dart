import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recova/pages/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/education_cubit.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/bloc/community_cubit.dart';
import 'package:recova/bloc/stats_cubit.dart';
import 'package:recova/core/network/api_client.dart';
import 'package:recova/core/theme/theme_cubit.dart';
import 'package:recova/features/routine/data/datasources/routine_remote_data_source.dart';
import 'package:recova/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/features/routine/presentation/cubit/checkin_cubit.dart';
import 'package:recova/features/routine/presentation/cubit/relapse_cubit.dart';
import 'package:recova/features/community/data/datasources/community_remote_data_source.dart';
import 'package:recova/features/community/data/repositories/community_repository_impl.dart';
import 'package:recova/features/community/domain/repositories/community_repository.dart';
import 'package:recova/services/auth_service.dart';
import 'package:recova/features/auth/presentation/pages/login_page.dart';
import 'package:recova/features/auth/presentation/pages/register_page.dart';
import 'package:recova/features/onboarding/presentation/pages/learning_1_page.dart';
import 'package:recova/features/onboarding/presentation/pages/learning_2_page.dart';
import 'package:recova/features/onboarding/presentation/pages/learning_3_page.dart';
import 'package:recova/features/onboarding/presentation/pages/learning_4_page.dart';
import 'package:recova/features/onboarding/presentation/pages/learning_5_page.dart';
import 'package:recova/features/onboarding/presentation/pages/set_name_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_1_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_2_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_3_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_4_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_5_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_6_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_7_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_8_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_9_page.dart';
import 'package:recova/features/onboarding/presentation/pages/know_your_why_page.dart';
import 'package:recova/features/onboarding/presentation/pages/set_porn_free_day_page.dart';
import 'package:recova/features/onboarding/presentation/pages/set_checkin_time_page.dart';
import 'package:recova/features/onboarding/presentation/pages/why_checkin_page.dart';
import 'package:recova/features/onboarding/presentation/pages/preparing_test_result_page.dart';
import 'package:recova/features/onboarding/presentation/pages/results_page.dart';
import 'package:recova/features/onboarding/presentation/pages/benefits_page.dart';
import 'package:recova/pages/main_scaffold.dart';
import 'package:recova/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:recova/services/notification_service.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Inisialisasi notification service sebelum runApp
      await NotificationService.initialize();

      // Load environment variables if present
      try {
        await dotenv.load(fileName: ".env");
      } catch (_) {
        // Gracefully continue when environment file is omitted
      }

      // Customize Flutter error UI
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Material(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'Terjadi error pada aplikasi',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.exceptionAsString(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      };

      final apiClient = ApiClient(tokenProvider: AuthService().getToken);
      final routineRemoteDataSource = RoutineRemoteDataSourceImpl(
        apiClient: apiClient,
      );
      final routineRepository = RoutineRepositoryImpl(
        remoteDataSource: routineRemoteDataSource,
      );
      final communityRemoteDataSource = CommunityRemoteDataSourceImpl(
        apiClient: apiClient,
      );
      final communityRepository = CommunityRepositoryImpl(
        remoteDataSource: communityRemoteDataSource,
      );

      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<RoutineRepository>.value(
              value: routineRepository,
            ),
            RepositoryProvider<CommunityRepository>.value(
              value: communityRepository,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>(
                create: (context) => ThemeCubit()..loadTheme(),
              ),
              BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
              BlocProvider<CheckinCubit>(
                create:
                    (context) => CheckinCubit(
                      homeCubit: context.read<HomeCubit>(),
                      routineRepository: routineRepository,
                    ),
              ),
              BlocProvider<RelapseCubit>(
                create:
                    (context) => RelapseCubit(
                      homeCubit: context.read<HomeCubit>(),
                      routineRepository: routineRepository,
                    ),
              ),
              BlocProvider<CommunityCubit>(
                create:
                    (context) => CommunityCubit(
                      communityRepository: communityRepository,
                    ),
              ),
              BlocProvider<EducationCubit>(
                create: (context) => EducationCubit(),
              ),
              BlocProvider<StatsCubit>(create: (context) => StatsCubit()),
            ],
            child: const MyApp(),
          ),
        ),
      );
    },
    (error, stack) {
      // Handle uncaught errors
      FlutterError.presentError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
      print('Uncaught zone error: $error');
      print(stack);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (context) => const SplashPage(),
            '/homepage': (context) => const MainScaffold(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/learning-1': (context) => const Learning1(),
            '/learning-2': (context) => const Learning2(),
            '/learning-3': (context) => const Learning3(),
            '/learning-4': (context) => const Learning4(),
            '/learning-5': (context) => const Learning5(),
            '/set-name': (context) => const SetNamePage(),
            '/question-1': (context) => const Question1(),
            '/question-2': (context) => const Question2(),
            '/question-3': (context) => const Question3(),
            '/question-4': (context) => const Question4(),
            '/question-5': (context) => const Question5(),
            '/question-6': (context) => const Question6(),
            '/question-7': (context) => const Question7(),
            '/question-8': (context) => const Question8(),
            '/question-9': (context) => const Question9(),
            '/know-your-why': (context) => const KnowYourWhyPage(),
            '/set-porn-free-day': (context) => const SetPornFreeDayPage(),
            '/set-checkin-time': (context) => const SetCheckinTimePage(),
            '/why-checkin': (context) => const WhyCheckinPage(),
            '/preparing-test-result':
                (context) => const PreparingTestResultPage(),
            '/results': (context) => const ResultsPage(),
            '/benefits': (context) => const BenefitsPage(),
          },
        );
      },
    );
  }
}
