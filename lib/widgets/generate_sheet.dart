import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/contact.dart';
import '../models/gallery_image.dart';
import '../services/contacts_repo.dart';
import '../services/logger.dart';
import '../services/pollinations.dart';
import '../services/prompt_suggest.dart';

Future<void> showGenerateSheet(BuildContext context, String contactId) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => GenerateSheet(contactId: contactId),
  );
}

class GenerateSheet extends StatefulWidget {
  final String contactId;
  const GenerateSheet({super.key, required this.contactId});

  @override
  State<GenerateSheet> createState() => _GenerateSheetState();
}

class _GenerateSheetState extends State<GenerateSheet> {
  late final TextEditingController _prompt;
  late final TextEditingController _seed;
  String _model = 'flux';
  int _width = 768;
  int _height = 768;
  bool _randomSeed = true;

  Contact? get _contact => repo.byId(widget.contactId);

  @override
  void initState() {
    super.initState();
    final c = _contact;
    _prompt = TextEditingController(text: c == null ? '' : suggestPrompt(c));
    _seed = TextEditingController(text: _newSeed().toString());
  }

  int _newSeed() => Random().nextInt(1 << 31);

  @override
  void dispose() {
    _prompt.dispose();
    _seed.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final c = _contact;
    if (c == null) {
      AppLogger.instance.warn('Generate: contact ${widget.contactId} no longer exists.');
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final seed = _randomSeed
        ? _newSeed()
        : (int.tryParse(_seed.text) ?? _newSeed());
    final prompt = _prompt.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt cannot be empty.')),
      );
      return;
    }
    final g = GalleryImage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prompt: prompt,
      seed: seed,
      model: _model,
      width: _width,
      height: _height,
      createdAt: DateTime.now(),
    );
    AppLogger.instance.info(
      'Queued generation: model=$_model seed=$seed size=${_width}x$_height prompt="$prompt"',
    );
    c.gallery.add(g);
    c.defaultImageIndex = c.gallery.length - 1;
    await repo.upsert(c);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final sizeValue = '${_width}x$_height';
    final knownSizes = Pollinations.sizes
        .map((s) => '${s.width}x${s.height}')
        .toSet();
    final currentSize = knownSizes.contains(sizeValue) ? sizeValue : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + inset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Generate portrait',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prompt,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: 'Prompt',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: Pollinations.models.contains(_model) ? _model : null,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                    items: Pollinations.models
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _model = v ?? 'flux'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currentSize,
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      border: OutlineInputBorder(),
                    ),
                    items: Pollinations.sizes
                        .map((s) => DropdownMenuItem(
                              value: '${s.width}x${s.height}',
                              child: Text(s.label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final parts = v.split('x');
                      setState(() {
                        _width = int.parse(parts[0]);
                        _height = int.parse(parts[1]);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _seed,
                    enabled: !_randomSeed,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Seed',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _randomSeed,
                      onChanged: (v) =>
                          setState(() => _randomSeed = v ?? true),
                    ),
                    const Text('Random'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate'),
            ),
            const SizedBox(height: 4),
            Text(
              'Pollinations.ai may take 10–40 seconds on first request. '
              'Same prompt + seed + model always reproduces the same image.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
