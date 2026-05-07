import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recova/controllers/checkin/checkin_controller.dart';

class CheckInPage extends StatefulWidget {
  final int streakDays;
  final bool hasCheckedInToday;

  const CheckInPage({super.key, required this.streakDays, this.hasCheckedInToday = false});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  late final TextEditingController _journalController;
  late final CheckinController _checkinController;
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
    _checkinController = Get.find<CheckinController>();
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final state = _checkinController.state.value;
        final isAlreadyCheckedIn = widget.hasCheckedInToday || state is CheckinSuccess;
        final displayStreak = (state is CheckinSuccess) ? widget.streakDays + 1 : widget.streakDays;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      key: ValueKey<int>(displayStreak),
                      '$displayStreak',
                      style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Color(0xFF003E53)),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text('Hari Tanpa Pornografi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),

                  const Text(
                    '“Saya akan berkomitmen untuk bebas dari pornografi, dan saya bersungguh-sungguh.”',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: Colors.black87),
                  ),

                  const SizedBox(height: 28),

                  // INPUT JOURNAL
                  TextField(
                    controller: _journalController,
                    enabled: !isAlreadyCheckedIn,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: isAlreadyCheckedIn
                          ? 'Kamu sudah check-in hari ini. Sampai jumpa besok!'
                          : 'Ceritakan apa yang kamu rasakan sekarang atau pilih salah satu template journal di bawah...',
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TEMPLATE CHIPS
                  _TemplateChips(templates: _templates, isEnabled: !isAlreadyCheckedIn, controller: _journalController),

                  const SizedBox(height: 32),

                  // TANGGAL
                  Text(_getTodayDate(), style: const TextStyle(color: Colors.black54, fontSize: 13)),

                  const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: SizedBox(
          width: double.infinity,
          child: Obx(() {
            final state = _checkinController.state.value;
            final isAlreadyCheckedIn = widget.hasCheckedInToday || state is CheckinSuccess;
            final isCheckingIn = state is CheckinLoading;

            return ElevatedButton(
              onPressed: (isCheckingIn || isAlreadyCheckedIn)
                  ? null
                  : () async {
                      await _checkinController.performCheckIn(journal: _journalController.text);
                      if (!context.mounted) return;

                      final resultState = _checkinController.state.value;

                      if (resultState is CheckinSuccess) {
                        _journalController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil check-in. Terima kasih!')));
                      } else if (resultState is CheckinFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultState.error)));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2EC4B6),
                disabledBackgroundColor: const Color(0xFFB2DFDB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: isCheckingIn
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                  : Text(isAlreadyCheckedIn ? 'Sudah Check-in' : 'Check In', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            );
          }),
        ),
      ),
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
      'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _TemplateChips extends StatefulWidget {
  final List<String> templates;
  final bool isEnabled;
  final TextEditingController controller;

  const _TemplateChips({required this.templates, required this.isEnabled, required this.controller});

  @override
  State<_TemplateChips> createState() => _TemplateChipsState();
}

class _TemplateChipsState extends State<_TemplateChips> {
  String? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.templates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = widget.templates[index];
          final selected = _selectedTemplate == text;
          return ChoiceChip(
            label: Text(text),
            selected: selected,
            onSelected: !widget.isEnabled
                ? null
                : (bool isSelected) {
                    setState(() {
                      _selectedTemplate = isSelected ? text : null;
                      if (isSelected) widget.controller.text = text;
                    });
                  },
            selectedColor: const Color(0xFF2EC4B6),
            backgroundColor: const Color(0xFFF3F3F3),
            labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 13),
            pressElevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }
}
