import '../models/contact.dart';

String suggestPrompt(Contact c) {
  final descriptor = <String>[
    if (c.level > 0) 'level ${c.level}',
    if (c.race.isNotEmpty) c.race,
    if (c.charClass.isNotEmpty) c.charClass,
  ].join(' ');
  final bits = <String>[
    'detailed fantasy portrait',
    if (c.name.isNotEmpty) 'of ${c.name}',
    if (descriptor.isNotEmpty) 'a $descriptor',
    'RPG character, digital painting, dramatic lighting, head and shoulders',
  ];
  return bits.join(', ');
}
