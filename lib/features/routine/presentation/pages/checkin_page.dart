import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/core/ui/app_toast.dart';
import 'package:recova/features/routine/presentation/cubit/checkin_cubit.dart';
import 'package:recova/features/routine/presentation/widgets/mood_selector.dart';
import 'package:recova/features/routine/presentation/widgets/routine_template_chips.dart';
import 'package:recova/features/routine/presentation/widgets/streak_badge.dart';
import 'package:recova/pages/main_scaffold.dart';

class CheckInPage extends StatefulWidget {
  final int streakDays;
  final bool hasCheckedInToday;

  const CheckInPage({
    super.key,
    required this.streakDays,
    this.hasCheckedInToday = false,
  });

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _journalController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  String? _selectedMood;

  final List<String> _templates = [
    'Aku merasa sangat tersiksa hari ini',
    'Hari ini cukup menantang',
    'Aku merasa lebih baik dari kemarin',
    'Aku bangga bisa bertahan hari ini',
  ];

  @override
  void initState() {
    super.initState();
    _journalController = TextEditingController();
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
    _journalController.dispose();
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
    final recoveryTheme = context.recoveryTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<CheckinCubit, CheckinState>(
        builder: (context, state) {
          final isAlreadyCheckedIn =
              widget.hasCheckedInToday || state is CheckinSuccess;
          final displayStreak =
              (state is CheckinSuccess)
                  ? widget.streakDays + 1
                  : widget.streakDays;

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
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          _getTodayDate(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 38),
                      ],
                    ),
                    const SizedBox(height: 20),
                    StreakBadge(
                      title: 'Daily Check-In',
                      streakDays: displayStreak,
                      subtitle: 'Hari Tanpa Pornografi',
                      quote:
                          '"Saya akan berkomitmen untuk bebas dari pornografi, dan saya bersungguh-sungguh."',
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
                    Text(
                      'Pilih yang paling menggambarkan perasaanmu saat ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    MoodSelector(
                      selectedMood: _selectedMood,
                      isEnabled: !isAlreadyCheckedIn,
                      onMoodSelected: (mood) {
                        setState(() {
                          _selectedMood = mood;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Jurnal Harian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ceritakan apa yang kamu rasakan hari ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _journalController,
                        enabled: !isAlreadyCheckedIn,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              isAlreadyCheckedIn
                                  ? 'Kamu sudah melakukan check-in hari ini.'
                                  : 'Tuliskan pengalaman atau perasaanmu hari ini...',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.6,
                            ),
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
                      templates: _templates,
                      isEnabled: !isAlreadyCheckedIn,
                      controller: _journalController,
                    ),
                    const SizedBox(height: 24),
                    if (isAlreadyCheckedIn)
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        decoration: BoxDecoration(
                          color: recoveryTheme.accentSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: recoveryTheme.cleanStatusColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Check-in Selesai',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kamu sudah melakukan check-in hari ini. Lanjutkan perjuanganmu besok!',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
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
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BlocBuilder<CheckinCubit, CheckinState>(
          builder: (context, state) {
            final isAlreadyCheckedIn =
                widget.hasCheckedInToday || state is CheckinSuccess;
            final isCheckingIn = state is CheckinLoading;

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (isCheckingIn || isAlreadyCheckedIn)
                        ? null
                        : () async {
                          if (_selectedMood == null) {
                            AppToast.showWarning(
                              context,
                              'Pilih mood kamu terlebih dahulu',
                            );
                            return;
                          }

                          await context.read<CheckinCubit>().performCheckIn(
                            content:
                                _journalController.text.isNotEmpty
                                    ? _journalController.text
                                    : 'Check-in harian',
                            mood: _selectedMood!,
                            commitment:
                                'Saya akan berkomitmen untuk bebas dari pornografi, dan saya bersungguh-sungguh.',
                          );
                          if (!context.mounted) return;

                          final resultState =
                              context.read<CheckinCubit>().state;

                          if (resultState is CheckinSuccess) {
                            _journalController.clear();
                            AppToast.showSuccess(
                              context,
                              'Berhasil check-in. Terima kasih!',
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScaffold(),
                              ),
                            );
                          } else if (resultState is CheckinFailure) {
                            AppToast.showError(context, resultState.error);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScaffold(),
                              ),
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  disabledBackgroundColor: colorScheme.primary.withOpacity(
                    0.38,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:
                    isCheckingIn
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
                            if (!isAlreadyCheckedIn)
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            if (!isAlreadyCheckedIn) const SizedBox(width: 8),
                            Text(
                              isAlreadyCheckedIn
                                  ? 'Sudah Check-in'
                                  : 'Check In Sekarang',
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
