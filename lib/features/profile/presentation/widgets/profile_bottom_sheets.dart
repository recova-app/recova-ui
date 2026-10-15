import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/services/api_service.dart';
import 'profile_sheet_scaffold.dart';

/// Modal bottom sheet helpers for modifying user recovery settings and preferences.
class ProfileBottomSheets {
  static const List<String> times = [
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

  static const List<Map<String, dynamic>> goals = [
    {'text': '7 hari', 'value': 7},
    {'text': '14 hari', 'value': 14},
    {'text': '30 hari', 'value': 30},
    {'text': '69 hari', 'value': 69},
    {'text': '120 hari', 'value': 120},
    {'text': '365 hari', 'value': 365},
    {'text': '1000 hari', 'value': 1000},
  ];

  static String format24h(String t) {
    final parts = t.split(' ');
    int hour = int.parse(parts[0]);
    final ampm = parts[1];
    if (ampm == 'pm' && hour < 12) hour += 12;
    if (ampm == 'am' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  static int timeIndexFrom24h(String? time24) {
    if (time24 == null || time24.isEmpty) return 3;
    for (int i = 0; i < times.length; i++) {
      if (format24h(times[i]) == time24) return i;
    }
    return 3;
  }

  static int goalIndexFromDays(int? days) {
    if (days == null) return 1;
    for (int i = 0; i < goals.length; i++) {
      if ((goals[i]['value'] as num) == days) return i;
    }
    return 1;
  }

  static void showCheckinTimeSheet(BuildContext ctx, String? currentTime) {
    final colorScheme = Theme.of(ctx).colorScheme;
    final initialIdx = timeIndexFrom24h(currentTime);
    int selected = initialIdx;
    final controller = FixedExtentScrollController(initialItem: initialIdx);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => ProfileSheetScaffold(
            title: 'Atur Ulang Check-In Time',
            subtitle: 'Kapan waktu daily check-in kamu?',
            asset: 'assets/images/maskots/set-checkin-time.png',
            buttonLabel: 'Simpan Waktu Check-In',
            bodyBuilder:
                (setS) => SizedBox(
                  height: 180,
                  child: ListWheelScrollView.useDelegate(
                    controller: controller,
                    itemExtent: 52,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (i) {
                      selected = i;
                      setS(() {});
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (_, i) {
                        if (i < 0 || i >= times.length) return null;
                        final isSel = selected == i;
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border:
                                isSel
                                    ? Border(
                                      top: BorderSide(
                                        color: colorScheme.outlineVariant,
                                      ),
                                      bottom: BorderSide(
                                        color: colorScheme.outlineVariant,
                                      ),
                                    )
                                    : null,
                          ),
                          child: Text(
                            times[i],
                            style: TextStyle(
                              fontSize: isSel ? 28 : 20,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                              color:
                                  isSel
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                      childCount: times.length,
                    ),
                  ),
                ),
            onSave: () async {
              await ApiService.updateUserSettings(
                dailyCheckinTime: format24h(times[selected]),
              );
              if (ctx.mounted) ctx.read<HomeCubit>().fetchHomeData();
            },
          ),
    );
  }

  static void showGoalsSheet(BuildContext ctx, int? currentGoalDays) {
    final colorScheme = Theme.of(ctx).colorScheme;
    final recoveryTheme = ctx.recoveryTheme;
    int selected = goalIndexFromDays(currentGoalDays);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => ProfileSheetScaffold(
            title: 'Atur Ulang Goals',
            subtitle: 'Mulai dengan target kecil untuk membangun momentum.',
            asset: 'assets/images/maskots/set-porn-free-day.png',
            buttonLabel: 'Tetapkan Target',
            bodyBuilder:
                (setS) => Column(
                  children:
                      goals.asMap().entries.map((e) {
                        final i = e.key;
                        final g = e.value;
                        final isSel = selected == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () {
                              selected = i;
                              setS(() {});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSel
                                        ? recoveryTheme.accentSurface
                                        : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSel
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
                                  width: isSel ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  g['text'] as String,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        isSel
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                    color:
                                        isSel
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
            onSave: () async {
              final goalValue = goals[selected]['value'];
              final days =
                  goalValue is int ? goalValue : (goalValue as double).toInt();
              await ApiService.updateUserSettings(pornFreeGoal: days);
              if (ctx.mounted) ctx.read<HomeCubit>().fetchHomeData();
            },
          ),
    );
  }

  static void showManifestoSheet(BuildContext ctx, String? current) {
    final colorScheme = Theme.of(ctx).colorScheme;
    final tc = TextEditingController(text: current ?? '');

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetCtx) => ProfileSheetScaffold(
            title: 'Tulis Ulang Manifesto',
            subtitle: 'Tulis surat kemenangan untuk dirimu.',
            asset: 'assets/images/maskots/set-victory-letter.png',
            buttonLabel: 'Simpan Manifesto',
            bodyBuilder:
                (setS) => TextField(
                  controller: tc,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis manifesto kamu di sini…',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            onSave: () async {
              await ApiService.updateUserSettings(
                recoveryReason: tc.text.trim(),
              );
              if (ctx.mounted) ctx.read<HomeCubit>().fetchHomeData();
            },
          ),
    );
  }
}
