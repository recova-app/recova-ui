import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recova/pages/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/education_cubit.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/bloc/community_cubit.dart';
import 'package:recova/bloc/stats_cubit.dart';
import 'package:recova/core/network/api_client.dart';
import 'package:recova/features/routine/data/datasources/routine_remote_data_source.dart';
import 'package:recova/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/features/routine/presentation/cubit/checkin_cubit.dart';
import 'package:recova/features/routine/presentation/cubit/relapse_cubit.dart';
import 'package:recova/services/auth_service.dart';
import 'package:recova/pages/login_page.dart';
import 'package:recova/pages/main_scaffold.dart';
import 'package:recova/pages/onboarding/learning_2.dart';
import 'package:recova/pages/onboarding/learning_3.dart';
import 'package:recova/pages/onboarding/learning_4.dart';
import 'package:recova/pages/onboarding/learning_5.dart';
import 'package:recova/pages/onboarding/questions/question_1.dart';
import 'package:recova/pages/onboarding/questions/question_2.dart';
import 'package:recova/pages/onboarding/questions/question_3.dart';
import 'package:recova/pages/onboarding/questions/question_4.dart';
import 'package:recova/pages/onboarding/questions/question_5.dart';
import 'package:recova/pages/onboarding/questions/question_6.dart';
import 'package:recova/pages/onboarding/questions/question_7.dart';
import 'package:recova/pages/onboarding/questions/question_8.dart';
import 'package:recova/pages/onboarding/questions/question_9.dart';
import 'package:recova/pages/onboarding/set_name.dart';
import 'package:recova/pages/onboarding/know_your_why.dart';
import 'package:recova/pages/onboarding/set_porn_free_day.dart';
import 'package:recova/pages/onboarding/set_checkin_time.dart';
import 'package:recova/pages/onboarding/preparing_test_result.dart';
import 'package:recova/pages/onboarding/results.dart';
import 'package:recova/pages/onboarding/benefits.dart';
import 'package:recova/pages/onboarding/why-checkin.dart';
import 'package:recova/pages/register_page.dart';
import 'package:recova/pages/onboarding/learning_1.dart';
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

      runApp(
        RepositoryProvider<RoutineRepository>.value(
          value: routineRepository,
          child: MultiBlocProvider(
            providers: [
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
                create: (context) => CommunityCubit(),
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
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
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
        '/preparing-test-result': (context) => const PreparingTestResultPage(),
        '/results': (context) => const ResultsPage(),
        '/benefits': (context) => const BenefitsPage(),
      },
    );
  }
}
