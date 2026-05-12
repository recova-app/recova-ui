import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';
import '../../services/onboarding_state.dart';

class SetCheckinTimePage extends StatefulWidget {
  const SetCheckinTimePage({super.key});

  @override
  State<SetCheckinTimePage> createState() => _SetCheckinTimePageState();
}

class _SetCheckinTimePageState extends State<SetCheckinTimePage> {
  int selectedTime = 3; // Default to "10 pm"
  final List<String> times = [
    '7 pm',
    '8 pm',
    '9 pm',
    '10 pm',
    '11 pm',
    '12 pm',
    '1 am',
    '2 am',
    '3 am',
    '4 am',
    '5 am',
    '6 am',
    '7 am',
    '8 am',
    '9 am',
    '10 am',
    '11 am',
    '12 am',
    '1 pm',
    '2 pm',
    '3 pm',
    '4 pm',
    '5 pm',
    '6 pm',
  ];

  String _formatTime(String timeStr) {
    final parts = timeStr.split(' ');
    int hour = int.parse(parts[0]);
    final ampm = parts[1];
    if (ampm == 'pm' && hour < 12) hour += 12;
    if (ampm == 'am' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  void _setCheckinTime() {
    final formattedTime = _formatTime(times[selectedTime]);
    OnboardingState().dailyCheckinTime = formattedTime;
    Navigator.pushNamed(context, '/preparing-test-result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.large ),

                        Container(
                      width: 200,
                      height: 200,
                      child: Image.asset(
                        'assets/images/maskots/set-checkin-time.png',
                        width: 220,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.large),

                    const SizedBox(height: AppSpacing.large),

                    // Main instruction
                    Text(
                      'Kapan Waktu yang kamu mau untuk daily check in setiap harinya?',
                      textAlign: TextAlign.center,
                      style: AppText.h2.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.large),

                    // Time Picker
                    Expanded(
                      child: Container(
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 60,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedTime = index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= times.length) return null;

                              final time = times[index];
                              final isSelected = selectedTime == index;

                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: isSelected ? const Border(
                                      top: BorderSide(color: Color(0xFFDDDDDD)),
                                      bottom: BorderSide(color: Color(0xFFDDDDDD)),
                                    ) : null,
                                  ),
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: isSelected ? 32 : 24,
                                      fontFamily: 'Inter',
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF777777),
                                    ),
                                  ),
                              );
                            },
                            childCount: times.length,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

                const SizedBox(height: AppSpacing.large ),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _setCheckinTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Atur Waktu Check-In',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }
}
