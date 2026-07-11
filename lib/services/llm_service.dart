import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';

import '../data/models/llm_model.dart';
import '../data/models/llm_server.dart';

class LlmService {
  final Dio _dio;

  LlmService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 120),
  ));

  String _baseUrl(LlmServer server) {
    var url = server.url.replaceAll(RegExp(r'/+$'), '');
    if (url.endsWith('/v1')) return url;
    return '$url/v1';
  }

  Map<String, String> _headers(LlmServer server) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (server.apiKey != null && server.apiKey!.isNotEmpty) {
      h['Authorization'] = 'Bearer ${server.apiKey}';
    }
    return h;
  }

  Future<bool> testConnection(LlmServer server) async {
    try {
      final resp = await _dio.get(
        '${_baseUrl(server)}/models',
        options: Options(headers: _headers(server)),
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<LlmModel>> getModels(LlmServer server) async {
    final resp = await _dio.get(
      '${_baseUrl(server)}/models',
      options: Options(headers: _headers(server)),
    );
    final data = resp.data['data'] as List? ?? [];
    return data
        .map((m) => LlmModel(
              identifier: m['id'] as String? ?? '',
              displayName: m['id'] as String? ?? '',
              isLoaded: true,
            ))
        .where((m) => m.identifier.isNotEmpty)
        .toList();
  }

  Future<LlmChatResult> chatCompletion({
    required LlmServer server,
    required String model,
    required List<LlmChatMessage> messages,
    double temperature = 0.7,
    int maxTokens = 4096,
  }) async {
    try {
      final resp = await _dio.post(
        '${_baseUrl(server)}/chat/completions',
        options: Options(headers: _headers(server)),
        data: {
          'model': model,
          'messages': messages.map((m) => m.toJson()).toList(),
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': false,
        },
      );
      final choices = resp.data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        return const LlmChatResult(success: false, error: 'No response from model');
      }
      final content = choices[0]['message']['content'] as String? ?? '';
      return LlmChatResult(success: true, content: content);
    } on DioException catch (e) {
      return LlmChatResult(
        success: false,
        error: e.message ?? e.error?.toString() ?? 'Request failed',
      );
    } catch (e) {
      return LlmChatResult(success: false, error: e.toString());
    }
  }

  Stream<String> chatCompletionStream({
    required LlmServer server,
    required String model,
    required List<LlmChatMessage> messages,
    double temperature = 0.7,
    int maxTokens = 4096,
  }) async* {
    final response = await _dio.post(
      '${_baseUrl(server)}/chat/completions',
      options: Options(
        headers: _headers(server),
        responseType: ResponseType.stream,
      ),
      data: {
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': true,
      },
    );

    final stream = response.data?.stream as Stream<List<int>>?;
    if (stream == null) return;

    final buffer = StringBuffer();
    await for (final chunk in stream) {
      buffer.write(utf8.decode(chunk));
      while (true) {
        final nl = buffer.toString().indexOf('\n');
        if (nl == -1) break;
        final line = buffer.toString().substring(0, nl).trim();
        buffer.clear();
        buffer.write(buffer.toString().substring(nl + 1));
        if (line.isEmpty) continue;
        if (line.startsWith('data: ')) {
          final payload = line.substring(6);
          if (payload == '[DONE]') return;
          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            final delta = json['choices']?[0]?['delta']?['content'] as String?;
            if (delta != null && delta.isNotEmpty) yield delta;
          } catch (_) {}
        }
      }
    }
  }
}
