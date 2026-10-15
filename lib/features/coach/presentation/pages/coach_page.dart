import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recova/services/api_service.dart';
import '../models/coach_chat_message.dart';
import '../models/coach_persona.dart';
import '../widgets/coach_chat_bubble.dart';
import '../widgets/coach_chat_input_bar.dart';
import '../widgets/coach_persona_selector.dart';

/// Screen for interactive conversational AI recovery coaching with selectable personas.
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

  final List<CoachPersona> _personas = CoachPersona.defaultPersonas;
  final List<CoachChatMessage> _messages = [];

  CoachPersona get _selectedPersona {
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
                  DateTime.tryParse(
                    (item['created_at'] ?? '').toString(),
                  )?.toLocal() ??
                  DateTime.now();

              String? personaKeyForMessage;
              if (role != 'user') {
                final rawPersona =
                    (item['persona_used'] ??
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
                      _personaCache[primaryKey] ??
                      _personaCache[_contentFallbackKey(content)];
                }

                if (personaKeyForMessage != null) {
                  _personaCache[_personaCacheKey(
                        id: messageId,
                        content: content,
                        createdAt: createdAt,
                      )] =
                      personaKeyForMessage;
                  _personaCache[_contentFallbackKey(content)] =
                      personaKeyForMessage;
                }
              }

              return CoachChatMessage(
                text: content,
                isAI: role != 'user',
                createdAt: createdAt,
                personaKey: personaKeyForMessage,
              );
            }),
          );

        if (_messages.isEmpty) {
          _messages.add(
            CoachChatMessage(
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
            CoachChatMessage(
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

  CoachPersona _personaFromKey(String rawKey) {
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

  Future<void> _onSelectPersona(CoachPersona persona) async {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan persona')));
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
      _messages.add(CoachChatMessage(text: input, isAI: false, createdAt: now));
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final result = await ApiService.askAiCoach(message: input);
      if (!mounted) return;

      final responseText = (result['response'] ?? '').toString().trim();
      final personaUsedRaw = (result['persona_used'] ?? '').toString();
      final personaUsed =
          personaUsedRaw.isNotEmpty
              ? _personaFromKey(personaUsedRaw)
              : activePersonaAtSend;

      setState(() {
        if (responseText.isNotEmpty) {
          _messages.add(
            CoachChatMessage(
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
          CoachChatMessage(
            text:
                'Maaf, Billy belum bisa membalas sekarang. Coba lagi sebentar.',
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat With Billy',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
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
          child: Container(color: colorScheme.outlineVariant, height: 1),
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
                    child:
                        _isLoading
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
                                final message = _messages[index];
                                return CoachChatBubble(
                                  message: message,
                                  avatarPath: _avatarForPersonaKey(
                                    message.personaKey,
                                  ),
                                  personaTitle: _titleForPersonaKey(
                                    message.personaKey,
                                  ),
                                  avatarSize: _avatarSize,
                                );
                              },
                            ),
                  ),
                ),
                CoachChatInputBar(
                  controller: _messageController,
                  isSending: _isSending,
                  onSend: _sendMessage,
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CoachPersonaSelector(
                selectedPersona: _selectedPersona,
                personas: _personas,
                isDropdownOpen: _isDropdownOpen,
                avatarSize: _avatarSize,
                onToggleDropdown: () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                },
                onSelectPersona: _onSelectPersona,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
