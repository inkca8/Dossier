import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/contact.dart';
import '../services/contacts_repo.dart';
import 'safe_network_image.dart';

Future<void> showImageViewerDialog(
  BuildContext context, {
  required Contact contact,
  required int index,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => _ImageViewerDialog(contactId: contact.id, index: index),
  );
}

class _ImageViewerDialog extends StatelessWidget {
  final String contactId;
  final int index;
  const _ImageViewerDialog({required this.contactId, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final c = repo.byId(contactId);
        if (c == null || index >= c.gallery.length) {
          return const SizedBox.shrink();
        }
        final g = c.gallery[index];
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: SafeNetworkImage(
                      url: g.url,
                      fit: BoxFit.contain,
                      debugLabel: 'viewer:${g.id}',
                      showUrlInError: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.prompt,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        '${g.model} • seed ${g.seed} • ${g.width}×${g.height}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy URL'),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: g.url)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        c.gallery.removeAt(index);
                        if (c.defaultImageIndex == index) {
                          c.defaultImageIndex = -1;
                        } else if (c.defaultImageIndex > index) {
                          c.defaultImageIndex -= 1;
                        }
                        await repo.upsert(c);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        c.defaultImageIndex = index;
                        await repo.upsert(c);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Set as default'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
