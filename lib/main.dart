import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recova/pages/splash_screen.dart';
import 'package:recova/pages/community_hub_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/bloc/community_cubit.dart';
import 'package:recova/bloc/checkin_cubit.dart';
import 'package:recova/bloc/education_cubit.dart';


void main() {
  // Ensure binding is initialized for plugin calls during startup
  WidgetsFlutterBinding.ensureInitialized();

  // Replace the default error widget to show a readable message instead of a blank crash
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // You can customize the UI here. Keep it simple so it won't crash again.
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
              const Text('Terjadi error pada aplikasi', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(details.exceptionAsString(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  };

  // Catch errors that escape the Flutter framework
  runZonedGuarded(() {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
          BlocProvider<CheckinCubit>(create: (context) => CheckinCubit()),
          BlocProvider<CommunityCubit>(create: (context) => CommunityCubit()),
          BlocProvider<EducationCubit>(create: (context) => EducationCubit()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    // Print to console so the error appears in `flutter run -v` and logcat
    // For production use, send this to a crash reporting service.
    FlutterError.presentError(FlutterErrorDetails(exception: error, stack: stack));
    // Also print plain error
    // ignore: avoid_print
    print('Uncaught zone error: $error');
    // ignore: avoid_print
    print(stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      // home: const CommunityHubPage(), // bypass langsung ke CommunityHubPage
      routes: {'/': (context) => const SplashPage()},
    );
  }
}