class Stats {
  int str;
  int dex;
  int con;
  int intl;
  int wis;
  int cha;

  Stats({
    this.str = 10,
    this.dex = 10,
    this.con = 10,
    this.intl = 10,
    this.wis = 10,
    this.cha = 10,
  });

  Map<String, dynamic> toJson() => {
        'str': str,
        'dex': dex,
        'con': con,
        'int': intl,
        'wis': wis,
        'cha': cha,
      };

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
        str: (j['str'] ?? 10) as int,
        dex: (j['dex'] ?? 10) as int,
        con: (j['con'] ?? 10) as int,
        intl: (j['int'] ?? 10) as int,
        wis: (j['wis'] ?? 10) as int,
        cha: (j['cha'] ?? 10) as int,
      );
}

const kPollinationsModels = <String>[
  'flux',
  'flux-realism',
  'flux-anime',
  'flux-3d',
  'flux-cablyai',
  'turbo',
];

class GalleryImage {
  final String id;
  final String prompt;
  final int seed;
  final String model;
  final int width;
  final int height;
  final DateTime createdAt;

  GalleryImage({
    required this.id,
    required this.prompt,
    required this.seed,
    this.model = 'flux',
    this.width = 768,
    this.height = 768,
    required this.createdAt,
  });

  String get url {
    final p = Uri.encodeComponent(prompt);
    return 'https://image.pollinations.ai/prompt/$p'
        '?width=$width&height=$height&seed=$seed&model=$model'
        '&nologo=true&enhance=true';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'seed': seed,
        'model': model,
        'width': width,
        'height': height,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GalleryImage.fromJson(Map<String, dynamic> j) => GalleryImage(
        id: j['id'] as String,
        prompt: j['prompt'] as String,
        seed: (j['seed'] as num).toInt(),
        model: (j['model'] as String?) ?? 'flux',
        width: ((j['width'] ?? 768) as num).toInt(),
        height: ((j['height'] ?? 768) as num).toInt(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class Contact {
  String id;
  String name;
  String race;
  String charClass;
  int level;
  String backstory;
  Stats stats;
  List<GalleryImage> gallery;
  int defaultImageIndex;

  Contact({
    required this.id,
    this.name = '',
    this.race = '',
    this.charClass = '',
    this.level = 1,
    this.backstory = '',
    Stats? stats,
    List<GalleryImage>? gallery,
    this.defaultImageIndex = -1,
  })  : stats = stats ?? Stats(),
        gallery = gallery ?? [];

  GalleryImage? get defaultImage {
    if (gallery.isEmpty) return null;
    if (defaultImageIndex >= 0 && defaultImageIndex < gallery.length) {
      return gallery[defaultImageIndex];
    }
    return gallery.last;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'race': race,
        'class': charClass,
        'level': level,
        'backstory': backstory,
        'stats': stats.toJson(),
        'gallery': gallery.map((g) => g.toJson()).toList(),
        'defaultImageIndex': defaultImageIndex,
      };

  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        race: (j['race'] as String?) ?? '',
        charClass: (j['class'] as String?) ?? '',
        level: ((j['level'] ?? 1) as num).toInt(),
        backstory: (j['backstory'] as String?) ?? '',
        stats: j['stats'] != null
            ? Stats.fromJson(Map<String, dynamic>.from(j['stats'] as Map))
            : Stats(),
        gallery: ((j['gallery'] as List?) ?? const [])
            .map((e) => GalleryImage.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        defaultImageIndex: ((j['defaultImageIndex'] ?? -1) as num).toInt(),
      );
}

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
