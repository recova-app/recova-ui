import 'package:flutter/material.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/models/education_model.dart';
import 'package:recova/models/journal_model.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});
  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  List<EducationContent> _emergencyVideos = [];
  bool _loadingVideos = false;

  @override
  void initState() {
    super.initState();
    _fetchEmergencyVideos();
  }

  Future<void> _fetchEmergencyVideos() async {
    setState(() => _loadingVideos = true);
    try {
      final all = await ApiService.getEducationContents();
      final filtered = all.where((e) => e.category.toLowerCase() == 'regulasi emosi').toList();
      if (mounted) setState(() { _emergencyVideos = filtered; _loadingVideos = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingVideos = false);
    }
  }

  void _showManifesto() async {
    showDialog(context: context, barrierColor: Colors.black54, builder: (_) => const _ManifestoDialog());
  }

  void _showPhysicalChallenge() {
    showDialog(context: context, barrierColor: Colors.black54, builder: (_) => const _PhysicalChallengeDialog());
  }

  void _showJournal() {
    showDialog(context: context, barrierColor: Colors.black54, builder: (_) => const _JournalDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C7A57),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Emergency", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              const Text("Kamu merasa tergoda? coba salah satu dari hal ini", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 32),
              _buildActionButton(iconAsset: "assets/images/home/icon_review.png", label: "Review Manifesto Yang Kamu Tulis", onTap: _showManifesto),
              const SizedBox(height: 16),
              _buildActionButton(iconAsset: "assets/images/home/icon_exercise.png", label: "Lakukan latihan fisik sederhana", onTap: _showPhysicalChallenge),
              const SizedBox(height: 16),
              _buildActionButton(iconAsset: "assets/images/home/icon_pencil.png", label: "Tulis Apa yang kamu rasakan sekarang", onTap: _showJournal),
              const SizedBox(height: 16),
              const Text("Video Regulasi Emosi", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text("Tonton video untuk membantumu mengelola emosi dan godaan", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              const SizedBox(height: 14),
              _buildVideoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    if (_loadingVideos) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    if (_emergencyVideos.isEmpty) {
      return Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
        child: const Text("Belum ada video regulasi emosi tersedia.", style: TextStyle(color: Colors.white70, fontSize: 13)),
      );
    }
    return SizedBox(
      height: 165,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), itemCount: _emergencyVideos.length,
        itemBuilder: (context, i) => _EmergencyVideoCard(content: _emergencyVideos[i]),
      ),
    );
  }

  Widget _buildActionButton({required String iconAsset, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Image.asset(iconAsset, color: Colors.white, width: 22, height: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
        ]),
      ),
    );
  }
}

// ── Manifesto Dialog ──
class _ManifestoDialog extends StatefulWidget {
  const _ManifestoDialog();
  @override
  State<_ManifestoDialog> createState() => _ManifestoDialogState();
}

class _ManifestoDialogState extends State<_ManifestoDialog> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  User? _user; bool _loading = true; String? _error;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..forward();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final u = await ApiService.getUserMe();
      if (mounted) setState(() { _user = u; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _anim, curve: Curves.easeIn),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
        child: Dialog(
          backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF22A06B).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 12))]),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF136E4D), Color(0xFF22A06B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Stack(clipBehavior: Clip.none, children: [
                  Padding(padding: const EdgeInsets.fromLTRB(22, 24, 100, 22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Manifesto\nKamu', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                    const SizedBox(height: 6),
                    Text('Alasan kamu memulai perjalanan ini', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                  ])),
                  Positioned(right: -5, bottom: -20, child: Image.asset('assets/images/maskots/quote.png', width: 110, fit: BoxFit.contain)),
                ]),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(22, 24, 22, 22), child: _buildBody()),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFFE4573D))));
    if (_error != null) return Column(children: [
      const Icon(Icons.cloud_off_rounded, size: 36, color: Color(0xFFD1D5DB)),
      const SizedBox(height: 8),
      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      const SizedBox(height: 12),
      TextButton.icon(onPressed: () { setState(() { _loading = true; _error = null; }); _fetch(); },
        icon: const Icon(Icons.refresh, size: 18), label: const Text('Coba Lagi'), style: TextButton.styleFrom(foregroundColor: const Color(0xFFE4573D))),
    ]);
    final reason = _user?.recoveryReason;
    if (reason == null || reason.isEmpty) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Column(children: [
        Icon(Icons.edit_note_rounded, color: Color(0xFF22A06B), size: 36), SizedBox(height: 12),
        Text('Kamu belum menulis manifesto', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        SizedBox(height: 4), Text('Tulis alasan pemulihanmu di halaman profil.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))]));
    }
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEAF9F1), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEAF9F1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF22A06B), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.format_quote_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          const Expanded(child: Text('Alasan Pemulihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color:  Color(0xFF22A06B)))),
        ]),
        const SizedBox(height: 14),
        Container(width: double.infinity, padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Text(reason, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151), height: 1.5))),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: Text('— ${_user?.nickname ?? "Kamu"}, ingat alasan ini saat kamu merasa tergoda.',
          style: TextStyle(fontSize: 11, color: const Color(0xFF6B7280).withOpacity(0.8), fontStyle: FontStyle.italic)))]),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ── Physical Challenge Dialog ──
class _PhysicalChallengeDialog extends StatefulWidget {
  const _PhysicalChallengeDialog();
  @override
  State<_PhysicalChallengeDialog> createState() => _PhysicalChallengeDialogState();
}

class _PhysicalChallengeDialogState extends State<_PhysicalChallengeDialog> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  PhysicalChallenge? _challenge; bool _loading = true; String? _error;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..forward();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final content = await ApiService.getDailyContent();
      if (mounted) setState(() { _challenge = content.physicalChallenge; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _anim, curve: Curves.easeIn),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
        child: Dialog(
          backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF136E4D).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 12))]),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF136E4D), Color(0xFF22A06B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Stack(clipBehavior: Clip.none, children: [
                  Padding(padding: const EdgeInsets.fromLTRB(22, 24, 100, 22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Latihan Fisik\nSederhana', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                    const SizedBox(height: 6),
                    Text('Gerakkan tubuhmu sekarang!', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                  ])),
                  Positioned(right: -5, bottom: -20, child: Image.asset('assets/images/maskots/activity.png', width: 110, fit: BoxFit.contain)),
                ]),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(22, 24, 22, 22), child: _buildBody()),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: Column(children: [
      SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF136E4D))),
      SizedBox(height: 12), Text('Memuat tantangan...', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))])));
    if (_error != null) return Column(children: [
      const Icon(Icons.cloud_off_rounded, size: 36, color: Color(0xFFD1D5DB)), const SizedBox(height: 8),
      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))), const SizedBox(height: 12),
      TextButton.icon(onPressed: () { setState(() { _loading = true; _error = null; }); _fetch(); },
        icon: const Icon(Icons.refresh, size: 18), label: const Text('Coba Lagi'), style: TextButton.styleFrom(foregroundColor: const Color(0xFF136E4D)))]);
    if (_challenge == null || _challenge!.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Column(children: [
      Icon(Icons.fitness_center_rounded, color: Color(0xFF38B768), size: 36), SizedBox(height: 12),
      Text('Belum ada tantangan fisik hari ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
      SizedBox(height: 4), Text('Cek lagi nanti ya!', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))]));
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEAF9F1), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD1FAE5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF38B768), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(_challenge!.title.isNotEmpty ? _challenge!.title : 'Latihan Fisik Hari Ini',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
        ]),
        if (_challenge!.description.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Text(_challenge!.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151), height: 1.5))),
        ],
        const SizedBox(height: 14),
        Row(children: [Expanded(child: Text('Latihan fisik membantu mengalihkan energi dan mengurangi dorongan.',
          style: TextStyle(fontSize: 11, color: const Color(0xFF6B7280).withOpacity(0.8), fontStyle: FontStyle.italic)))]),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ── Journal Dialog ──
class _JournalDialog extends StatefulWidget {
  const _JournalDialog();
  @override
  State<_JournalDialog> createState() => _JournalDialogState();
}

class _JournalDialogState extends State<_JournalDialog> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  final _controller = TextEditingController();
  List<Journal> _journals = []; bool _loading = true; bool _submitting = false; String? _error;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..forward();
    _fetchJournals();
  }

  Future<void> _fetchJournals() async {
    try {
      final j = await ApiService.getJournals();
      if (mounted) setState(() { _journals = j; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ApiService.createJournal(content: text);
      _controller.clear();
      setState(() { _loading = true; _submitting = false; });
      _fetchJournals();
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() { _anim.dispose(); _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _anim, curve: Curves.easeIn),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
        child: Dialog(
          backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF5C6BC0).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 12))]),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF136E4D), Color(0xFF22A06B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Stack(clipBehavior: Clip.none, children: [
                  Padding(padding: const EdgeInsets.fromLTRB(22, 24, 100, 22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Tulis\nPerasaanmu', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                    const SizedBox(height: 6),
                    Text('Ekspresikan apa yang kamu rasakan', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                  ])),
                  Positioned(right: -5, bottom: -20, child: Image.asset('assets/images/maskots/write.png', width: 110, fit: BoxFit.contain)),
                ]),
              ),
              Expanded(child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                child: Column(children: [
                  // Input
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
                    child: TextField(
                      controller: _controller, maxLines: 3, decoration: const InputDecoration(
                        hintText: 'Tulis apa yang kamu rasakan sekarang...', hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                        border: InputBorder.none, contentPadding: EdgeInsets.all(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22A06B), foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
                  )),
                  const SizedBox(height: 16),
                  const Align(alignment: Alignment.centerLeft, child: Text('Jurnal Kamu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF374151)))),
                  const SizedBox(height: 8),
                  Expanded(child: _buildJournalList()),
                ]),
              )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildJournalList() {
    if (_loading) return const Center(child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF303F9F)));
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))));
    if (_journals.isEmpty) return const Center(child: Text('Belum ada jurnal. Tulis yang pertama!', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))));
    return ListView.builder(
      physics: const BouncingScrollPhysics(), itemCount: _journals.length,
      itemBuilder: (_, i) {
        final j = _journals[i];
        final date = '${j.createdAt.day}/${j.createdAt.month}/${j.createdAt.year}';
        return Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFEAF9F1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEAF9F1))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(j.content, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4)),
            const SizedBox(height: 6),
            Text(date, style: const TextStyle(fontSize: 10, color:  Color.fromARGB(255, 2, 48, 24))),
          ]),
        );
      },
    );
  }
}

// ── Emergency Video Card ──
class _EmergencyVideoCard extends StatelessWidget {
  final EducationContent content;
  const _EmergencyVideoCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(content.url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {}
      },
      child: Container(
        width: 200, margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(content.thumbnailUrl, height: 110, width: double.infinity, fit: BoxFit.cover,
              loadingBuilder: (c, child, p) => p == null ? child : Container(height: 110, color: Colors.white24, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
              errorBuilder: (_, __, ___) => Container(height: 110, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 36)))),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Text(content.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}