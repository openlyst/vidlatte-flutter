import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/comfy_server.dart';
import 'package:vidlatte/data/models/generated_image.dart';
import 'package:vidlatte/data/models/studio_session.dart';

void main() {
  group('StudioSession', () {
    final now = DateTime(2025, 1, 1);
    final image = GeneratedImage(
      id: 'img-1',
      prompt: 'test',
      model: 'model.safetensors',
      createdAt: now,
    );
    final session = StudioSession(
      id: 'sess-1',
      title: 'My Project',
      prompt: 'a beautiful landscape',
      model: 'sd_xl.safetensors',
      loras: ['lora1'],
      images: [image],
      createdAt: now,
      updatedAt: now,
    );

    test('toJson serializes correctly', () {
      final json = session.toJson();
      expect(json['id'], 'sess-1');
      expect(json['title'], 'My Project');
      expect(json['prompt'], 'a beautiful landscape');
      expect(json['model'], 'sd_xl.safetensors');
      expect(json['loras'], ['lora1']);
      expect((json['images'] as List).length, 1);
    });

    test('fromJson deserializes correctly', () {
      final restored = StudioSession.fromJson(session.toJson());
      expect(restored.id, session.id);
      expect(restored.title, session.title);
      expect(restored.prompt, session.prompt);
      expect(restored.model, session.model);
      expect(restored.loras, session.loras);
      expect(restored.images.length, 1);
      expect(restored.images.first.id, image.id);
    });

    test('copyWith creates modified copy', () {
      final modified = session.copyWith(title: 'New Title');
      expect(modified.title, 'New Title');
      expect(modified.id, session.id);
    });

    test('fromJson handles defaults', () {
      final json = {
        'id': 'test',
        'title': 'Test',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      final restored = StudioSession.fromJson(json);
      expect(restored.prompt, '');
      expect(restored.model, '');
      expect(restored.loras, isEmpty);
      expect(restored.images, isEmpty);
    });
  });
}
