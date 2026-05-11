import '../services/pollinations.dart';

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

  String get url => Pollinations.imageUrl(
        prompt: prompt,
        seed: seed,
        model: model,
        width: width,
        height: height,
      );

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
