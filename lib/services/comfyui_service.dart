import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/constants.dart';
import '../data/models/comfy_server.dart';
import '../data/models/model_catalog.dart';
import 'comfy_workflow.dart';

class ComfyApiException implements Exception {
  final String message;
  final int? statusCode;

  ComfyApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ComfyApiException: $message';
}

class PreviewMessage {
  final String type;
  final String? promptId;
  final String? node;
  final int? progressValue;
  final int? progressMax;
  final Uint8List? previewBytes;
  final String? error;

  const PreviewMessage({
    required this.type,
    this.promptId,
    this.node,
    this.progressValue,
    this.progressMax,
    this.previewBytes,
    this.error,
  });
}

class ComfyJobResult {
  final bool success;
  final String? filename;
  final String? subfolder;
  final String? type;
  final Uint8List? imageBytes;
  final String? error;

  const ComfyJobResult({
    required this.success,
    this.filename,
    this.subfolder,
    this.type,
    this.imageBytes,
    this.error,
  });
}

class ComfyService {
  final Dio _dio;

  ComfyService({Dio? dio}) : _dio = dio ?? Dio();

  String _normalizeUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Options _authOptions(ComfyServer server, {Map<String, dynamic>? headers, ResponseType? responseType, Duration? sendTimeout, Duration? receiveTimeout}) {
    final authHeaders = server.authHeaders();
    final mergedHeaders = <String, dynamic>{...authHeaders, ...?headers};
    return Options(
      headers: mergedHeaders.isNotEmpty ? mergedHeaders : null,
      responseType: responseType,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  Future<ServerHealth> checkHealth(ComfyServer server) async {
    final baseUrl = _normalizeUrl(server.url);
    try {
      final response = await _dio.get(
        '$baseUrl/system_stats',
        options: _authOptions(server,
          responseType: ResponseType.json,
          sendTimeout: const Duration(milliseconds: ComfyConstants.healthCheckTimeoutMs),
          receiveTimeout: const Duration(milliseconds: ComfyConstants.healthCheckTimeoutMs),
        ),
      );

      if (response.statusCode != 200) {
        return ServerHealth(
          serverId: server.id,
          healthy: false,
          error: 'HTTP ${response.statusCode}',
          checkedAt: DateTime.now(),
        );
      }

      final data = response.data as Map<String, dynamic>;
      final system = data['system'] as Map<String, dynamic>?;
      final devices = data['devices'] as List?;

      if (system == null || system['os'] == null || devices == null) {
        return ServerHealth(
          serverId: server.id,
          healthy: false,
          error: 'Invalid ComfyUI response',
          checkedAt: DateTime.now(),
        );
      }

      return ServerHealth(
        serverId: server.id,
        healthy: true,
        os: system['os'] as String?,
        pythonVersion: system['python_version'] as String?,
        ramTotal: system['ram_total'] as int?,
        ramFree: system['ram_free'] as int?,
        devices: devices.map((e) => e.toString()).toList(),
        checkedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      return ServerHealth(
        serverId: server.id,
        healthy: false,
        error: e.message ?? 'Connection failed',
        checkedAt: DateTime.now(),
      );
    } catch (e) {
      return ServerHealth(
        serverId: server.id,
        healthy: false,
        error: e.toString(),
        checkedAt: DateTime.now(),
      );
    }
  }

  Future<ModelCatalog> getModels(ComfyServer server) async {
    final baseUrl = _normalizeUrl(server.url);
    try {
      final responses = await Future.wait([
        _dio.get('$baseUrl/object_info/CheckpointLoaderSimple',
            options: _authOptions(server, responseType: ResponseType.json)),
        _dio.get('$baseUrl/object_info/LoraLoader',
            options: _authOptions(server, responseType: ResponseType.json)),
      ]);

      final modelsJson = responses[0].data as Map<String, dynamic>;
      final lorasJson = responses[1].data as Map<String, dynamic>;

      final models = (modelsJson['CheckpointLoaderSimple']
              as Map<String, dynamic>?)?['input'] as Map<String, dynamic>?;
      final modelList = (models?['required'] as Map<String, dynamic>?)?['ckpt_name'] as List?;
      final modelNames = modelList != null && modelList.isNotEmpty
          ? (modelList[0] as List).cast<String>()
          : <String>[];

      final loras = (lorasJson['LoraLoader']
              as Map<String, dynamic>?)?['input'] as Map<String, dynamic>?;
      final loraList = (loras?['required'] as Map<String, dynamic>?)?['lora_name'] as List?;
      final loraNames = loraList != null && loraList.isNotEmpty
          ? (loraList[0] as List).cast<String>()
          : <String>[];

      return ModelCatalog(
        serverId: server.id,
        models: modelNames,
        loras: loraNames,
        maxLoras: server.maxLoras,
        fetchedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw ComfyApiException('Failed to fetch models: ${e.message}');
    } catch (e) {
      throw ComfyApiException('Failed to fetch models: $e');
    }
  }

  Future<Map<String, dynamic>?> getLoraMetadata(ComfyServer server, String loraName) async {
    final baseUrl = _normalizeUrl(server.url);
    final filename = loraName.split('/').last;
    try {
      final response = await _dio.get(
        '$baseUrl/view_metadata/loras',
        queryParameters: {'filename': filename},
        options: _authOptions(server, responseType: ResponseType.json),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ComfyApiException('Failed to fetch LoRA metadata: ${e.message}');
    } catch (e) {
      throw ComfyApiException('Failed to fetch LoRA metadata: $e');
    }
  }

  Future<String> submitWorkflow(ComfyServer server, Map<String, dynamic> workflow) async {
    final baseUrl = _normalizeUrl(server.url);
    try {
      final response = await _dio.post(
        '$baseUrl/prompt',
        data: jsonEncode({'prompt': workflow}),
        options: _authOptions(server,
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode != 200) {
        throw ComfyApiException('Submit failed: HTTP ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;
      final promptId = data['prompt_id'] as String?;
      if (promptId == null) {
        throw ComfyApiException('No prompt_id in response');
      }
      return promptId;
    } on DioException catch (e) {
      throw ComfyApiException('Submit failed: ${e.message}');
    }
  }

  Future<ComfyJobResult> pollForResult(
    ComfyServer server,
    String promptId, {
    void Function(PreviewMessage)? onPreview,
    int? maxAttempts,
  }) async {
    final baseUrl = _normalizeUrl(server.url);
    final attempts = maxAttempts ?? ComfyConstants.maxPollAttempts;

    WebSocketChannel? ws;
    if (onPreview != null) {
      ws = _connectWebSocket(baseUrl, promptId, onPreview, server);
    }

    try {
      for (var i = 0; i < attempts; i++) {
        await Future.delayed(Duration(milliseconds: ComfyConstants.pollIntervalMs));

        try {
          final historyRes = await _dio.get(
            '$baseUrl/history/$promptId',
            options: _authOptions(server, responseType: ResponseType.json),
          );

          if (historyRes.statusCode != 200) continue;

          final history = historyRes.data as Map<String, dynamic>;
          final entry = history[promptId] as Map<String, dynamic>?;
          if (entry == null) continue;

          final outputs = entry['outputs'] as Map<String, dynamic>?;
          if (outputs == null) continue;

          for (final output in outputs.values) {
            final outputMap = output as Map<String, dynamic>;
            final images = outputMap['images'] as List?;
            if (images == null || images.isEmpty) continue;

            final image = images[0] as Map<String, dynamic>;
            final filename = image['filename'] as String;
            final subfolder = image['subfolder'] as String? ?? '';
            final type = image['type'] as String? ?? 'output';

            onPreview?.call(PreviewMessage(type: 'complete', promptId: promptId));

            final imageUrl =
                '$baseUrl/view?filename=${Uri.encodeComponent(filename)}&subfolder=${Uri.encodeComponent(subfolder)}&type=${Uri.encodeComponent(type)}';
            final imageRes = await _dio.get(
              imageUrl,
              options: _authOptions(server, responseType: ResponseType.bytes),
            );

            if (imageRes.statusCode != 200) {
              return ComfyJobResult(
                success: false,
                error: 'Failed to download image',
              );
            }

            return ComfyJobResult(
              success: true,
              filename: filename,
              subfolder: subfolder,
              type: type,
              imageBytes: Uint8List.fromList(imageRes.data as List<int>),
            );
          }
        } catch (e) {
          continue;
        }
      }

      return const ComfyJobResult(success: false, error: 'Job timed out');
    } finally {
      await ws?.sink.close();
    }
  }

  Future<ComfyJobResult> generateImage(
    ComfyServer server, {
    required String prompt,
    required String model,
    String negativePrompt = '',
    List<String> loras = const [],
    Map<String, double> loraWeights = const {},
    Creativity creativity = Creativity.normal,
    double? cfg,
    int? steps,
    bool? hiresFix,
    int width = ComfyConstants.defaultWidth,
    int height = ComfyConstants.defaultHeight,
    int? seed,
    String? refImageFilename,
    String? refImageSubfolder,
    String? refImageType,
    double denoise = 0.5,
    void Function(PreviewMessage)? onPreview,
  }) async {
    final actualSteps = steps ?? server.steps;
    final actualHiresFix = hiresFix ?? server.hiresFix;

    var workflow = ComfyWorkflow.generate(WorkflowInputs(
      prompt: prompt,
      negativePrompt: negativePrompt,
      model: model,
      loras: loras,
      loraWeights: loraWeights,
      creativity: creativity,
      cfg: cfg,
      steps: actualSteps,
      width: width,
      height: height,
      seed: seed,
      refImageFilename: refImageFilename,
      refImageSubfolder: refImageSubfolder,
      refImageType: refImageType,
      denoise: denoise,
    ));

    if (actualHiresFix) {
      workflow = ComfyWorkflow.addHiresFix(
        workflow,
        ComfyConstants.hiresFixScale,
        ComfyConstants.hiresFixSteps,
      );
    }

    final promptId = await submitWorkflow(server, workflow);
    return pollForResult(server, promptId, onPreview: onPreview);
  }

  Future<Uint8List> getImage(
    ComfyServer server,
    String filename,
    String subfolder,
    String type,
  ) async {
    final baseUrl = _normalizeUrl(server.url);
    final imageUrl =
        '$baseUrl/view?filename=${Uri.encodeComponent(filename)}&subfolder=${Uri.encodeComponent(subfolder)}&type=${Uri.encodeComponent(type)}';
    final response = await _dio.get(
      imageUrl,
      options: _authOptions(server, responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }

  Future<({String filename, String subfolder, String type})> uploadImage(
    ComfyServer server,
    Uint8List bytes,
    String filename,
  ) async {
    final baseUrl = _normalizeUrl(server.url);
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(
      '$baseUrl/upload/image',
      data: formData,
      options: _authOptions(server, responseType: ResponseType.json),
    );
    if (response.statusCode != 200) {
      throw ComfyApiException('Upload failed: HTTP ${response.statusCode}');
    }
    final data = response.data as Map<String, dynamic>;
    return (
      filename: data['name'] as String,
      subfolder: data['subfolder'] as String? ?? '',
      type: data['type'] as String? ?? 'input',
    );
  }

  WebSocketChannel _connectWebSocket(
    String baseUrl,
    String promptId,
    void Function(PreviewMessage) onPreview,
    ComfyServer server,
  ) {
    var wsUrl = '${baseUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws';
    if (server.authType == ServerAuthType.basic &&
        server.authUsername != null &&
        server.authPassword != null) {
      wsUrl = wsUrl.replaceFirst('://', '://${Uri.encodeComponent(server.authUsername!)}:${Uri.encodeComponent(server.authPassword!)}@');
    } else if (server.authType == ServerAuthType.bearer && server.authToken != null) {
      wsUrl = '$wsUrl?token=${Uri.encodeComponent(server.authToken!)}';
    }
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    channel.stream.listen(
      (data) {
        if (data is String) {
          try {
            final msg = jsonDecode(data) as Map<String, dynamic>;
            final type = msg['type'] as String? ?? '';
            final msgData = msg['data'] as Map<String, dynamic>?;

            switch (type) {
              case 'execution_start':
                onPreview(PreviewMessage(
                  type: 'executing',
                  promptId: msgData?['prompt_id'] as String?,
                ));
              case 'executing':
                onPreview(PreviewMessage(
                  type: 'executing',
                  node: msgData?['node']?.toString(),
                  promptId: msgData?['prompt_id'] as String?,
                ));
              case 'progress':
                onPreview(PreviewMessage(
                  type: 'progress',
                  progressValue: msgData?['value'] as int?,
                  progressMax: msgData?['max'] as int?,
                ));
              case 'executed':
                onPreview(PreviewMessage(
                  type: 'executed',
                  node: msgData?['node']?.toString(),
                ));
            }
          } catch (_) {}
        }
      },
      onError: (e) {
        onPreview(PreviewMessage(type: 'error', error: e.toString()));
      },
    );

    return channel;
  }

  void dispose() {
    _dio.close();
  }
}
