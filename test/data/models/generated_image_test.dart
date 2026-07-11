import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/comfy_server.dart';
import 'package:vidlatte/data/models/generated_image.dart';

void main() {
  group('ImageStatus', () {
    test('name returns correct string', () {
      expect(ImageStatus.pending.name, 'pending');
      expect(ImageStatus.processing.name, 'processing');
      expect(ImageStatus.completed.name, 'completed');
      expect(ImageStatus.failed.name, 'failed');
    });

    test('fromString parses correctly', () {
      expect(ImageStatusExtension.fromString('pending'), ImageStatus.pending);
      expect(ImageStatusExtension.fromString('processing'), ImageStatus.processing);
      expect(ImageStatusExtension.fromString('completed'), ImageStatus.completed);
      expect(ImageStatusExtension.fromString('failed'), ImageStatus.failed);
      expect(ImageStatusExtension.fromString('unknown'), ImageStatus.pending);
    });
  });

  group('GeneratedImage', () {
    final now = DateTime(2025, 1, 1);
    final image = GeneratedImage(
      id: 'img-1',
      prompt: 'a cat',
      model: 'sd_xl.safetensors',
      loras: ['lora1.safetensors', 'lora2.safetensors'],
      creativity: Creativity.high,
      steps: 30,
      hiresFix: true,
      width: 768,
      height: 1024,
      seed: 42,
      status: ImageStatus.completed,
      localPath: '/path/to/image.png',
      serverUrl: 'http://127.0.0.1:8188',
      isFavorite: true,
      createdAt: now,
      completedAt: now.add(const Duration(seconds: 10)),
    );

    test('toJson serializes correctly', () {
      final json = image.toJson();
      expect(json['id'], 'img-1');
      expect(json['prompt'], 'a cat');
      expect(json['model'], 'sd_xl.safetensors');
      expect(json['loras'], ['lora1.safetensors', 'lora2.safetensors']);
      expect(json['creativity'], 'high');
      expect(json['steps'], 30);
      expect(json['hiresFix'], true);
      expect(json['width'], 768);
      expect(json['height'], 1024);
      expect(json['seed'], 42);
      expect(json['status'], 'completed');
      expect(json['localPath'], '/path/to/image.png');
      expect(json['isFavorite'], true);
    });

    test('fromJson deserializes correctly', () {
      final json = image.toJson();
      final restored = GeneratedImage.fromJson(json);
      expect(restored.id, image.id);
      expect(restored.prompt, image.prompt);
      expect(restored.model, image.model);
      expect(restored.loras, image.loras);
      expect(restored.creativity, image.creativity);
      expect(restored.steps, image.steps);
      expect(restored.hiresFix, image.hiresFix);
      expect(restored.width, image.width);
      expect(restored.height, image.height);
      expect(restored.seed, image.seed);
      expect(restored.status, image.status);
      expect(restored.localPath, image.localPath);
      expect(restored.isFavorite, image.isFavorite);
    });

    test('copyWith creates modified copy', () {
      final modified = image.copyWith(
        isFavorite: false,
        status: ImageStatus.failed,
        errorMessage: 'OOM',
      );
      expect(modified.isFavorite, false);
      expect(modified.status, ImageStatus.failed);
      expect(modified.errorMessage, 'OOM');
      expect(modified.prompt, image.prompt);
      expect(modified.id, image.id);
    });

    test('fromJson handles defaults for missing fields', () {
      final json = {
        'id': 'test',
        'prompt': 'test',
        'model': 'test',
        'createdAt': now.toIso8601String(),
      };
      final restored = GeneratedImage.fromJson(json);
      expect(restored.loras, isEmpty);
      expect(restored.creativity, Creativity.normal);
      expect(restored.status, ImageStatus.pending);
      expect(restored.isFavorite, false);
      expect(restored.width, 1024);
      expect(restored.height, 1024);
    });

    test('equality works correctly', () {
      final copy = GeneratedImage(
        id: 'img-1',
        prompt: 'a cat',
        model: 'sd_xl.safetensors',
        loras: ['lora1.safetensors', 'lora2.safetensors'],
        creativity: Creativity.high,
        steps: 30,
        hiresFix: true,
        width: 768,
        height: 1024,
        seed: 42,
        status: ImageStatus.completed,
        localPath: '/path/to/image.png',
        serverUrl: 'http://127.0.0.1:8188',
        isFavorite: true,
        createdAt: now,
        completedAt: now.add(const Duration(seconds: 10)),
      );
      expect(copy, image);
    });
  });
}
