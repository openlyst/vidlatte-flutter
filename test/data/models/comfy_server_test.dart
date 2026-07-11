import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/comfy_server.dart';

void main() {
  group('Creativity', () {
    test('cfgScale returns correct values', () {
      expect(Creativity.low.cfgScale, 11);
      expect(Creativity.normal.cfgScale, 7);
      expect(Creativity.high.cfgScale, 4);
      expect(Creativity.max.cfgScale, 1.5);
    });

    test('label returns human-readable names', () {
      expect(Creativity.low.label, 'Low');
      expect(Creativity.normal.label, 'Normal');
      expect(Creativity.high.label, 'High');
      expect(Creativity.max.label, 'Max');
    });
  });

  group('ComfyServer', () {
    final now = DateTime(2025, 1, 1);
    final server = ComfyServer(
      id: 'test-id',
      name: 'My Server',
      url: 'http://127.0.0.1:8188',
      maxLoras: 3,
      steps: 30,
      hiresFix: true,
      isDefault: true,
      createdAt: now,
    );

    test('toJson serializes correctly', () {
      final json = server.toJson();
      expect(json['id'], 'test-id');
      expect(json['name'], 'My Server');
      expect(json['url'], 'http://127.0.0.1:8188');
      expect(json['maxLoras'], 3);
      expect(json['steps'], 30);
      expect(json['hiresFix'], true);
      expect(json['isDefault'], true);
      expect(json['createdAt'], now.toIso8601String());
    });

    test('fromJson deserializes correctly', () {
      final json = server.toJson();
      final restored = ComfyServer.fromJson(json);
      expect(restored.id, server.id);
      expect(restored.name, server.name);
      expect(restored.url, server.url);
      expect(restored.maxLoras, server.maxLoras);
      expect(restored.steps, server.steps);
      expect(restored.hiresFix, server.hiresFix);
      expect(restored.isDefault, server.isDefault);
    });

    test('copyWith creates modified copy', () {
      final modified = server.copyWith(name: 'New Name', steps: 50);
      expect(modified.name, 'New Name');
      expect(modified.steps, 50);
      expect(modified.url, server.url);
      expect(modified.id, server.id);
    });

    test('equality works correctly', () {
      final copy = ComfyServer(
        id: 'test-id',
        name: 'My Server',
        url: 'http://127.0.0.1:8188',
        maxLoras: 3,
        steps: 30,
        hiresFix: true,
        isDefault: true,
        createdAt: now,
      );
      expect(copy, server);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'url': 'http://localhost',
        'createdAt': now.toIso8601String(),
      };
      final restored = ComfyServer.fromJson(json);
      expect(restored.maxLoras, 5);
      expect(restored.steps, 20);
      expect(restored.hiresFix, false);
      expect(restored.isDefault, false);
    });
  });
}
