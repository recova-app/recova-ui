import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                    const Text(
                      'Pilih yang paling menggambarkan perasaanmu saat ini',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B98A0)),
                    ),
                    const SizedBox(height: 14),
                    MoodSelector(
                      selectedMood: _selectedMood,
                      isEnabled: !isAlreadyCheckedIn,
                      activeColor: const Color(0xFF38B768),
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
                    const Text(
                      'Ceritakan apa yang kamu rasakan hari ini',
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
                        controller: _journalController,
                        enabled: !isAlreadyCheckedIn,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        decoration: InputDecoration(
                          hintText:
                              isAlreadyCheckedIn
                                  ? 'Kamu sudah melakukan check-in hari ini.'
                                  : 'Tuliskan pengalaman atau perasaanmu hari ini...',
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
                      templates: _templates,
                      isEnabled: !isAlreadyCheckedIn,
                      controller: _journalController,
                    ),
                    const SizedBox(height: 24),
                    if (isAlreadyCheckedIn)
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF9F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF38B768),
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
                                    'Check-in Selesai',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF136E4D),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Kamu sudah melakukan check-in hari ini. Lanjutkan perjuanganmu besok!',
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Berhasil check-in. Terima kasih!',
                                ),
                                backgroundColor: Color(0xFF38B768),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScaffold(),
                              ),
                            );
                          } else if (resultState is CheckinFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(resultState.error),
                                backgroundColor: const Color(0xFF38B768),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScaffold(),
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
