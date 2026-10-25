// lib/Screens/crm/crm_notes_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmNotesScreen extends StatefulWidget {
  const CrmNotesScreen({Key? key}) : super(key: key);

  @override
  State<CrmNotesScreen> createState() => _CrmNotesScreenState();
}

class _CrmNotesScreenState extends State<CrmNotesScreen> {
  bool _isLoading = true;
  List<CrmNote> _notes = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await CrmApiService.getNotes(search: _searchCtrl.text.trim());
    if (mounted) {
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmHeader(
            title: 'CRM Internal Notes',
            subtitle: 'Rich customer notes, call summaries, contract requirements, and team memos.',
            icon: Icons.note_alt_outlined,
            onRefresh: _loadNotes,
            actionLabel: 'New Note',
            actionIcon: Icons.edit_note,
            onAction: () async {
              final ok = await CrmDialogs.showNoteDialog(context);
              if (ok == true) _loadNotes();
            },
          ),

          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: CrmTheme.cardDecoration,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _loadNotes(),
                    decoration: CrmTheme.inputDecoration(
                      hintText: 'Search notes by keyword or content...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: CrmTheme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loadNotes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CrmTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Notes Grid
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
          else if (_notes.isEmpty)
            Container(
              decoration: CrmTheme.cardDecoration,
              child: CrmEmptyState(
                icon: Icons.edit_off_outlined,
                title: 'No Notes Recorded',
                message: 'Add internal memos and records to keep context shared across your team.',
                actionLabel: 'Add First Note',
                onAction: () async {
                  final ok = await CrmDialogs.showNoteDialog(context);
                  if (ok == true) _loadNotes();
                },
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _notes.length,
                  itemBuilder: (ctx, i) {
                    final note = _notes[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: note.isPinned ? const Color(0xFFFEFCE8) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: note.isPinned ? const Color(0xFFFDE047) : CrmTheme.border),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (note.isPinned) ...[
                                    const Icon(Icons.push_pin, size: 14, color: CrmTheme.amber),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    note.title.isNotEmpty ? note.title : 'Internal Note',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 16, color: CrmTheme.rose),
                                onPressed: () async {
                                  await CrmApiService.deleteNote(note.id);
                                  _loadNotes();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                note.content,
                                style: const TextStyle(fontSize: 13, color: CrmTheme.textPrimary, height: 1.4),
                              ),
                            ),
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                note.createdByName.isNotEmpty ? note.createdByName : 'Author',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CrmTheme.textSecondary),
                              ),
                              Text(
                                '${note.createdAt.month}/${note.createdAt.day}/${note.createdAt.year}',
                                style: const TextStyle(fontSize: 11, color: CrmTheme.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
