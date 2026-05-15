import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/pages/login_page.dart';
import 'package:recova/services/auth_service.dart';
import 'package:recova/services/api_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // ── Time list shared by check-in & reminder pickers ──
  static const List<String> _times = [
    '7 pm','8 pm','9 pm','10 pm','11 pm','12 pm',
    '1 am','2 am','3 am','4 am','5 am','6 am',
    '7 am','8 am','9 am','10 am','11 am','12 am',
    '1 pm','2 pm','3 pm','4 pm','5 pm','6 pm',
  ];

  static String _format24h(String t) {
    final parts = t.split(' ');
    int hour = int.parse(parts[0]);
    final ampm = parts[1];
    if (ampm == 'pm' && hour < 12) hour += 12;
    if (ampm == 'am' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  /// Resolve the wheel index from a 24h time string like "09:00".
  static int _timeIndexFrom24h(String? time24) {
    if (time24 == null || time24.isEmpty) return 3; // default 10 pm
    for (int i = 0; i < _times.length; i++) {
      if (_format24h(_times[i]) == time24) return i;
    }
    return 3;
  }

  /// Resolve the goal index from an integer number of days.
  static int _goalIndexFromDays(int? days) {
    if (days == null) return 1; // default 1 hari
    for (int i = 0; i < _goals.length; i++) {
      if ((_goals[i]['value'] as num) == days) return i;
    }
    return 1;
  }

  // ── Goal options ──
  static const List<Map<String, dynamic>> _goals = [
    {'text': '7 hari', 'value': 7},
    {'text': '14 hari', 'value': 14},
    {'text': '30 hari', 'value': 30},
    {'text': '69 hari', 'value': 69},
    {'text': '120 hari', 'value': 120},
    {'text': '365 hari', 'value': 365},
    {'text': '1000 hari', 'value': 1000},
  ];

  // ════════════════════════════════════════════════════════
  //  BOTTOM SHEETS
  // ════════════════════════════════════════════════════════

  void _showCheckinTimeSheet(BuildContext ctx, String? currentTime) {
    final initialIdx = _timeIndexFrom24h(currentTime);
    int selected = initialIdx;
    final controller = FixedExtentScrollController(initialItem: initialIdx);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetScaffold(
        title: 'Edit Check-In Time',
        subtitle: 'Kapan waktu daily check-in kamu?',
        asset: 'assets/images/maskots/set-checkin-time.png',
        buttonLabel: 'Simpan Waktu Check-In',
        bodyBuilder: (setS) => SizedBox(
          height: 180,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 52,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) { selected = i; setS(() {}); },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (_, i) {
                if (i < 0 || i >= _times.length) return null;
                final isSel = selected == i;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: isSel ? const Border(
                      top: BorderSide(color: Color(0xFFDDDDDD)),
                      bottom: BorderSide(color: Color(0xFFDDDDDD)),
                    ) : null,
                  ),
                  child: Text(
                    _times[i],
                    style: TextStyle(
                      fontSize: isSel ? 28 : 20,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? const Color(0xFF1A1A1A) : const Color(0xFF999999),
                    ),
                  ),
                );
              },
              childCount: _times.length,
            ),
          ),
        ),
        onSave: () async {
          await ApiService.updateUserSettings(dailyCheckinTime: _format24h(_times[selected]));
          if (ctx.mounted) ctx.read<HomeCubit>().fetchHomeData();
        },
      ),
    );
  }

  void _showGoalsSheet(BuildContext ctx, int? currentGoalDays) {
    int selected = _goalIndexFromDays(currentGoalDays);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetScaffold(
        title: 'Atur Ulang Goals',
        subtitle: 'Mulai dengan target kecil untuk membangun momentum.',
        asset: 'assets/images/maskots/set-porn-free-day.png',
        buttonLabel: 'Tetapkan Target',
        bodyBuilder: (setS) => Column(
          children: _goals.asMap().entries.map((e) {
            final i = e.key;
            final g = e.value;
            final isSel = selected == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () { selected = i; setS(() {}); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF4CAF50).withOpacity(0.10) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      g['text'] as String,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? const Color(0xFF1B5E20) : const Color(0xFF777777),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        onSave: () async {
          final goalValue = _goals[selected]['value'];
          final days = goalValue is int ? goalValue : (goalValue as double).toInt();
          await ApiService.updateUserSettings(pornFreeGoal: days);
          if (ctx.mounted) ctx.read<HomeCubit>().fetchHomeData();
        },
      ),
    );
  }

  void _showManifestoSheet(BuildContext ctx, String? current) {
    final tc = TextEditingController(text: current ?? '');
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _SheetScaffold(
        title: 'Edit Manifesto',
        subtitle: 'Tulis surat kemenangan untuk dirimu.',
        asset: 'assets/images/maskots/set-victory-letter.png',
        buttonLabel: 'Simpan Manifesto',
        bodyBuilder: (setS) => TextField(
          controller: tc,
          maxLines: 5,
          style: const TextStyle(fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            hintText: 'Tulis manifesto kamu di sini…',
            hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
        ),
        onSave: () async {
          await ApiService.updateUserSettings(recoveryReason: tc.text.trim());
          if (ctx.mounted) ctx.read<HomeCubit>().fetchHomeData();
        },
      ),
    );
  }

  void _showReminderSheet(BuildContext ctx) {
    int selected = 3;
    final controller = FixedExtentScrollController(initialItem: selected);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetScaffold(
        title: 'Set Reminder Time',
        subtitle: 'Kapan kamu ingin diingatkan setiap hari?',
        asset: 'assets/images/maskots/why-checkin.png',
        buttonLabel: 'Simpan Pengingat',
        bodyBuilder: (setS) => SizedBox(
          height: 180,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 52,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) { selected = i; setS(() {}); },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (_, i) {
                if (i < 0 || i >= _times.length) return null;
                final isSel = selected == i;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: isSel ? const Border(
                      top: BorderSide(color: Color(0xFFDDDDDD)),
                      bottom: BorderSide(color: Color(0xFFDDDDDD)),
                    ) : null,
                  ),
                  child: Text(
                    _times[i],
                    style: TextStyle(
                      fontSize: isSel ? 28 : 20,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? const Color(0xFF1A1A1A) : const Color(0xFF999999),
                    ),
                  ),
                );
              },
              childCount: _times.length,
            ),
          ),
        ),
        onSave: () async {
          await ApiService.updateUserSettings(dailyCheckinTime: _format24h(_times[selected]));
          if (ctx.mounted) ctx.read<HomeCubit>().fetchHomeData();
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeLoadFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat profil: ${state.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().fetchHomeData(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final successState = state as HomeLoadSuccess;
        final user = successState.user;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset('assets/images/logo.png', width: 64, height: 64),
                    ),
                    const Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Page Title ──
                const Text('Pengaturan', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Kelola akun dan preferensi kamu', style: TextStyle(fontSize: 14, color: Color(0xFF8B98A0))),
                const SizedBox(height: 18),

                // ── Profile Card ──
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF136E4D),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 24, 140, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Profil Kamu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(user.nickname, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(user.email, style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 12, height: 1.3), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 16, top: 0, bottom: 0,
                            child: Center(
                              child: Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0F5A3D),
                                  border: Border.all(color: const Color(0xFF38B768), width: 3),
                                ),
                                child: ClipOval(child: Image.asset('assets/images/maskots/profile.png', fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alasan Pemulihan', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(user.recoveryReason ?? 'Belum diatur', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ── Manage Section ──
                const Text('Manage', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),

                _ProfileSettingCard(
                  icon: Icons.access_time_filled_rounded,
                  title: 'Edit Check-In Time',
                  subtitle: 'Atur jadwal check-in harian kamu',
                  assetPath: 'assets/images/maskots/set-checkin-time.png',
                  onTap: () => _showCheckinTimeSheet(context, user.dailyCheckinTime),
                ),
                const SizedBox(height: 12),
                _ProfileSettingCard(
                  icon: Icons.track_changes_rounded,
                  title: 'Atur Ulang Goals Kamu',
                  subtitle: 'Sesuaikan target pemulihan kamu',
                  assetPath: 'assets/images/maskots/set-porn-free-day.png',
                  onTap: () => _showGoalsSheet(context, user.pornFreeGoal),
                ),
                const SizedBox(height: 12),
                _ProfileSettingCard(
                  icon: Icons.auto_stories_rounded,
                  title: 'Edit Manifesto',
                  subtitle: 'Perbarui surat kemenangan kamu',
                  assetPath: 'assets/images/maskots/set-victory-letter.png',
                  onTap: () => _showManifestoSheet(context, user.recoveryReason),
                ),

                const SizedBox(height: 26),

                // ── Notifications Section ──
                const Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),

                _ProfileSettingCard(
                  icon: Icons.notifications_active_rounded,
                  title: 'Set Your Reminder Time',
                  subtitle: 'Atur pengingat harian kamu',
                  assetPath: 'assets/images/maskots/why-checkin.png',
                  onTap: () => _showReminderSheet(context),
                ),

                const SizedBox(height: 26),

                // ── Logout Button ──
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final AuthService authService = AuthService();
                        await authService.logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                            SizedBox(width: 8),
                            Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Text('Version 1.0  •  Made with ❤ by Recova teams', style: TextStyle(fontSize: 10, color: Color(0xFF7A7A7A)), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════
//  Reusable bottom-sheet scaffold
// ════════════════════════════════════════════════════════

class _SheetScaffold extends StatefulWidget {
  const _SheetScaffold({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.buttonLabel,
    required this.bodyBuilder,
    required this.onSave,
  });

  final String title;
  final String subtitle;
  final String asset;
  final String buttonLabel;
  final Widget Function(StateSetter setS) bodyBuilder;
  final Future<void> Function() onSave;

  @override
  State<_SheetScaffold> createState() => _SheetScaffoldState();
}

class _SheetScaffoldState extends State<_SheetScaffold> {
  bool _saving = false;

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    try {
      await widget.onSave();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Berhasil disimpan!'),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (ctx, setS) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              // Mascot
              Image.asset(widget.asset, width: 120, height: 120, fit: BoxFit.contain),
              const SizedBox(height: 16),
              // Title
              Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 6),
              Text(widget.subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF777777))),
              const SizedBox(height: 24),
              // Body
              widget.bodyBuilder(setS),
              const SizedBox(height: 24),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    disabledBackgroundColor: const Color(0xFF1B5E20).withOpacity(0.5),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(widget.buttonLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  Setting card (unchanged design)
// ════════════════════════════════════════════════════════

class _ProfileSettingCard extends StatelessWidget {
  const _ProfileSettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.iconBgColor = const Color(0xFFEAF9F1),
    this.iconColor = const Color(0xFF38B768),
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String assetPath;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111111))),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 7.5, color: Color(0xFF454545))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -10, bottom: -15,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
              child: Image.asset(assetPath, width: 70, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
