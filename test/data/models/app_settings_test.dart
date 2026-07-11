import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('default values are correct', () {
      const settings = AppSettings();
      expect(settings.themeMode, 'system');
      expect(settings.defaultServerId, isNull);
      expect(settings.lastModel, '');
      expect(settings.lastLoras, isEmpty);
      expect(settings.lastCreativity, 'normal');
      expect(settings.saveToGallery, true);
      expect(settings.downloadLocally, true);
    });

    test('toJson serializes correctly', () {
      const settings = AppSettings(
        themeMode: 'dark',
        defaultServerId: 'server-1',
        lastModel: 'model.safetensors',
        lastLoras: ['lora1'],
        lastCreativity: 'high',
        saveToGallery: false,
      );
      final json = settings.toJson();
      expect(json['themeMode'], 'dark');
      expect(json['defaultServerId'], 'server-1');
      expect(json['lastModel'], 'model.safetensors');
      expect(json['lastLoras'], ['lora1']);
      expect(json['lastCreativity'], 'high');
      expect(json['saveToGallery'], false);
    });

    test('fromJson deserializes correctly', () {
      const settings = AppSettings(
        themeMode: 'light',
        lastModel: 'test',
        lastLoras: ['a', 'b'],
      );
      final restored = AppSettings.fromJson(settings.toJson());
      expect(restored.themeMode, 'light');
      expect(restored.lastModel, 'test');
      expect(restored.lastLoras, ['a', 'b']);
    });

    test('copyWith creates modified copy', () {
      const settings = AppSettings();
      final modified = settings.copyWith(themeMode: 'dark', lastModel: 'new');
      expect(modified.themeMode, 'dark');
      expect(modified.lastModel, 'new');
      expect(modified.saveToGallery, true);
    });
  });
}
