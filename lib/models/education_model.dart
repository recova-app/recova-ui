class EducationContent {
  final String id;
  final String title;
  final String description;
  final String url;
  final String thumbnailUrl;
  final String category;
  final String type;
  final String? publishedAt;

  EducationContent({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
    required this.category,
    required this.type,
    this.publishedAt,
  });

  factory EducationContent.fromJson(Map<String, dynamic> json) {
    return EducationContent(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      // Memberikan nilai default jika kategori null atau kosong
      category: (json['category'] != null && json['category'].isNotEmpty)
          ? json['category']
          : 'General',
      type: json['type'] ?? 'video',
      publishedAt: json['published_at'],
    );
  }
}