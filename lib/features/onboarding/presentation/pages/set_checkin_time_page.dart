import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/onboarding_state.dart';
import '../widgets/onboarding_button.dart';

class SetCheckinTimePage extends StatefulWidget {
  const SetCheckinTimePage({super.key});

  @override
  State<SetCheckinTimePage> createState() => _SetCheckinTimePageState();
}

class _SetCheckinTimePageState extends State<SetCheckinTimePage> {
  int selectedTime = 3; // Default to "10 pm"
  late final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: selectedTime);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<String> times = const [
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.large),
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Image.asset(
                        'assets/images/maskots/set-checkin-time.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      'Kapan Waktu yang kamu mau untuk daily check in setiap harinya?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: _scrollController,
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
                                border:
                                    isSelected
                                        ? Border(
                                          top: BorderSide(
                                            color: colorScheme.outline
                                                .withOpacity(0.5),
                                          ),
                                          bottom: BorderSide(
                                            color: colorScheme.outline
                                                .withOpacity(0.5),
                                          ),
                                        )
                                        : null,
                              ),
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: isSelected ? 32 : 24,
                                  fontFamily: 'Inter',
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                          childCount: times.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              OnboardingButton(text: 'Set Waktu', onPressed: _setCheckinTime),
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }
}
