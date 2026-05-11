import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../models/gallery_image.dart';
import 'safe_network_image.dart';

class GalleryStrip extends StatelessWidget {
  final Contact contact;
  final void Function(int index) onTap;

  const GalleryStrip({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (contact.gallery.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No portraits yet. Tap "Generate portrait" to create one.',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: contact.gallery.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final g = contact.gallery[i];
          final isDefault = contact.defaultImageIndex == i ||
              (contact.defaultImageIndex == -1 &&
                  i == contact.gallery.length - 1);
          return _Thumb(image: g, isDefault: isDefault, onTap: () => onTap(i));
        },
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final GalleryImage image;
  final bool isDefault;
  final VoidCallback onTap;

  const _Thumb({
    required this.image,
    required this.isDefault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SafeNetworkImage(
              url: image.url,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              debugLabel: 'gallery-thumb:${image.id}',
            ),
          ),
          if (isDefault)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
