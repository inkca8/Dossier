import 'package:flutter/material.dart';

import '../models/contact.dart';
import 'safe_network_image.dart';

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
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: img == null
            ? Container(
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
              )
            : SafeNetworkImage(
                url: img.url,
                fit: fit,
                debugLabel: 'portrait:${contact.displayName}',
              ),
      ),
    );
  }
}
