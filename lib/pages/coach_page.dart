import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recova/services/api_service.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _defaultCoachAvatar = 'assets/images/home/billy.png';
  static const String _personaCacheStorageKey = 'coach_persona_cache_v1';
  static const double _avatarSize = 36;

  bool _isLoading = true;
  bool _isSending = false;
  bool _isDropdownOpen = false;
  String _selectedPersonaKey = 'supportive';
  Map<String, String> _personaCache = {};

  final List<_Persona> _personas = const [
    _Persona(
      key: 'supportive',
      title: 'Supportive Billy',
      desc:
          'Pendamping penuh empati yang siap mendengarkan tanpa menghakimi dan memberikan afirmasi positif saat Anda merasa down.',
      color: Color(0xFFE8F5E9),
      avatarPath: 'assets/images/home/supportiveBilly.png',
    ),
    _Persona(
      key: 'friendly',
      title: 'Friendly Billy',
      desc:
          'Sahabat kasual dan santai yang siap diajak ngobrol tentang apa saja untuk memberikan distraksi positif dari dorongan negatif.',
      color: Color(0xFFE0F2F1),
      avatarPath: 'assets/images/home/friendlyBilly.png',
    ),
    _Persona(
      key: 'direct',
      title: 'Direct Billy',
      desc:
          'Billy yang tegas dan logis yang membantu menjaga akuntabilitas Anda melalui instruksi praktis agar tetap fokus pada tujuan.',
      color: Color(0xFFE8F5E9),
      avatarPath: 'assets/images/home/directBilly.png',
    ),
  ];

  final List<_ChatMessage> _messages = [];

  _Persona get _selectedPersona {
    return _personas.firstWhere(
      (p) => p.key == _selectedPersonaKey,
      orElse: () => _personas.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _personaCache = await _loadPersonaCache();
      final personaKey = await ApiService.getAiPersonaPreference();
      final history = await ApiService.getAiChatHistory(limit: 100);

      if (!mounted) return;

      final sortedHistory = [...history]..sort((a, b) {
        final aTime = DateTime.tryParse((a['created_at'] ?? '').toString());
        final bTime = DateTime.tryParse((b['created_at'] ?? '').toString());

        if (aTime != null && bTime != null) {
          final byTime = aTime.compareTo(bTime);
          if (byTime != 0) return byTime;
        } else if (aTime == null && bTime != null) {
          return -1;
        } else if (aTime != null && bTime == null) {
          return 1;
        }

        final aRole = (a['role'] ?? '').toString();
        final bRole = (b['role'] ?? '').toString();
        if (aRole != bRole) {
          if (aRole == 'user') return -1;
          if (bRole == 'user') return 1;
        }

        final aId = (a['id'] ?? '').toString();
        final bId = (b['id'] ?? '').toString();
        return aId.compareTo(bId);
      });

      setState(() {
        _selectedPersonaKey = _normalizePersonaKey(personaKey);
        _messages
          ..clear()
          ..addAll(
            sortedHistory.map((item) {
              final role = (item['role'] ?? '').toString();
              final content = (item['content'] ?? '').toString();
              final messageId = (item['id'] ?? '').toString();
              final createdAt =
                  DateTime.tryParse((item['created_at'] ?? '').toString())
                          ?.toLocal() ??
                      DateTime.now();

              String? personaKeyForMessage;
              if (role != 'user') {
                final rawPersona = (item['persona_used'] ??
                        item['persona'] ??
                        item['persona_key'] ??
                        '')
                    .toString();

                if (rawPersona.isNotEmpty) {
                  personaKeyForMessage = _normalizePersonaKey(rawPersona);
                } else {
                  final primaryKey = _personaCacheKey(
                    id: messageId,
                    content: content,
                    createdAt: createdAt,
                  );
                  personaKeyForMessage =
                      _personaCache[primaryKey] ?? _personaCache[_contentFallbackKey(content)];
                }

                if (personaKeyForMessage != null) {
                  _personaCache[_personaCacheKey(
                    id: messageId,
                    content: content,
                    createdAt: createdAt,
                  )] = personaKeyForMessage;
                  _personaCache[_contentFallbackKey(content)] = personaKeyForMessage;
                }
              }

              return _ChatMessage(
                text: content,
                isAI: role != 'user',
                createdAt: createdAt,
                personaKey: personaKeyForMessage,
              );
            }),
          );

        if (_messages.isEmpty) {
          _messages.add(
            _ChatMessage(
              text: 'Halo, aku Billy. Ceritakan apa yang sedang kamu rasakan.',
              isAI: true,
              createdAt: DateTime.now(),
              personaKey: _selectedPersona.key,
            ),
          );
        }
      });

      await _savePersonaCache(_personaCache);
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_messages.isEmpty) {
          _messages.add(
            _ChatMessage(
              text: 'Halo, aku Billy. Ceritakan apa yang sedang kamu rasakan.',
              isAI: true,
              createdAt: DateTime.now(),
              personaKey: _selectedPersona.key,
            ),
          );
        }
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _normalizePersonaKey(String rawKey) {
    final lower = rawKey.trim().toLowerCase();
    if (lower.contains('friendly')) return 'friendly';
    if (lower.contains('direct') || lower.contains('concise')) return 'direct';
    if (lower.contains('supportive')) return 'supportive';
    if (_personas.any((p) => p.key == lower)) return lower;
    return 'supportive';
  }

  _Persona _personaFromKey(String rawKey) {
    final key = _normalizePersonaKey(rawKey);
    return _personas.firstWhere(
      (p) => p.key == key,
      orElse: () => _personas.first,
    );
  }

  String _personaCacheKey({
    required String id,
    required String content,
    required DateTime createdAt,
  }) {
    if (id.isNotEmpty) return 'id:$id';
    final minuteStamp = createdAt.toIso8601String().substring(0, 16);
    return 'fallback:$minuteStamp:${content.trim().toLowerCase()}';
  }

  String _contentFallbackKey(String content) {
    return 'content:${content.trim().toLowerCase()}';
  }

  Future<Map<String, String>> _loadPersonaCache() async {
    final raw = await _storage.read(key: _personaCacheStorageKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) {
        return parsed.map((key, value) => MapEntry(key, value.toString()));
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _savePersonaCache(Map<String, String> cache) async {
    try {
      await _storage.write(
        key: _personaCacheStorageKey,
        value: jsonEncode(cache),
      );
    } catch (_) {}
  }

  String _formatTimestamp(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return 'JUST NOW';

    final sameDay =
        now.year == createdAt.year && now.month == createdAt.month && now.day == createdAt.day;

    final hh = createdAt.hour.toString().padLeft(2, '0');
    final mm = createdAt.minute.toString().padLeft(2, '0');
    if (sameDay) return '$hh:$mm';

    final dd = createdAt.day.toString().padLeft(2, '0');
    final mo = createdAt.month.toString().padLeft(2, '0');
    return '$dd/$mo $hh:$mm';
  }

  String _avatarForPersonaKey(String? key) {
    if (key == null || key.isEmpty) return _defaultCoachAvatar;
    final persona = _personas.where((p) => p.key == key);
    if (persona.isEmpty) return _defaultCoachAvatar;
    return persona.first.avatarPath;
  }

  String _titleForPersonaKey(String? key) {
    if (key == null || key.isEmpty) return 'Billy';
    final persona = _personas.where((p) => p.key == key);
    if (persona.isEmpty) return 'Billy';
    return persona.first.title;
  }

  Future<void> _onSelectPersona(_Persona persona) async {
    final previous = _selectedPersonaKey;
    setState(() {
      _selectedPersonaKey = persona.key;
      _isDropdownOpen = false;
    });

    try {
      await ApiService.updateAiPersonaPreference(persona: persona.key);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedPersonaKey = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan persona')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final input = _messageController.text.trim();
    if (input.isEmpty || _isSending) return;

    final activePersonaAtSend = _selectedPersona;
    final now = DateTime.now();

    setState(() {
      _isSending = true;
      _isDropdownOpen = false;
      _messages.add(
        _ChatMessage(
          text: input,
          isAI: false,
          createdAt: now,
        ),
      );
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final result = await ApiService.askAiCoach(message: input);
      if (!mounted) return;

      final responseText = (result['response'] ?? '').toString().trim();
      final personaUsedRaw = (result['persona_used'] ?? '').toString();
      final personaUsed =
          personaUsedRaw.isNotEmpty ? _personaFromKey(personaUsedRaw) : activePersonaAtSend;

      setState(() {
        if (responseText.isNotEmpty) {
          _messages.add(
            _ChatMessage(
              text: responseText,
              isAI: true,
              createdAt: DateTime.now(),
              personaKey: personaUsed.key,
            ),
          );

          _personaCache[_contentFallbackKey(responseText)] = personaUsed.key;
        }
        _selectedPersonaKey = personaUsed.key;
      });
      await _savePersonaCache(_personaCache);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'Maaf, Billy belum bisa membalas sekarang. Coba lagi sebentar.',
            isAI: true,
            createdAt: DateTime.now(),
            personaKey: activePersonaAtSend.key,
          ),
        );
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Billy',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF1F5F9),
              child: Image.asset(
                _selectedPersona.avatarPath,
                width: _avatarSize,
                height: _avatarSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_isDropdownOpen) {
                        setState(() {
                          _isDropdownOpen = false;
                        });
                      }
                    },
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 74,
                              bottom: 16,
                            ),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                  ),
                ),
                _buildInputField(),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildFloatingPersonaSelector(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingPersonaSelector() {
    final availablePersonas = _personas.where((p) => p.key != _selectedPersonaKey).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
        ),
        boxShadow: _isDropdownOpen
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isDropdownOpen = !_isDropdownOpen;
              });
            },
            child: Row(
              children: [
                Image.asset(
                  _selectedPersona.avatarPath,
                  width: _avatarSize,
                  height: _avatarSize,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedPersona.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF0F172A),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          if (_isDropdownOpen) const SizedBox(height: 12),
          if (_isDropdownOpen && availablePersonas.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F8C72),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: availablePersonas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final persona = entry.value;

                  return GestureDetector(
                    onTap: () => _onSelectPersona(persona),
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 2,
                        right: 2,
                        top: index == 0 ? 2 : 0,
                        bottom: index == availablePersonas.length - 1 ? 2 : 0,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: persona.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            persona.avatarPath,
                            width: _avatarSize,
                            height: _avatarSize,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  persona.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  persona.desc,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final timeLabel = _formatTimestamp(message.createdAt);

    if (!message.isAI) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeLabel,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final avatarPath = _avatarForPersonaKey(message.personaKey);
    final personaTitle = _titleForPersonaKey(message.personaKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                avatarPath,
                width: _avatarSize,
                height: _avatarSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  personaTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildMarkdownMessage(message.text),
          ),
          const SizedBox(height: 8),
          Text(
            timeLabel,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownMessage(String text) {
    return MarkdownBody(
      data: text,
      selectable: false,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          height: 1.5,
        ),
        strong: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
        em: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
        listBullet: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !_isSending,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Reply ...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isSending ? null : _sendMessage,
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isSending ? const Color(0xFF94A3B8) : const Color(0xFF0F8C72),
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 16,
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

class _Persona {
  const _Persona({
    required this.key,
    required this.title,
    required this.desc,
    required this.color,
    required this.avatarPath,
  });

  final String key;
  final String title;
  final String desc;
  final Color color;
  final String avatarPath;
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isAI,
    required this.createdAt,
    this.personaKey,
  });

  final String text;
  final bool isAI;
  final DateTime createdAt;
  final String? personaKey;
}
