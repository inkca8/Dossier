import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../services/contacts_repo.dart';
import '../services/logger.dart';
import '../widgets/contact_tile.dart';
import 'contact_detail_screen.dart';
import 'debug_log_screen.dart';

class ContactsListScreen extends StatelessWidget {
  const ContactsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossier'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) => _handleMenu(context, v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'export', child: Text('Export JSON…')),
              PopupMenuItem(value: 'import', child: Text('Import JSON…')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'log', child: Text('Debug log…')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newContact(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New contact'),
      ),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          final contacts = repo.contacts;
          if (contacts.isEmpty) return const _EmptyState();
          return LayoutBuilder(
            builder: (context, constraints) {
              final cols =
                  (constraints.maxWidth / 200).floor().clamp(2, 8);
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: contacts.length,
                itemBuilder: (context, i) =>
                    ContactTile(contact: contacts[i]),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _newContact(BuildContext context) async {
    final c = Contact(id: DateTime.now().microsecondsSinceEpoch.toString());
    await repo.upsert(c);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactDetailScreen(contactId: c.id),
      ),
    );
  }

  Future<void> _handleMenu(BuildContext context, String action) async {
    switch (action) {
      case 'export':
        await _export(context);
        break;
      case 'import':
        await _import(context);
        break;
      case 'log':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DebugLogScreen()),
        );
        break;
    }
  }

  Future<void> _export(BuildContext context) async {
    final json = repo.exportJson();
    final bytes = Uint8List.fromList(utf8.encode(json));
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    try {
      await FileSaver.instance.saveFile(
        name: 'dossier-$stamp',
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported.')),
      );
    } catch (e, s) {
      AppLogger.instance.warn('Export failed, falling back to dialog.', e, s);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Export JSON'),
          content: SizedBox(
            width: 500,
            child: SelectableText(json),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _import(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    final bytes = res.files.single.bytes;
    if (bytes == null) return;
    try {
      final n = await repo.importJson(utf8.decode(bytes));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $n contact(s).')),
      );
    } catch (e, s) {
      AppLogger.instance.error('Import failed.', e, s);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text(
              'No contacts yet.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap "New contact" to add your first character.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
