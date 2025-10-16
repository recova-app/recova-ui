import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/pages/login_page.dart';
import 'package:recova/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoadSuccess) {
              final user = state.user;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pengaturan",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage("assets/images/logo.png"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile Section
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: const AssetImage("assets/images/logo.png"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.nickname,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Manage Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Manage",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),

                  buildSettingsItem(Icons.check_box, "Edit Check-In Time",
                      color: Colors.green),
                  buildSettingsItem(Icons.track_changes, "Atur Ulang Goals Kamu",
                      color: Colors.red),
                  buildSettingsItem(Icons.edit, "Edit Manifesto",
                      color: Colors.orange),
                  const SizedBox(height: 20),

                  // Notification Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Notifications",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),

                  buildSettingsItem(Icons.alarm, "Set Your Reminder Time",
                      color: Colors.redAccent),
                  const SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final AuthService authService = AuthService();
                        await authService.logout();

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                            (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Footer
                  Column(
                    children: const [
                      Text(
                        "Version 1.0",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Made with ❤ by Recova teams",
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ],
              );
            } else if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoadFailure) {
              return Center(child: Text('Gagal memuat profil: ${state.error}'));
            }
            return const SizedBox.shrink(); // Fallback
          },
        ),
      ),
    );
  }

  Widget buildSettingsItem(IconData icon, String title, {Color color = Colors.black}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 26),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
      ),
    );
  }
}