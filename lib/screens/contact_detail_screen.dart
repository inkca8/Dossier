import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../services/contacts_repo.dart';
import '../widgets/contact_fields_editor.dart';
import '../widgets/gallery_strip.dart';
import '../widgets/generate_sheet.dart';
import '../widgets/image_viewer_dialog.dart';
import '../widgets/portrait.dart';
import '../widgets/stats_editor.dart';

class ContactDetailScreen extends StatefulWidget {
  final String contactId;
  const ContactDetailScreen({super.key, required this.contactId});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late final TextEditingController _name;
  late final TextEditingController _race;
  late final TextEditingController _charClass;
  late final TextEditingController _level;
  late final TextEditingController _backstory;
  late final Map<String, TextEditingController> _stats;

  @override
  void initState() {
    super.initState();
    final c = repo.byId(widget.contactId);
    _name = TextEditingController(text: c?.name ?? '');
    _race = TextEditingController(text: c?.race ?? '');
    _charClass = TextEditingController(text: c?.charClass ?? '');
    _level = TextEditingController(text: (c?.level ?? 1).toString());
    _backstory = TextEditingController(text: c?.backstory ?? '');
    _stats = {
      'STR': TextEditingController(text: (c?.stats.str ?? 10).toString()),
      'DEX': TextEditingController(text: (c?.stats.dex ?? 10).toString()),
      'CON': TextEditingController(text: (c?.stats.con ?? 10).toString()),
      'INT': TextEditingController(text: (c?.stats.intl ?? 10).toString()),
      'WIS': TextEditingController(text: (c?.stats.wis ?? 10).toString()),
      'CHA': TextEditingController(text: (c?.stats.cha ?? 10).toString()),
    };
  }

  @override
  void dispose() {
    _name.dispose();
    _race.dispose();
    _charClass.dispose();
    _level.dispose();
    _backstory.dispose();
    for (final c in _stats.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final c = repo.byId(widget.contactId);
    if (c == null) return;
    c.name = _name.text.trim();
    c.race = _race.text.trim();
    c.charClass = _charClass.text.trim();
    c.level = int.tryParse(_level.text) ?? c.level;
    c.backstory = _backstory.text;
    c.stats.str = int.tryParse(_stats['STR']!.text) ?? c.stats.str;
    c.stats.dex = int.tryParse(_stats['DEX']!.text) ?? c.stats.dex;
    c.stats.con = int.tryParse(_stats['CON']!.text) ?? c.stats.con;
    c.stats.intl = int.tryParse(_stats['INT']!.text) ?? c.stats.intl;
    c.stats.wis = int.tryParse(_stats['WIS']!.text) ?? c.stats.wis;
    c.stats.cha = int.tryParse(_stats['CHA']!.text) ?? c.stats.cha;
    await repo.upsert(c);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final c = repo.byId(widget.contactId);
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Contact not found.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(c.displayName),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, c),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await _save();
              if (!context.mounted) return;
              await showGenerateSheet(context, c.id);
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate portrait'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Center(
                child: Portrait(
                  contact: c,
                  size: 220,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 24),
              ContactFieldsEditor(
                name: _name,
                race: _race,
                charClass: _charClass,
                level: _level,
                onChanged: _save,
              ),
              const SizedBox(height: 24),
              StatsEditor(controllers: _stats, onChanged: _save),
              const SizedBox(height: 24),
              TextField(
                controller: _backstory,
                maxLines: null,
                minLines: 3,
                onChanged: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'Backstory / notes',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              Text('Gallery',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GalleryStrip(
                contact: c,
                onTap: (i) =>
                    showImageViewerDialog(context, contact: c, index: i),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Contact c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${c.displayName}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.remove(c.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
