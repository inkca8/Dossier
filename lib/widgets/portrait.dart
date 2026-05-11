import 'package:flutter/material.dart';

import '../models.dart';

class Portrait extends StatelessWidget {
  final Contact contact;
  final double size;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const Portrait({
    super.key,
    required this.contact,
    this.size = 96,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size / 8);
    final img = contact.defaultImage;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: img == null
            ? _initialsPlaceholder(context)
            : Image.network(
                img.url,
                fit: fit,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stack) => _initialsPlaceholder(context),
              ),
      ),
    );
  }

  Widget _initialsPlaceholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        contact.initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
