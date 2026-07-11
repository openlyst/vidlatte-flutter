import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/collection.dart';

void main() {
  group('Collection', () {
    final now = DateTime(2025, 1, 1);
    final collection = Collection(
      id: 'col-1',
      name: 'My Collection',
      description: 'Best images',
      createdAt: now,
      updatedAt: now,
    );

    test('toJson serializes correctly', () {
      final json = collection.toJson();
      expect(json['id'], 'col-1');
      expect(json['name'], 'My Collection');
      expect(json['description'], 'Best images');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['updatedAt'], now.toIso8601String());
    });

    test('fromJson deserializes correctly', () {
      final restored = Collection.fromJson(collection.toJson());
      expect(restored.id, collection.id);
      expect(restored.name, collection.name);
      expect(restored.description, collection.description);
    });

    test('copyWith creates modified copy', () {
      final modified = collection.copyWith(name: 'New Name');
      expect(modified.name, 'New Name');
      expect(modified.id, collection.id);
    });
  });
}
