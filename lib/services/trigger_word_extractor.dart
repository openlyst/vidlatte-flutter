import 'dart:convert';

class TriggerWord {
  final String word;
  final int count;
  final String source;

  const TriggerWord({
    required this.word,
    this.count = 0,
    required this.source,
  });
}

class TriggerWordExtractor {
  static const _genericTags = {
    'solo', '1girl', '2girls', '1boy', '2boys', 'multiple girls', 'multiple boys',
    'smile', 'open mouth', 'closed mouth', 'looking at viewer', 'simple background',
    'white background', 'grey background', 'black background', 'transparent background',
    'full body', 'upper body', 'lower body', 'close-up', 'detailed face', 'detailed eyes',
    'long hair', 'short hair', 'blonde hair', 'black hair', 'blue hair', 'brown hair',
    'blue eyes', 'green eyes', 'red eyes', 'brown eyes', 'black eyes', 'yellow eyes',
    'breasts', 'large breasts', 'small breasts', 'medium breasts',
    'blush', 'light blush', 'nose blush',
    'bangs', 'eyebrows', 'eyelashes',
    'shirt', 'white shirt', 'black shirt', 'jacket', 'hoodie', 'pants', 'black pants',
    'shoes', 'black footwear', 'barefoot',
    'sitting', 'standing', 'lying', 'kneeling',
    'outdoors', 'indoors', 'sky', 'cloudy sky', 'blue sky',
    'tree', 'trees', 'grass', 'flower', 'flowers',
    'day', 'night', 'sunset', 'sunrise',
    'photo', 'photorealistic', 'realistic', 'anime', 'cartoon', 'comic',
    'high quality', 'best quality', 'masterpiece', 'detailed', 'highres',
    'no humans', 'animal focus', 'animal', 'mammal',
    'male focus', 'female focus', 'furry', 'anthro',
    'tail', 'ears', 'animal ears', 'cat ears', 'dog ears', 'cat tail', 'dog tail',
    'paws', 'claws', 'fangs', 'teeth',
    'collar', 'bell', 'bow', 'necklace',
    'gloves', 'socks', 'stockings', 'boots',
    'hat', 'cap', 'glasses', 'sunglasses',
    'dress', 'skirt', 'shorts', 'jeans',
    'coat', 'scarf', 'vest',
    'hand up', 'hands up', 'hand in pocket', 'hand on own face', 'hand on own cheek',
    'pocket', 'drawstring',
    'off shoulder', 'sleeveless', 'sleeveless shirt', 'long sleeves', 'short sleeves',
    'layered sleeves',
    'jewelry', 'earrings', 'piercing', 'ear piercing',
    'muscular', 'muscular male', 'bara', 'pectorals', 'large pectorals', 'abs',
    'thighs', 'thick thighs', 'stomach', 'navel',
    'nipples', 'nude', 'completely nude', 'uncensored', 'penis', 'erection',
    'testicles', 'anus',
    'heart', 'sparkle', 'crescent',
    'tongue', 'tongue out', 'fang',
    'yaoi', 'furry with furry', 'furry male',
    'flat color', 'monochrome', 'colored sclera',
    'purple theme', 'purple skin', 'purple background', 'red theme',
    'young', 'female', 'male', 'dog', 'cat', 'wolf', 'fox',
    'rectangular-shaped body', 'two-tone fur', 'blue fur', 'red fur', 'white fur',
    'black nose', 'red blush',
    'focusing', 'focusing on', 'furry female',
    'solo focus',
    'animal feet', 'pawpads',
    'jingle bell', 'tail ornament',
    'official style', 'from behind', 'from below', 'from rear',
    'pigtails', 'deer', 'fish', 'robot', 'animatronic',
    'canine', 'feline', 'marine', 'lamia', 'anglerfish', '3d',
    'semi-anthro', 'quadruped', 'feral',
    'whiskers', 'animal nose', 'pink nose', 'shiny nose',
    'glowing eyes', 'black sclera', 'white sclera', 'red glowing eyes',
    'orange eyes', 'orange fur', 'black fur', 'purple fur', 'brown fur',
    'grey fur', 'multicolored fur', 'striped fur', 'light tan fur accents',
    'tufted fur', 'fluffy chest', 'fluffy ears',
    'short antlers', 'small ears', 'small tail', 'fox tail',
    '3 spots on back', 'dipstick tail', 'hooves',
    'orange pawpads', 'green paws', 'green neck tuft',
    'pumpkin-shaped head', 'black body',
    'red nose', 'red and white striped antlers',
    'heavily damaged', 'missing face', 'jagged teeth',
    'expose wiring', 'red bow tie', 'two black chest buttons',
    'scuffed', 'ripped', 'misaligned rabbit ears', 'hollow face',
    'metal right hand', 'metal left foot', 'amputated arm', 'withering',
    'animatronic rabbit', 'sharp teeth', 'red body',
    'black thigh high socks', 'robot joints',
    'anglerfish lure', '3 arm', '3 eye',
    'beanie', 'cat girl', 'pointed ears', 'short',
    'tan muzzle', 'reddish-brown fur', 'white eyebrows', 'white whiskers',
    'pink shirt', 'hairbow',
  };

  static const _genericDatasets = {
    'img', 'images', 'image', 'train', 'training', 'data', 'dataset',
    'pics', 'photos', 'input', 'lora', 'my_lora', 'custom',
    'nueva carpeta', 'new folder', 'untitled', 'folder',
  };

  static bool _isGeneric(String tag) =>
      _genericTags.contains(tag.toLowerCase());

  static bool _isGenericDataset(String name) =>
      _genericDatasets.contains(name.toLowerCase());

  static List<TriggerWord> extract(Map<String, dynamic>? metadata, String loraName) {
    final words = <_Word>[];

    void add(String word, int count, int priority) {
      if (word.isEmpty) return;
      final existing = words.where((w) => w.word.toLowerCase() == word.toLowerCase());
      if (existing.isNotEmpty) {
        final w = existing.first;
        if (count > w.count) w.count = count;
        if (priority > w.priority) w.priority = priority;
        return;
      }
      words.add(_Word(word, count, priority));
    }

    if (metadata != null) {
      _checkExplicitFields(metadata, add);
      _parseTagFrequency(metadata, add);
    }

    if (words.isEmpty) {
      _extractFromFilename(loraName, add);
    }

    words.sort((a, b) {
      if (a.priority != b.priority) return b.priority - a.priority;
      return b.count - a.count;
    });

    return words.map((w) => TriggerWord(
      word: w.word,
      count: w.count,
      source: _sourceName(w.priority),
    )).toList();
  }

  static String _sourceName(int priority) {
    switch (priority) {
      case 4: return 'explicit';
      case 3: return 'dataset name';
      case 2: return 'tag frequency';
      default: return 'filename';
    }
  }

  static void _checkExplicitFields(Map<String, dynamic> meta, void Function(String, int, int) add) {
    const fields = [
      'civitai_trigger_words',
      'trigger_word',
      'trigger_words',
      'ss_trigger_word',
      'civitai',
    ];

    for (final field in fields) {
      final val = meta[field];
      if (val == null) continue;

      if (val is String) {
        if (val.isNotEmpty) add(val, 0, 4);
      } else if (val is List) {
        for (final item in val) {
          if (item is String && item.isNotEmpty) add(item, 0, 4);
        }
      } else if (val is Map) {
        final tw = val['trigger_words'];
        if (tw is List) {
          for (final item in tw) {
            if (item is String && item.isNotEmpty) add(item, 0, 4);
          }
        }
      }
    }
  }

  static void _extractFromDatasetNames(Map<String, dynamic> tagFreq, void Function(String, int, int) add) {
    for (final key in tagFreq.keys) {
      var p = key;
      while (p.isNotEmpty && _isDigit(p.codeUnitAt(0))) p = p.substring(1);
      if (p.isNotEmpty && p[0] == '_') p = p.substring(1);
      if (p.isEmpty) continue;
      if (!_isGenericDataset(p)) add(p, 0, 3);
    }
  }

  static bool _isDigit(int c) => c >= 48 && c <= 57;

  static bool _isCaptionStyle(Map<String, dynamic> tags) {
    int longCount = 0;
    int total = 0;
    for (final tag in tags.keys) {
      total++;
      if (tag.length > 30) longCount++;
    }
    return total > 0 && longCount > total ~/ 2;
  }

  static void _extractCaptionTrigger(Map<String, dynamic> tags, void Function(String, int, int) add) {
    final wordCounts = <String, int>{};

    for (final tag in tags.keys) {
      final spaceIdx = tag.indexOf(' ');
      final firstWord = spaceIdx >= 0 ? tag.substring(0, spaceIdx) : tag;
      if (firstWord.isEmpty) continue;
      wordCounts[firstWord.toLowerCase()] = (wordCounts[firstWord.toLowerCase()] ?? 0) + 1;
    }

    String? bestWord;
    int bestCount = 0;
    wordCounts.forEach((word, count) {
      if (count > bestCount) {
        bestCount = count;
        bestWord = word;
      }
    });

    if (bestWord != null && bestCount > 1) {
      add(bestWord!, bestCount, 2);
    }
  }

  static Map<String, dynamic>? _parseDatasetDirs(Map<String, dynamic> meta) {
    final ddStr = meta['ss_dataset_dirs'];
    if (ddStr is! String) return null;
    try {
      return jsonDecode(ddStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static int _getImgCount(Map<String, dynamic>? datasetDirs, String dsName) {
    if (datasetDirs == null) return 0;
    final ds = datasetDirs[dsName];
    if (ds is! Map) return 0;
    final count = ds['img_count'];
    if (count is int) return count;
    if (count is String) return int.tryParse(count) ?? 0;
    return 0;
  }

  static void _extractFromFilename(String loraName, void Function(String, int, int) add) {
    var buf = loraName;
    final dotIdx = buf.indexOf('.safetensors');
    if (dotIdx >= 0) buf = buf.substring(0, dotIdx);

    while (true) {
      final lastUnder = buf.lastIndexOf('_');
      final lastDash = buf.lastIndexOf('-');
      final sep = lastUnder > lastDash ? lastUnder : lastDash;
      if (sep <= 0) break;

      final suffix = buf.substring(sep + 1);
      if (suffix.length < 2) break;

      bool isVersion = true;
      for (final c in suffix.codeUnits) {
        final isDigit = c >= 48 && c <= 57;
        final isHex = (c >= 65 && c <= 70) || (c >= 97 && c <= 102);
        final isVersionChar = c == 115 || c == 101 || c == 86 || c == 118; // s, e, V, v
        if (!isDigit && !isHex && !isVersionChar) {
          isVersion = false;
          break;
        }
      }

      if (isVersion && suffix.length <= 8) {
        buf = buf.substring(0, sep);
      } else {
        break;
      }
    }

    if (buf.isNotEmpty) add(buf, 0, 1);
  }

  static void _parseTagFrequency(Map<String, dynamic> meta, void Function(String, int, int) add) {
    final tfStr = meta['ss_tag_frequency'];
    if (tfStr is! String) return;

    Map<String, dynamic> tf;
    try {
      tf = jsonDecode(tfStr) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    _extractFromDatasetNames(tf, add);

    final datasetDirs = _parseDatasetDirs(meta);

    int maxCount = 0;
    for (final ds in tf.keys) {
      final tags = tf[ds];
      if (tags is! Map) continue;

      if (_isCaptionStyle(Map<String, dynamic>.from(tags))) {
        _extractCaptionTrigger(Map<String, dynamic>.from(tags), add);
        continue;
      }

      for (final countObj in tags.values) {
        int count = 0;
        if (countObj is int) {
          count = countObj;
        } else if (countObj is String) {
          count = int.tryParse(countObj) ?? 0;
        }
        if (count > maxCount) maxCount = count;
      }
    }

    for (final ds in tf.keys) {
      final tags = tf[ds];
      if (tags is! Map) continue;
      if (_isCaptionStyle(Map<String, dynamic>.from(tags))) continue;

      final imgCount = _getImgCount(datasetDirs, ds);
      final threshold = imgCount > 0 ? (imgCount * 0.7).toInt() : (maxCount * 0.6).toInt();

      for (final entry in tags.entries) {
        final tag = entry.key;
        int count = 0;
        final countObj = entry.value;
        if (countObj is int) {
          count = countObj;
        } else if (countObj is String) {
          count = int.tryParse(countObj) ?? 0;
        }
        if (count >= threshold && !_isGeneric(tag)) {
          add(tag, count, 2);
        }
      }
    }
  }

  static String toCommaString(List<TriggerWord> words) {
    return words.map((w) => w.word).join(', ');
  }
}

class _Word {
  String word;
  int count;
  int priority;

  _Word(this.word, this.count, this.priority);
}
