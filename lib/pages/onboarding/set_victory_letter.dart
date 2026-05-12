import 'package:flutter/material.dart';

class SetVictoryLetterPage extends StatefulWidget {
  const SetVictoryLetterPage({super.key});

  @override
  State<SetVictoryLetterPage> createState() => _SetVictoryLetterPageState();
}

class _SetVictoryLetterPageState extends State<SetVictoryLetterPage> {
  int selectedGoal = 1; // Default to "1 day (recommended)"
  final List<Map<String, dynamic>> goals = [
    {'text': '12 hours', 'value': 0.5, 'recommended': false},
    {'text': '1 day (recommended)', 'value': 1, 'recommended': true},
    {'text': '3 days', 'value': 3, 'recommended': false},
  ];

  void _setGoal() {
    // Navigate to next page or handle goal setting
    Navigator.pushNamed(context, '/next-onboarding-step');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Status Bar Space
              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
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

                    // Title
                    const Text(
                      'Porn-free victory goal',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Main instruction
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Let\'s start with a small goal\nto build momentum.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),

              // Goal Options
              Column(
                children: goals.asMap().entries.map((entry) {
                  final index = entry.key;
                  final goal = entry.value;
                  final isSelected = selectedGoal == index;
                  final isRecommended = goal['recommended'] as bool;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGoal = index;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4CAF50).withOpacity(0.1)
                              : Colors.transparent,
                          border: Border(
                            top: index == 0
                                ? const BorderSide(color: Color(0xFFE0E0E0))
                                : BorderSide.none,
                            bottom: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            goal['text'] as String,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1B5E20)
                                  : (isRecommended
                                      ? const Color(0xFF777777)
                                      : const Color(0xFF1A1A1A)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Bottom Buttons
              Column(
                children: [
                  // Set Goal Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _setGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Set porn-free goal',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
