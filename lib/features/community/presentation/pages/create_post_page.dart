import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/core/ui/app_toast.dart';
import 'package:recova/features/community/presentation/cubit/community_cubit.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  String _selectedCategory = 'Nasihat';
  final List<String> _categories = ['Nasihat', 'Bantuan', 'Motivasi'];

  void _submitPost(BuildContext context) {
    final title = _titleController.text.trim();
    final content = _textController.text.trim();
    final colorScheme = Theme.of(context).colorScheme;

    if (title.isEmpty || content.isEmpty) {
      AppToast.showWarning(
        context,
        'Judul dan isi tulisan tidak boleh kosong.',
      );
      return;
    }

    context.read<CommunityCubit>().createPost(
      title: title,
      content: content,
      category: _selectedCategory,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    return BlocListener<CommunityCubit, CommunityState>(
      listener: (context, state) {
        if (state is CommunitySubmitSuccess) {
          Navigator.pop(context);
          AppToast.showSuccess(context, 'Postingan berhasil dibuat!');
        } else if (state is CommunitySubmitFailure) {
          AppToast.showError(
            context,
            'Gagal membuat postingan: ${state.error}',
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Buat Postingan Baru',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedCategory = newValue);
                  }
                },
                items:
                    _categories
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 24),

              Text(
                'Judul',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Tulis judul postinganmu...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Isi Postingan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 10,
                minLines: 6,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Apa yang ingin kamu bagikan?',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            final isSubmitting = state is CommunitySubmitting;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () => _submitPost(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child:
                      isSubmitting
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                          : const Text(
                            'Kirim',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
