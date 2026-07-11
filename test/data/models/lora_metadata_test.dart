import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/lora_metadata.dart';

void main() {
  group('LoraMetadata', () {
    final now = DateTime(2025, 7, 10);

    final meta = LoraMetadata(
      serverId: 's1',
      loraName: 'my_lora.safetensors',
      triggerWords: 'cat girl, anime style',
      isEnabled: true,
      updatedAt: now,
    );

    test('toJson serializes correctly', () {
      final json = meta.toJson();
      expect(json['serverId'], 's1');
      expect(json['loraName'], 'my_lora.safetensors');
      expect(json['triggerWords'], 'cat girl, anime style');
      expect(json['isEnabled'], true);
      expect(json['updatedAt'], now.toIso8601String());
    });

    test('fromJson deserializes correctly', () {
      final restored = LoraMetadata.fromJson(meta.toJson());
      expect(restored.serverId, meta.serverId);
      expect(restored.loraName, meta.loraName);
      expect(restored.triggerWords, meta.triggerWords);
      expect(restored.isEnabled, meta.isEnabled);
    });

    test('fromJson handles defaults', () {
      final json = {
        'serverId': 's1',
        'loraName': 'lora.safetensors',
      };
      final restored = LoraMetadata.fromJson(json);
      expect(restored.triggerWords, '');
      expect(restored.isEnabled, true);
    });

    test('displayName extracts filename from path', () {
      expect(meta.displayName, 'my_lora.safetensors');
      final nested = LoraMetadata(
        serverId: 's1',
        loraName: 'folder/subfolder/lora_v2.safetensors',
        updatedAt: now,
      );
      expect(nested.displayName, 'lora_v2.safetensors');
    });

    test('copyWith creates modified copy', () {
      final modified = meta.copyWith(triggerWords: 'new triggers', isEnabled: false);
      expect(modified.triggerWords, 'new triggers');
      expect(modified.isEnabled, false);
      expect(modified.loraName, meta.loraName);
      expect(modified.serverId, meta.serverId);
    });

    test('equality works', () {
      final copy = LoraMetadata(
        serverId: 's1',
        loraName: 'my_lora.safetensors',
        triggerWords: 'cat girl, anime style',
        isEnabled: true,
        updatedAt: now,
      );
      expect(copy, meta);
    });
  });
}
