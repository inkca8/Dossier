import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../repo.dart';
import '../widgets/portrait.dart';

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

  Contact get _contact => repo.byId(widget.contactId)!;

  @override
  void initState() {
    super.initState();
    final c = _contact;
    _name = TextEditingController(text: c.name);
    _race = TextEditingController(text: c.race);
    _charClass = TextEditingController(text: c.charClass);
    _level = TextEditingController(text: c.level.toString());
    _backstory = TextEditingController(text: c.backstory);
    _stats = {
      'STR': TextEditingController(text: c.stats.str.toString()),
      'DEX': TextEditingController(text: c.stats.dex.toString()),
      'CON': TextEditingController(text: c.stats.con.toString()),
      'INT': TextEditingController(text: c.stats.intl.toString()),
      'WIS': TextEditingController(text: c.stats.wis.toString()),
      'CHA': TextEditingController(text: c.stats.cha.toString()),
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
    final c = _contact;
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
          return const Scaffold(body: Center(child: Text('Contact not found')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(c.name.isEmpty ? 'New contact' : c.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, c),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openGenerateSheet(context, c),
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
              _fields(),
              const SizedBox(height: 24),
              _statsBlock(),
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
              Text('Gallery', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _gallery(c),
            ],
          ),
        );
      },
    );
  }

  Widget _fields() {
    return Column(
      children: [
        TextField(
          controller: _name,
          onChanged: (_) => _save(),
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _race,
                onChanged: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'Race',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _charClass,
                onChanged: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 88,
              child: TextField(
                controller: _level,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsBlock() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _stats.entries.map((e) {
        return SizedBox(
          width: 92,
          child: TextField(
            controller: e.value,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            onChanged: (_) => _save(),
            decoration: InputDecoration(
              labelText: e.key,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _gallery(Contact c) {
    if (c.gallery.isEmpty) {
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
        itemCount: c.gallery.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final g = c.gallery[i];
          final isDefault = c.defaultImageIndex == i ||
              (c.defaultImageIndex == -1 && i == c.gallery.length - 1);
          return GestureDetector(
            onTap: () => _openImageDialog(context, c, i),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    g.url,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 120,
                        height: 120,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
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
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openImageDialog(
      BuildContext context, Contact c, int index) async {
    final g = c.gallery[index];
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(g.url, fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.prompt, style: Theme.of(ctx).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      '${g.model} • seed ${g.seed} • ${g.width}×${g.height}',
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.outline,
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
                    onPressed: () async {
                      c.gallery.removeAt(index);
                      if (c.defaultImageIndex == index) {
                        c.defaultImageIndex = -1;
                      } else if (c.defaultImageIndex > index) {
                        c.defaultImageIndex -= 1;
                      }
                      await repo.upsert(c);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      c.defaultImageIndex = index;
                      await repo.upsert(c);
                      if (ctx.mounted) Navigator.of(ctx).pop();
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
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Contact c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${c.name.isEmpty ? "contact" : c.name}?'),
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

  Future<void> _openGenerateSheet(BuildContext context, Contact c) async {
    await _save();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _GenerateSheet(contactId: c.id),
    );
  }
}

class _GenerateSheet extends StatefulWidget {
  final String contactId;
  const _GenerateSheet({required this.contactId});

  @override
  State<_GenerateSheet> createState() => _GenerateSheetState();
}

class _GenerateSheetState extends State<_GenerateSheet> {
  late final TextEditingController _prompt;
  late final TextEditingController _seed;
  String _model = 'flux';
  int _width = 768;
  int _height = 768;
  bool _randomSeed = true;

  @override
  void initState() {
    super.initState();
    final c = repo.byId(widget.contactId)!;
    _prompt = TextEditingController(text: suggestPrompt(c));
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
    final c = repo.byId(widget.contactId)!;
    final seed = _randomSeed
        ? _newSeed()
        : (int.tryParse(_seed.text) ?? _newSeed());
    final g = GalleryImage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prompt: _prompt.text.trim(),
      seed: seed,
      model: _model,
      width: _width,
      height: _height,
      createdAt: DateTime.now(),
    );
    c.gallery.add(g);
    c.defaultImageIndex = c.gallery.length - 1;
    await repo.upsert(c);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
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
                    initialValue: _model,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                    items: kPollinationsModels
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _model = v ?? 'flux'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: '${_width}x$_height',
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '512x512', child: Text('512 × 512')),
                      DropdownMenuItem(value: '768x768', child: Text('768 × 768')),
                      DropdownMenuItem(value: '1024x1024', child: Text('1024 × 1024')),
                      DropdownMenuItem(value: '768x1024', child: Text('768 × 1024')),
                      DropdownMenuItem(value: '1024x768', child: Text('1024 × 768')),
                    ],
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
                      onChanged: (v) => setState(() => _randomSeed = v ?? true),
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
              'Images are generated by Pollinations.ai. The same prompt + seed + model always re-creates the same image.',
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
