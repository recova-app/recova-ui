import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recova/controllers/education/education_controller.dart';
import 'package:recova/models/education_model.dart';
import 'package:recova/pages/coach_page.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late final EducationController _educationController;

  @override
  void initState() {
    super.initState();
    _educationController = Get.find<EducationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _educationController.fetchEducationContents();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget ini hanya mengembalikan kontennya, tanpa Scaffold.
    // Bungkus dengan SafeArea agar tidak tertutup oleh system UI / bottom nav.
    // Padding atas ditambahkan untuk ruang di bawah status bar.
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _educationController.fetchEducationContents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Column( // Column dipertahankan karena strukturnya sudah benar
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Edukasi",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage("assets/images/logo.png"),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quote Slider
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "“Perubahan kecil dalam kebiasaan sehari-hari bisa membawa perubahan besar dalam hidupmu.”\n- James Clear -",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // AI Coach
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CoachPage()),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  // Path diperbaiki agar sesuai dengan struktur proyek
                  backgroundImage: AssetImage("assets/images/home/icon_coach.png"),
                ),
                title: Text("Smart Personal AI Coach"),
                subtitle: Text(
                    "Dapatkan Insight untuk Keluhan atau Pertanyaanmu"),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Video Library Section
          const Text(
            "Video Library",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Obx(() {
            final state = _educationController.state.value;
            if (state is EducationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is EducationLoadFailure) {
              return Center(child: Text('Gagal memuat konten: ${state.error}'));
            }
            if (state is EducationLoadSuccess) {
              if (state.contents.isEmpty) {
                return const Center(child: Text('Belum ada konten edukasi.'));
              }
              final groupedContent = <String, List<EducationContent>>{};
              for (var content in state.contents) {
                (groupedContent[content.category] ??= []).add(content);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groupedContent.entries.map((entry) {
                  return buildVideoCategory(entry.key, entry.value);
                }).toList(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
          ),
        ),
      ),
    );
  }

  Widget buildVideoCategory(String title, List<EducationContent> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 150, // Placeholder height for the horizontal list container. Individual cards compute their own height responsively.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = MediaQuery.of(context).size.width * 0.45;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: cardWidth,
                      child: VideoCard(content: items[index], width: cardWidth),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class VideoCard extends StatelessWidget {
  final EducationContent content;
  final double width;

  const VideoCard({
    super.key,
    required this.content,
    required this.width,
  });

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Could not launch the URL
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute height responsively from width (maintain aspect ratio)
    final double height = width * 0.75; // 4:3-ish aspect
    final double imageHeight = height * 0.66;

    return GestureDetector(
      onTap: () => _launchURL(content.url),
      child: Container(
        margin: const EdgeInsets.only(right: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  content.thumbnailUrl,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                // Placeholder dan error handling untuk gambar
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: imageHeight,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: imageHeight,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            // Judul
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: height - imageHeight - 16, // remaining space minus paddings
                  child: Text(
                    content.title,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
          ),
        ),
      ),
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