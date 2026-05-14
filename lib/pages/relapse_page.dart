import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/relapse_cubit.dart';
import 'package:recova/pages/main_scaffold.dart';

class RelapsePage extends StatefulWidget {
  final int streakDays;

  const RelapsePage({
    super.key,
    required this.streakDays,
  });

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

  final List<_MoodOption> _moods = const [
    _MoodOption(emoji: '😢', label: 'Sangat Buruk', value: 'sangat_buruk'),
    _MoodOption(emoji: '😟', label: 'Buruk', value: 'buruk'),
    _MoodOption(emoji: '😐', label: 'Biasa', value: 'biasa'),
    _MoodOption(emoji: '😊', label: 'Baik', value: 'baik'),
    _MoodOption(emoji: '🤩', label: 'Sangat Baik', value: 'sangat_baik'),
  ];

  final List<_TriggerOption> _triggers = const [
    _TriggerOption(icon: Icons.hourglass_empty_rounded, label: 'Boredom', value: 'Boredom'),
    _TriggerOption(icon: Icons.psychology_rounded, label: 'Stress', value: 'Stress'),
    _TriggerOption(icon: Icons.phone_android_rounded, label: 'Media', value: 'Media'),
    _TriggerOption(icon: Icons.mood_rounded, label: 'Mood', value: 'Mood'),
    _TriggerOption(icon: Icons.location_on_rounded, label: 'Location', value: 'Location'),
  ];

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
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                    // ─── TOP BAR ───
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

                    // ─── RELAPSE HEADER CARD ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF136E4D),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Image.asset('assets/images/maskots/learning-5.png', width: 200, height: 200,),
                          const SizedBox(height: 8),
                          const Text(
                            'Tidak Apa-Apa',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Jatuh bukan berarti gagal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '"Yang penting adalah kamu jujur pada dirimu sendiri dan bangkit kembali."',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFEAF9F1),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── MOOD SECTION ───
                    const Text(
                      'Bagaimana Mood Kamu?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih yang paling menggambarkan perasaanmu saat ini',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B98A0)),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF9F1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            _moods.map((mood) {
                              final isSelected = _selectedMood == mood.value;
                              return GestureDetector(
                                onTap:
                                    isSubmitted
                                        ? null
                                        : () {
                                          setState(() {
                                            _selectedMood = mood.value;
                                          });
                                        },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? const Color(0xFF136E4D)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              const BoxShadow(
                                                color: Color(0x33DC2626),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                            : [],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedScale(
                                        scale: isSelected ? 1.25 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: Text(
                                          mood.emoji,
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        mood.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── RELAPSE TRIGGERS SECTION ───
                    const Text(
                      'Apa Pemicu Relapse Kamu?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih satu atau lebih pemicu yang kamu rasakan',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B98A0)),
                    ),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          _triggers.map((trigger) {
                            final isSelected = _selectedTriggers.contains(
                              trigger.value,
                            );
                            return GestureDetector(
                              onTap:
                                  isSubmitted
                                      ? null
                                      : () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedTriggers.remove(
                                              trigger.value,
                                            );
                                          } else {
                                            _selectedTriggers.add(
                                              trigger.value,
                                            );
                                          }
                                        });
                                      },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFF136E4D)
                                          : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF136E4D)
                                            : const Color(0xFFE5E7EB),
                                    width: 1.5,
                                  ),
                                  boxShadow:
                                      isSelected
                                          ? [
                                            const BoxShadow(
                                              color: Color(0x33DC2626),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                          : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      trigger.icon,
                                      size: 18,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : const Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      trigger.label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : const Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ─── COMMITMENT MESSAGE SECTION ───
                    const Text(
                      'Pesan Komitmen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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

                    // ─── COMMITMENT TEMPLATE CHIPS ───
                    _TemplateChips(
                      templates: _commitmentTemplates,
                      isEnabled: !isSubmitted,
                      controller: _commitmentController,
                    ),

                    const SizedBox(height: 24),

                    // ─── SUCCESS INFO CARD ───
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
                          // Validate mood
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

                          // Validate triggers
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

                          // Validate commitment
                          if (_commitmentController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tulis pesan komitmen kamu',
                                ),
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
                                backgroundColor: Color(0xFF136E4D),
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
                  disabledBackgroundColor: const Color(0xFFEAF9F1),
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
                            Text(
                              isSubmitted
                                  ? 'Relapse Sudah Dicatat'
                                  : 'Relapse',
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

// ─── Mood Option Model ───
class _MoodOption {
  final String emoji;
  final String label;
  final String value;

  const _MoodOption({
    required this.emoji,
    required this.label,
    required this.value,
  });
}

// ─── Trigger Option Model ───
class _TriggerOption {
  final IconData icon;
  final String label;
  final String value;

  const _TriggerOption({
    required this.icon,
    required this.label,
    required this.value,
  });
}

// ─── Template Chips ───
class _TemplateChips extends StatefulWidget {
  final List<String> templates;
  final bool isEnabled;
  final TextEditingController controller;

  const _TemplateChips({
    required this.templates,
    required this.isEnabled,
    required this.controller,
  });

  @override
  State<_TemplateChips> createState() => _TemplateChipsState();
}

class _TemplateChipsState extends State<_TemplateChips> {
  String? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          widget.templates.map((text) {
            final selected = _selectedTemplate == text;
            return ChoiceChip(
              label: Text(text),
              selected: selected,
              onSelected:
                  !widget.isEnabled
                      ? null
                      : (bool isSelected) {
                        setState(() {
                          _selectedTemplate = isSelected ? text : null;
                          if (isSelected) widget.controller.text = text;
                        });
                      },
              selectedColor: const Color(0xFF136E4D),
              backgroundColor: const Color(0xFFF3F4F6),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF374151),
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      selected
                          ? const Color(0xFF136E4D)
                          : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            );
          }).toList(),
    );
  }
}
