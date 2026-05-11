import 'gallery_image.dart';
import 'stats.dart';

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

  String get displayName => name.trim().isEmpty ? 'Unnamed' : name;

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
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
            .map((e) =>
                GalleryImage.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        defaultImageIndex: ((j['defaultImageIndex'] ?? -1) as num).toInt(),
      );
}
