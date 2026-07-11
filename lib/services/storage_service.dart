import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/constants.dart';
import '../data/models/app_settings.dart';
import '../data/models/collection.dart';
import '../data/models/comfy_server.dart';
import '../data/models/generated_image.dart';
import '../data/models/llm_server.dart';
import '../data/models/lora_metadata.dart';
import '../data/models/studio_session.dart';

class StorageService {
  late Box _serversBox;
  late Box _imagesBox;
  late Box _collectionsBox;
  late Box _settingsBox;
  late Box _sessionsBox;
  late Box _llmServersBox;
  late Box _loraMetaBox;
  late Directory _imageDir;

  Future<void> init() async {
    await Hive.initFlutter();

    _serversBox = await Hive.openBox(StorageKeys.servers);
    _imagesBox = await Hive.openBox(StorageKeys.images);
    _collectionsBox = await Hive.openBox(StorageKeys.collections);
    _settingsBox = await Hive.openBox(StorageKeys.settings);
    _sessionsBox = await Hive.openBox('sessions');
    _llmServersBox = await Hive.openBox('llm_servers');
    _loraMetaBox = await Hive.openBox('lora_metadata');

    final appDir = await getApplicationDocumentsDirectory();
    _imageDir = Directory(p.join(appDir.path, 'vidlatte_images'));
    if (!_imageDir.existsSync()) {
      await _imageDir.create(recursive: true);
    }
  }

  // --- Servers ---

  List<ComfyServer> getServers() {
    return _serversBox.values.map((v) {
      final json = jsonDecode(v as String) as Map<String, dynamic>;
      return ComfyServer.fromJson(json);
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> saveServer(ComfyServer server) async {
    await _serversBox.put(server.id, jsonEncode(server.toJson()));
  }

  Future<void> deleteServer(String id) async {
    await _serversBox.delete(id);
  }

  ComfyServer? getDefaultServer() {
    final servers = getServers();
    try {
      return servers.firstWhere((s) => s.isDefault);
    } catch (_) {
      return servers.isNotEmpty ? servers.first : null;
    }
  }

  Future<void> setDefaultServer(String id) async {
    final servers = getServers();
    for (final server in servers) {
      final updated = server.copyWith(isDefault: server.id == id);
      await _serversBox.put(server.id, jsonEncode(updated.toJson()));
    }
  }

  ComfyServer? getServer(String id) {
    final raw = _serversBox.get(id);
    if (raw == null) return null;
    final json = jsonDecode(raw as String) as Map<String, dynamic>;
    return ComfyServer.fromJson(json);
  }

  // --- Images ---

  List<GeneratedImage> getImages() {
    return _imagesBox.values.map((v) {
      final json = jsonDecode(v as String) as Map<String, dynamic>;
      return GeneratedImage.fromJson(json);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<GeneratedImage> getFavoriteImages() {
    return getImages().where((img) => img.isFavorite).toList();
  }

  List<GeneratedImage> getImagesByCollection(String collectionId) {
    return getImages().where((img) => img.collectionId == collectionId).toList();
  }

  Future<void> saveImage(GeneratedImage image) async {
    await _imagesBox.put(image.id, jsonEncode(image.toJson()));
  }

  Future<void> deleteImage(String id) async {
    final image = getImage(id);
    if (image?.localPath != null) {
      final file = File(image!.localPath!);
      if (file.existsSync()) await file.delete();
    }
    await _imagesBox.delete(id);
  }

  GeneratedImage? getImage(String id) {
    final raw = _imagesBox.get(id);
    if (raw == null) return null;
    final json = jsonDecode(raw as String) as Map<String, dynamic>;
    return GeneratedImage.fromJson(json);
  }

  Future<void> toggleFavorite(String id) async {
    final image = getImage(id);
    if (image == null) return;
    await saveImage(image.copyWith(isFavorite: !image.isFavorite));
  }

  Future<void> toggleHidden(String id) async {
    final image = getImage(id);
    if (image == null) return;
    await saveImage(image.copyWith(isHidden: !image.isHidden));
  }

  Future<void> setImageCollection(String imageId, String? collectionId) async {
    final image = getImage(imageId);
    if (image == null) return;
    await saveImage(image.copyWith(collectionId: collectionId));
  }

  // --- Image files ---

  Future<String> saveImageFile(Uint8List bytes, String filename) async {
    final path = p.join(_imageDir.path, filename);
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  Future<Uint8List?> readImageFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) return null;
    return file.readAsBytes();
  }

  // --- Collections ---

  List<Collection> getCollections() {
    return _collectionsBox.values.map((v) {
      final json = jsonDecode(v as String) as Map<String, dynamic>;
      return Collection.fromJson(json);
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> saveCollection(Collection collection) async {
    await _collectionsBox.put(collection.id, jsonEncode(collection.toJson()));
  }

  Future<void> deleteCollection(String id) async {
    await _collectionsBox.delete(id);
    final images = getImagesByCollection(id);
    for (final image in images) {
      await saveImage(image.copyWith(collectionId: null));
    }
  }

  // --- Settings ---

  AppSettings getSettings() {
    final raw = _settingsBox.get('app_settings');
    if (raw == null) return const AppSettings();
    final json = jsonDecode(raw as String) as Map<String, dynamic>;
    return AppSettings.fromJson(json);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('app_settings', jsonEncode(settings.toJson()));
  }

  // --- Studio Sessions ---

  List<StudioSession> getSessions() {
    return _sessionsBox.values.map((v) {
      final json = jsonDecode(v as String) as Map<String, dynamic>;
      return StudioSession.fromJson(json);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveSession(StudioSession session) async {
    await _sessionsBox.put(session.id, jsonEncode(session.toJson()));
  }

  Future<void> deleteSession(String id) async {
    await _sessionsBox.delete(id);
  }

  StudioSession? getSession(String id) {
    final raw = _sessionsBox.get(id);
    if (raw == null) return null;
    final json = jsonDecode(raw as String) as Map<String, dynamic>;
    return StudioSession.fromJson(json);
  }

  // --- Cleanup ---

  Future<void> clearAll() async {
    await _serversBox.clear();
    await _imagesBox.clear();
    await _collectionsBox.clear();
    await _settingsBox.clear();
    await _sessionsBox.clear();
    await _llmServersBox.clear();
    await _loraMetaBox.clear();
    if (_imageDir.existsSync()) {
      await _imageDir.delete(recursive: true);
      await _imageDir.create(recursive: true);
    }
  }

  // --- LLM Servers ---

  List<LlmServer> getLlmServers() {
    return _llmServersBox.values.map((v) {
      final json = jsonDecode(v as String) as Map<String, dynamic>;
      return LlmServer.fromJson(json);
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> saveLlmServer(LlmServer server) async {
    await _llmServersBox.put(server.id, jsonEncode(server.toJson()));
  }

  Future<void> deleteLlmServer(String id) async {
    await _llmServersBox.delete(id);
  }

  LlmServer? getLlmServer(String id) {
    final raw = _llmServersBox.get(id);
    if (raw == null) return null;
    final json = jsonDecode(raw as String) as Map<String, dynamic>;
    return LlmServer.fromJson(json);
  }

  // --- LoRA Metadata ---

  String _loraMetaKey(String serverId, String loraName) => '$serverId::$loraName';

  List<LoraMetadata> getAllLoraMetadata(String serverId) {
    final prefix = '$serverId::';
    return _loraMetaBox.keys
        .where((k) => (k as String).startsWith(prefix))
        .map((k) {
          final raw = _loraMetaBox.get(k);
          if (raw == null) return null;
          return LoraMetadata.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
        })
        .whereType<LoraMetadata>()
        .toList()
      ..sort((a, b) => a.loraName.compareTo(b.loraName));
  }

  LoraMetadata? getLoraMetadata(String serverId, String loraName) {
    final raw = _loraMetaBox.get(_loraMetaKey(serverId, loraName));
    if (raw == null) return null;
    return LoraMetadata.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
  }

  Future<void> saveLoraMetadata(LoraMetadata meta) async {
    await _loraMetaBox.put(
      _loraMetaKey(meta.serverId, meta.loraName),
      jsonEncode(meta.toJson()),
    );
  }

  Future<void> saveLoraMetadataBatch(String serverId, List<LoraMetadata> items) async {
    for (final meta in items) {
      await _loraMetaBox.put(
        _loraMetaKey(meta.serverId, meta.loraName),
        jsonEncode(meta.toJson()),
      );
    }
  }

  Future<void> deleteLoraMetadata(String serverId, String loraName) async {
    await _loraMetaBox.delete(_loraMetaKey(serverId, loraName));
  }

  Future<void> deleteAllLoraMetadata(String serverId) async {
    final prefix = '$serverId::';
    final keys = _loraMetaBox.keys.where((k) => (k as String).startsWith(prefix)).toList();
    await _loraMetaBox.deleteAll(keys);
  }

  Map<String, String> getLoraTriggerWords(String serverId) {
    final metas = getAllLoraMetadata(serverId);
    return {for (final m in metas) m.loraName: m.triggerWords};
  }

  Set<String> getDisabledLoras(String serverId) {
    return getAllLoraMetadata(serverId)
        .where((m) => !m.isEnabled)
        .map((m) => m.loraName)
        .toSet();
  }
}
