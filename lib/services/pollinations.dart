class Pollinations {
  static const String host = 'https://image.pollinations.ai';

  static const List<String> models = <String>[
    'flux',
    'flux-realism',
    'flux-anime',
    'flux-3d',
    'flux-cablyai',
    'turbo',
  ];

  static const List<({int width, int height, String label})> sizes = [
    (width: 512, height: 512, label: '512 × 512'),
    (width: 768, height: 768, label: '768 × 768'),
    (width: 1024, height: 1024, label: '1024 × 1024'),
    (width: 768, height: 1024, label: '768 × 1024'),
    (width: 1024, height: 768, label: '1024 × 768'),
  ];

  static String imageUrl({
    required String prompt,
    required int seed,
    String model = 'flux',
    int width = 768,
    int height = 768,
    bool enhance = false,
  }) {
    final p = Uri.encodeComponent(prompt);
    final params = <String, String>{
      'width': '$width',
      'height': '$height',
      'seed': '$seed',
      'model': model,
      'nologo': 'true',
      'private': 'true',
      if (enhance) 'enhance': 'true',
    };
    final query =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$host/prompt/$p?$query';
  }
}
