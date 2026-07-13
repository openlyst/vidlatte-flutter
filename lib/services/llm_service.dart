import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
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
    var result = await _openAiChatCompletion(
      server: server,
      model: model,
      messages: messages,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    // LM Studio returns 4xx from /v1/chat/completions when the requested model
    // is not loaded. Its native /api/v1/models/load endpoint loads it on demand.
    if (!result.success) {
      final error = result.error ?? '';
      final statusCode = _parseStatusCode(error);
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        debugPrint('[LlmService] OpenAI-compatible chat failed with HTTP $statusCode, trying LM Studio /api/v1/models/load');
        try {
          await _loadLlmStudioModel(server, model);
          debugPrint('[LlmService] LM Studio model load succeeded, retrying chat');
          result = await _openAiChatCompletion(
            server: server,
            model: model,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens,
          );
        } catch (e) {
          debugPrint('[LlmService] LM Studio model load fallback failed: $e');
          // Keep the original OpenAI-compatible error.
        }
      }
    }

    return result;
  }

  Future<LlmChatResult> _openAiChatCompletion({
    required LlmServer server,
    required String model,
    required List<LlmChatMessage> messages,
    required double temperature,
    required int maxTokens,
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
      final status = e.response?.statusCode;
      final body = e.response?.data?.toString() ?? 'no body';
      return LlmChatResult(
        success: false,
        error: 'HTTP $status: ${e.message}. Response: $body',
      );
    } catch (e) {
      return LlmChatResult(success: false, error: e.toString());
    }
  }

  int? _parseStatusCode(String error) {
    final match = RegExp(r'HTTP (\d+)').firstMatch(error);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  Future<void> _loadLlmStudioModel(LlmServer server, String model) async {
    final url = server.url.replaceAll(RegExp(r'/+$'), '');
    await _dio.post(
      '$url/api/v1/models/load',
      options: Options(headers: _headers(server)),
      data: {
        'model': model,
        'context_length': 4096,
      },
    );
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
