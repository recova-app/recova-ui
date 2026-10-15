import 'package:flutter/material.dart';
import '../widgets/onboarding_button.dart';

class SetVictoryLetterPage extends StatefulWidget {
  const SetVictoryLetterPage({super.key});

  @override
  State<SetVictoryLetterPage> createState() => _SetVictoryLetterPageState();
}

class _SetVictoryLetterPageState extends State<SetVictoryLetterPage> {
  int selectedGoal = 1; // Default to "1 day (recommended)"
  final List<Map<String, dynamic>> goals = const [
    {'text': '12 hours', 'value': 0.5, 'recommended': false},
    {'text': '1 day (recommended)', 'value': 1, 'recommended': true},
    {'text': '3 days', 'value': 3, 'recommended': false},
  ];

  void _setGoal() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamed(context, '/homepage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Image.asset(
                        'assets/images/maskots/set-victory-letter.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Porn-free victory goal',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Let\'s start with a small goal\nto build momentum.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              Column(
                children:
                    goals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final goal = entry.value;
                      final isSelected = selectedGoal == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGoal = index;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? colorScheme.primary.withOpacity(0.12)
                                      : colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withOpacity(0.4),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                goal['text'] as String,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                  color:
                                      isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),
              OnboardingButton(text: 'Set porn-free goal', onPressed: _setGoal),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
