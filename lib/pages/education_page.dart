import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/education_cubit.dart';
import 'package:recova/models/education_model.dart';
import 'package:recova/pages/coach_page.dart';
import 'package:recova/pages/article_page.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  @override
  void initState() {
    super.initState();
    context.read<EducationCubit>().fetchEducationContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<EducationCubit>().fetchEducationContents(),
          color: const Color(0xFF38B768),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header (sama persis dengan HomePage) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    const Icon(Icons.notifications_none_rounded, color: Color(0xFF6B7280)),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Quote Card (mirip StreakCard style) ──
                Container(
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 24, 120, 24),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quote Hari Ini',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '"Perubahan kecil dalam kebiasaan sehari-hari bisa membawa perubahan besar dalam hidupmu."',
                              style: TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '— James Clear',
                              style: TextStyle(
                                color: Color(0xFFA7F3D0),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -15,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(18),
                          ),
                          child: Image.asset(
                            'assets/images/maskots/quote.png',
                            width: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // ── Fitur Edukasi section ──
                const Text(
                  'Fitur Edukasi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CoachPage(),
                      ),
                    );
                  },
                  child: const _EducationFeatureCard(
                    title: 'Smart Personal AI Coach',
                    subtitle:
                        'Dapatkan Insight untuk Keluhan atau Pertanyaanmu',
                    assetPath: 'assets/images/maskots/coach.png',
                    bg: Color(0xFFEAF9F1),
                    arrow: true,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArticlePage(
                          title: 'Pahami Dampak Pornografi',
                          category: 'Dampak pornografi',
                        ),
                      ),
                    );
                  },
                  child: const _EducationFeatureCard(
                    title: 'Pahami Dampak Pornografi',
                    subtitle:
                        'Pelajari dampak pornografi pada otak dan kehidupanmu',
                    assetPath: 'assets/images/maskots/dampak.png',
                    bg: Color(0xFFEAF9F1),
                    arrow: true,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArticlePage(
                          title: 'Tips & Strategi Pemulihan',
                          category: 'Pemulihan',
                        ),
                      ),
                    );
                  },
                  child: const _EducationFeatureCard(
                    title: 'Tips & Strategi Pemulihan',
                    subtitle:
                        'Tips praktis mengatasi urge dan membangun kebiasaan baru',
                    assetPath: 'assets/images/maskots/pemulihan.png',
                    bg: Color(0xFFEAF9F1),
                    arrow: true,
                  ),
                ),
                const SizedBox(height: 26),

                // ── Video Library Section ──
                const Text(
                  'Video Edukasi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),

                BlocBuilder<EducationCubit, EducationState>(
                  builder: (context, state) {
                    if (state is EducationLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF38B768),
                          ),
                        ),
                      );
                    }
                    if (state is EducationLoadFailure) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                state.error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<EducationCubit>()
                                    .fetchEducationContents(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF38B768),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state is EducationLoadSuccess) {
                      if (state.contents.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                          decoration: BoxDecoration(
                            color: const Color(0x1A000000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Belum ada konten edukasi.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Konten edukasi akan segera tersedia. Stay tuned!',
                                style: TextStyle(
                                    fontSize: 10, color: Color(0xFF7A7A7A)),
                              ),
                            ],
                          ),
                        );
                      }
                      // Kelompokkan konten berdasarkan kategori
                      final groupedContent = <String, List<EducationContent>>{};
                      for (var content in state.contents) {
                        if (content.category == 'Dampak Pornografi' || content.category == 'Pemulihan') {
                          continue;
                        }
                        (groupedContent[content.category] ??= []).add(content);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupedContent.entries.map((entry) {
                          return _buildVideoCategory(entry.key, entry.value);
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 26),

                // ── Today Insight (sama style dengan HomePage) ──
                const Text(
                  'Insight Edukasi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF9F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tahukah kamu? Otak manusia memiliki kemampuan neuroplastisitas — artinya kamu bisa melatih ulang otakmu untuk melepaskan kebiasaan lama dan membangun jalur saraf baru yang lebih sehat.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Insight ini berdasarkan riset neurosains tentang pemulihan dari kecanduan',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFF7A7A7A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCategory(String title, List<EducationContent> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _VideoCard(content: items[index]);
            },
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

// ── Video Card (redesigned to match app style) ──
class _VideoCard extends StatelessWidget {
  final EducationContent content;

  const _VideoCard({required this.content});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Could not launch the URL
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchURL(content.url),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF9F1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                content.thumbnailUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 110,
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF38B768),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_circle_outline,
                          color: Color(0xFF8B98A0), size: 36),
                    ),
                  );
                },
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Text(
                content.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF111111),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feature Card (sama persis dengan _FeatureCard di HomePage) ──
class _EducationFeatureCard extends StatelessWidget {
  const _EducationFeatureCard({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.bg,
    this.arrow = false,
    this.titleColor = const Color(0xFF111111),
    this.subtitleColor = const Color(0xFF454545),
  });
  final String title;
  final String subtitle;
  final String assetPath;
  final Color bg;
  final bool arrow;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        // Layer 1: Background dan Konten Utama
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 31 * 0.42,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 18 * 0.42,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (arrow) Icon(Icons.chevron_right, color: titleColor),
            ],
          ),
        ),

        // Layer 2: Gambar yang diposisikan (Positioned)
        Positioned(
          right: -10,
          bottom: -15,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(12),
            ),
            child: Image.asset(
              assetPath,
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class ArticleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final String readTime;

  const ArticleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.readTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, // Menggunakan subtitle dari parameter
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(tag, // Menggunakan tag dari parameter
                      style: const TextStyle(
                          fontSize: 12, color: Colors.teal)),
                  backgroundColor: Colors.teal.shade50,
                ),
                Text(readTime, // Menggunakan readTime dari parameter
                    style: const TextStyle(
                        fontSize: 12, color: Colors.teal)),
              ],
            )
          ],
        ),
      ),
    );
  }
}