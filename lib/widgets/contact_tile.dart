import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../screens/contact_detail_screen.dart';
import '../services/contacts_repo.dart';
import 'portrait.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  const ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (contact.race.isNotEmpty) contact.race,
      if (contact.charClass.isNotEmpty) contact.charClass,
    ];
    final subtitle = 'Lv ${contact.level}'
        '${subtitleParts.isNotEmpty ? " ${subtitleParts.join(" • ")}" : ""}';
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ContactDetailScreen(contactId: contact.id),
          ),
        ),
        onLongPress: () => _confirmDelete(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Portrait(
                contact: contact,
                size: 1000,
                borderRadius: BorderRadius.zero,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: scheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${contact.displayName}?'),
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
    if (ok == true) await repo.remove(contact.id);
  }
}
