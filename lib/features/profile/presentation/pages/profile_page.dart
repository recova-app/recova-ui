import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/pages/login_page.dart';
import 'package:recova/pages/notification_page.dart';
import 'package:recova/services/auth_service.dart';
import '../widgets/profile_bottom_sheets.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_notification_toggle_card.dart';
import '../widgets/profile_setting_card.dart';

/// User profile and settings dashboard page.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat profil: ${state.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Page Title
                Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola akun dan preferensi kamu',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),

                // Profile Card
                ProfileHeaderCard(user: user),

                const SizedBox(height: 26),

                // Manage Section
                Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),

                ProfileSettingCard(
                  icon: Icons.access_time_filled_rounded,
                  title: 'Atur Ulang Check-In Time',
                  subtitle: 'Atur jadwal check-in harian kamu',
                  assetPath: 'assets/images/maskots/set-checkin-time.png',
                  onTap:
                      () => ProfileBottomSheets.showCheckinTimeSheet(
                        context,
                        user.dailyCheckinTime,
                      ),
                ),
                const SizedBox(height: 12),
                ProfileSettingCard(
                  icon: Icons.track_changes_rounded,
                  title: 'Atur Ulang Goals Kamu',
                  subtitle: 'Sesuaikan target pemulihan kamu',
                  assetPath: 'assets/images/maskots/set-porn-free-day.png',
                  onTap:
                      () => ProfileBottomSheets.showGoalsSheet(
                        context,
                        user.pornFreeGoal,
                      ),
                ),
                const SizedBox(height: 12),
                ProfileSettingCard(
                  icon: Icons.auto_stories_rounded,
                  title: 'Tulis Ulang Manifesto',
                  subtitle: 'Perbarui surat kemenangan kamu',
                  assetPath: 'assets/images/maskots/set-victory-letter.png',
                  onTap:
                      () => ProfileBottomSheets.showManifestoSheet(
                        context,
                        user.recoveryReason,
                      ),
                ),

                const SizedBox(height: 26),

                // Notifications Section
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),

                ProfileNotificationToggleCard(
                  checkinTime: user.dailyCheckinTime,
                ),

                const SizedBox(height: 26),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final AuthService authService = AuthService();
                        await authService.logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Version 1.0  •  Made with ❤ by Recova teams',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
