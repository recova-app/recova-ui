import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/features/routine/presentation/cubit/relapse_cubit.dart';
import 'package:recova/features/routine/presentation/widgets/mood_selector.dart';
import 'package:recova/features/routine/presentation/widgets/relapse_trigger_selector.dart';
import 'package:recova/features/routine/presentation/widgets/routine_template_chips.dart';
import 'package:recova/features/routine/presentation/widgets/streak_badge.dart';
import 'package:recova/pages/main_scaffold.dart';

class RelapsePage extends StatefulWidget {
  final int streakDays;

  const RelapsePage({super.key, required this.streakDays});

  @override
  State<RelapsePage> createState() => _RelapsePageState();
}

class _RelapsePageState extends State<RelapsePage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _commitmentController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  String? _selectedMood;
  final Set<String> _selectedTriggers = {};

  final List<String> _commitmentTemplates = [
    'Saya akan lebih kuat dari kemarin',
    'Saya tidak akan menyerah',
    'Setiap kejatuhan adalah pelajaran',
    'Saya berkomitmen untuk bangkit kembali',
  ];

  @override
  void initState() {
    super.initState();
    _commitmentController = TextEditingController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _commitmentController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _getTodayDate() {
    final now = DateTime.now();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<RelapseCubit, RelapseState>(
        builder: (context, state) {
          final isSubmitted = state is RelapseSuccess;

          return SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        Text(
                          _getTodayDate(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B98A0),
                          ),
                        ),
                        const SizedBox(width: 38),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const StreakBadge(
                      title: 'Tidak Apa-Apa',
                      subtitle: 'Jatuh bukan berarti gagal',
                      mascotAssetPath: 'assets/images/maskots/learning-5.png',
                      quote:
                          '"Yang penting adalah kamu jujur pada dirimu sendiri dan bangkit kembali."',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bagaimana Mood Kamu?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih yang paling menggambarkan perasaanmu saat ini',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B98A0)),
                    ),
                    const SizedBox(height: 14),
                    MoodSelector(
                      selectedMood: _selectedMood,
                      isEnabled: !isSubmitted,
                      activeColor: const Color(0xFF136E4D),
                      onMoodSelected: (mood) {
                        setState(() {
                          _selectedMood = mood;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Apa Pemicu Relapse?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih satu atau lebih pemicu yang kamu rasakan',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B98A0)),
                    ),
                    const SizedBox(height: 14),
                    RelapseTriggerSelector(
                      selectedTriggers: _selectedTriggers,
                      isEnabled: !isSubmitted,
                      onTriggerToggled: (trigger) {
                        setState(() {
                          if (_selectedTriggers.contains(trigger)) {
                            _selectedTriggers.remove(trigger);
                          } else {
                            _selectedTriggers.add(trigger);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pesan Komitmen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tulis komitmen kamu untuk bangkit kembali',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B98A0)),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _commitmentController,
                        enabled: !isSubmitted,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        decoration: InputDecoration(
                          hintText:
                              isSubmitted
                                  ? 'Relapse sudah dicatat. Tetap semangat!'
                                  : 'Tuliskan komitmen kamu untuk tetap berjuang...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB0B8C1),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.all(18),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RoutineTemplateChips(
                      templates: _commitmentTemplates,
                      isEnabled: !isSubmitted,
                      controller: _commitmentController,
                    ),
                    const SizedBox(height: 24),
                    if (isSubmitted)
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF136E4D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Relapse Dicatat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Terima kasih atas kejujuranmu. Kamu bisa bangkit kembali!',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BlocBuilder<RelapseCubit, RelapseState>(
          builder: (context, state) {
            final isSubmitted = state is RelapseSuccess;
            final isLoading = state is RelapseLoading;

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (isLoading || isSubmitted)
                        ? null
                        : () async {
                          if (_selectedMood == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pilih mood kamu terlebih dahulu',
                                ),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          if (_selectedTriggers.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pilih minimal satu pemicu relapse',
                                ),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          if (_commitmentController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tulis pesan komitmen kamu'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          await context.read<RelapseCubit>().submitRelapse(
                            mood: _selectedMood!,
                            relapseTriggers: _selectedTriggers.toList(),
                            commitment: _commitmentController.text,
                          );
                          if (!context.mounted) return;

                          final resultState =
                              context.read<RelapseCubit>().state;

                          if (resultState is RelapseSuccess) {
                            _commitmentController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Relapse dicatat. Tetap semangat!',
                                ),
                                backgroundColor: Color(0xFF136E4D),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScaffold(),
                              ),
                            );
                          } else if (resultState is RelapseFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(resultState.error),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136E4D),
                  disabledBackgroundColor: const Color(0xFFB2DFDB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isSubmitted)
                              const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            if (!isSubmitted) const SizedBox(width: 8),
                            Text(
                              isSubmitted
                                  ? 'Relapse Sudah Dicatat'
                                  : 'Akui & Reset Progress',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
              ),
            );
          },
        ),
      ),
    );
  }
}
