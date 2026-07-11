import 'package:flutter_test/flutter_test.dart';
import 'package:vidlatte/data/models/llm_model.dart';
import 'package:vidlatte/data/models/llm_server.dart';

void main() {
  group('LlmServer', () {
    final now = DateTime(2025, 1, 1);
    final server = LlmServer(
      id: 'llm-1',
      name: 'My LLM',
      url: 'http://127.0.0.1:1234',
      apiKey: 'secret-key',
      defaultModel: 'llama-3-8b',
      isEnabled: true,
      createdAt: now,
    );

    test('toJson serializes correctly', () {
      final json = server.toJson();
      expect(json['id'], 'llm-1');
      expect(json['name'], 'My LLM');
      expect(json['url'], 'http://127.0.0.1:1234');
      expect(json['apiKey'], 'secret-key');
      expect(json['defaultModel'], 'llama-3-8b');
      expect(json['isEnabled'], true);
      expect(json['createdAt'], now.toIso8601String());
    });

    test('fromJson deserializes correctly', () {
      final restored = LlmServer.fromJson(server.toJson());
      expect(restored.id, server.id);
      expect(restored.name, server.name);
      expect(restored.url, server.url);
      expect(restored.apiKey, server.apiKey);
      expect(restored.defaultModel, server.defaultModel);
      expect(restored.isEnabled, server.isEnabled);
    });

    test('copyWith creates modified copy', () {
      final modified = server.copyWith(name: 'New Name', isEnabled: false);
      expect(modified.name, 'New Name');
      expect(modified.isEnabled, false);
      expect(modified.url, server.url);
      expect(modified.id, server.id);
    });

    test('copyWith can set nullable fields to null', () {
      final modified = server.copyWith(apiKey: null, defaultModel: null);
      expect(modified.apiKey, isNull);
      expect(modified.defaultModel, isNull);
    });

    test('fromJson handles defaults', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'url': 'http://localhost',
        'createdAt': now.toIso8601String(),
      };
      final restored = LlmServer.fromJson(json);
      expect(restored.apiKey, isNull);
      expect(restored.defaultModel, isNull);
      expect(restored.isEnabled, true);
    });

    test('equality works', () {
      final copy = LlmServer(
        id: 'llm-1',
        name: 'My LLM',
        url: 'http://127.0.0.1:1234',
        apiKey: 'secret-key',
        defaultModel: 'llama-3-8b',
        isEnabled: true,
        createdAt: now,
      );
      expect(copy, server);
    });
  });

  group('LlmModel', () {
    test('fromJson parses correctly', () {
      final model = LlmModel.fromJson({
        'id': 'llama-3-8b',
        'displayName': 'Llama 3 8B',
        'isLoaded': true,
      });
      expect(model.identifier, 'llama-3-8b');
      expect(model.displayName, 'Llama 3 8B');
      expect(model.isLoaded, true);
    });

    test('fromJson handles missing fields with defaults', () {
      final model = LlmModel.fromJson({});
      expect(model.identifier, '');
      expect(model.displayName, '');
      expect(model.isLoaded, false);
    });

    test('fromJson uses identifier as fallback for displayName', () {
      final model = LlmModel.fromJson({'id': 'test-model'});
      expect(model.identifier, 'test-model');
      expect(model.displayName, 'test-model');
    });
  });

  group('LlmChatMessage', () {
    test('system factory creates correct role', () {
      final msg = LlmChatMessage.system('You are helpful');
      expect(msg.role, 'system');
      expect(msg.content, 'You are helpful');
    });

    test('user factory creates correct role', () {
      final msg = LlmChatMessage.user('Hello');
      expect(msg.role, 'user');
      expect(msg.content, 'Hello');
    });

    test('assistant factory creates correct role', () {
      final msg = LlmChatMessage.assistant('Hi there');
      expect(msg.role, 'assistant');
      expect(msg.content, 'Hi there');
    });

    test('toJson serializes correctly', () {
      final msg = LlmChatMessage.user('test');
      expect(msg.toJson(), {'role': 'user', 'content': 'test'});
    });
  });

  group('LlmChatResult', () {
    test('success result', () {
      const result = LlmChatResult(success: true, content: 'response');
      expect(result.success, true);
      expect(result.content, 'response');
      expect(result.error, isNull);
    });

    test('error result', () {
      const result = LlmChatResult(success: false, error: 'Connection failed');
      expect(result.success, false);
      expect(result.error, 'Connection failed');
      expect(result.content, '');
    });
  });
}
