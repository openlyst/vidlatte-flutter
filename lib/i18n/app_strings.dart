import 'package:flutter/material.dart';

abstract class AppStrings {
  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  // App
  String get appName;

  // Nav
  String get create;
  String get gallery;
  String get studio;
  String get settings;
  String get browse;

  // Common
  String get cancel;
  String get delete;
  String get save;
  String get edit;
  String get add;
  String get done;
  String get retry;
  String get remove;
  String get required_;
  String get loading;
  String get search;
  String get select;
  String get new_;
  String get close;
  String get stop;
  String get start;
  String get back;
  String get rename;
  String get confirm;
  String get yes;
  String get no;
  String get none;
  String get default_;
  String get status;
  String get healthy;
  String get unhealthy;
  String get error;
  String get models;
  String get os;
  String get python;
  String get ram;
  String get enabled;
  String get test;
  String get fetchModels;
  String get setDefault;
  String get healthCheck;
  String get name;
  String get url;
  String get invalidUrl;
  String get authType;
  String get authNone;
  String get authBasic;
  String get authBearer;
  String get username;
  String get authPassword;
  String get authToken;

  // Negative prompt
  String get negativePrompt;
  String get negativePromptHint;

  // LoRA weights
  String get loraWeight;

  // img2img
  String get img2img;
  String get txt2img;
  String get selectRefImage;
  String get refImageHint;
  String get denoiseStrength;
  String get denoiseHint;
  String get uploadImage;
  String get pickFromGallery;
  String get noRefImage;
  String get removeRefImage;

  // Face restore + upscale
  String get faceRestore;
  String get faceRestoreStrength;
  String get useCodeFormer;
  String get upscaleImage;
  String get upscaleModel;
  String get upscaleScale;
  String get processing;
  String get processingMsg;
  String get faceRestoreDone;
  String get faceRestoreFailed;
  String get upscaleDone;
  String get upscaleFailed;
  String get noUpscaleModels;

  // Inpainting
  String get inpaint;
  String get inpaintHint;
  String get brushSize;
  String get clearMask;
  String get maskEraser;
  String get inpaintDenoise;
  String get inpaintDenoiseHint;
  String get noInpaintImage;
  String get selectInpaintImage;

  // ControlNet
  String get controlnet;
  String get controlnetHint;
  String get controlnetModel;
  String get controlnetStrength;
  String get controlImage;
  String get noControlnetModels;
  String get selectControlImage;

  // Create page
  String get createTitle;
  String get autoImageTitle;
  String get browseModelsLoras;
  String get autoImageTooltip;
  String get backToCreate;
  String get generate;
  String get addToQueue;
  String get results;
  String get noImagesYet;
  String get noImagesYetMsg;
  String get noComfyServer;
  String get noComfyServerMsg;
  String get enterPrompt;
  String get selectModel;
  String get modelNotAvailable;
  String modelNotAvailableRaw(String model, String server);
  String get queue;
  String get describeImage;
  String get model;
  String get server;
  String get selectServer;
  String get selectModelHint;
  String get loadingModels;
  String get loras;
  String get noLorasSelected;
  String get creativityCfg;
  String get advanced;
  String get customCfg;
  String get customCfgSubtitleOn;
  String get customCfgSubtitleOff;
  String get cfgScale;
  String get hiresFix;
  String get hiresFixSubtitle;
  String get dimensions;
  String get steps;
  String get stepsWithDefault;

  // Auto Image
  String get autoImageSubtitle;
  String get generationMode;
  String get auto;
  String get variation;
  String get topicOptional;
  String get topicHint;
  String get leaveEmptyRandom;
  String get basePrompt;
  String get basePromptHint;
  String get variationDesc;
  String get mustIncludeTags;
  String get mustIncludeHint;
  String get maxImages;
  String get maxImagesHint;
  String get llmServer;
  String get llmModel;
  String get imageServer;
  String get imageModel;
  String get noLlmServersConfigured;
  String get noComfyServersConfigured;
  String get startGeneration;
  String get autoImageEmptyMsg;
  String get idle;
  String get generatingPrompt;
  String get generatingImage;
  String get waiting;
  String get paused;
  String get completed;
  String get currentPrompt;
  String get modelNotOnServer;
  String modelNotOnServerRaw(String model);

  // Gallery
  String get galleryTitle;
  String get galleryEmpty;
  String get galleryEmptyMsg;
  String get searchPromptModelLora;
  String get all;
  String get favorites;
  String get playlists;
  String get locked;
  String get unlocked;
  String get noResults;
  String get noResultsMsg;
  String get noHiddenImages;
  String get noHiddenImagesMsg;
  String get noPlaylists;
  String get noPlaylistsMsg;
  String get newPlaylist;
  String get playlistName;
  String get playlistNameHint;
  String get renamePlaylist;
  String get deletePlaylist;
  String get deletePlaylistConfirm;
  String deletePlaylistConfirmRaw(String name);
  String get deleteImage;
  String get deleteImageMsg;
  String get incorrectPassword;
  String get galleryLocked;
  String get galleryLockedMsg;
  String get password;
  String get unlock;
  String get noHiddenImagesPlural;
  String hiddenImagesCount(int count);
  String imagesCount(int count);
  String get addToPlaylist;
  String get noPlaylistsYet;
  String get noPlaylistsYetNew;
  String get backToPlaylists;
  String get deletePlaylistTooltip;

  // Batch gallery operations
  String get selectMode;
  String get selectAll;
  String get deselectAll;
  String get bulkDelete;
  String get bulkFavorite;
  String get bulkMoveToCollection;
  String get selectedCount;
  String confirmBulkDelete(int count);

  // Studio
  String get studioTitle;
  String get noStudioSessions;
  String get noStudioSessionsMsg;
  String get newSession;
  String get sessionName;
  String get selectSession;
  String get selectSessionMsg;
  String get sessions;
  String get deleteSession;
  String get deleteSessionMsg;
  String get sessionImages;
  String get imagesLabel;

  // Settings
  String get settingsTitle;
  String get appearance;
  String get appearanceSubtitle;
  String get system;
  String get light;
  String get dark;
  String get language;
  String get languageSubtitle;
  String get comfyuiServers;
  String get noServers;
  String get noServersMsg;
  String get addServer;
  String get editServer;
  String get llmServers;
  String get llmServersSubtitle;
  String get noLlmServers;
  String get noLlmServersMsg;
  String get addLlmServer;
  String get editLlmServer;
  String get apiKeyOptional;
  String get apiKeyHint;
  String get defaultModelOptional;
  String get defaultModelHint;
  String get deleteServer;
  String get deleteServerMsg;
  String get deleteLlmServer;
  String get deleteLlmServerMsg;
  String get galleryPrivacy;
  String get galleryPrivacyEnabled;
  String get galleryPrivacyDisabled;
  String get galleryProtectedMsg;
  String get galleryNoPasswordMsg;
  String get changePassword;
  String get setPassword;
  String get currentPassword;
  String get newPassword;
  String get confirmPassword;
  String get passwordsDoNotMatch;
  String get currentPasswordIncorrect;
  String get passwordUpdated;
  String get passwordSet;
  String get removePassword;
  String get removePasswordMsg;
  String get incorrectPasswordMsg;

  // Browse
  String get browseTitle;
  String get modelsTab;
  String get lorasTab;
  String get noServerConnected;
  String get noServerConnectedMsg;
  String get noModelsFound;
  String get noModelsFoundMsg;
  String get noLorasFound;
  String get noLorasFoundMsg;
  String get fetchAllTriggerWords;
  String fetchingTriggerWords(int count);
  String fetchingTriggerWordsFor(String name);
  String get fetchTriggerWords;
  String get show;
  String get hide;
  String get editLora;
  String get copyName;
  String copiedLabel(String label);
  String fromServer(String serverName);
  String get hidden;

  // LoRA picker
  String get selectLoras;
  String get searchByNameOrTriggers;
  String get noLorasAvailable;
  String get noMatches;
  String maxLorasSelected(int max);

  // LoRA edit
  String get triggerWords;
  String get triggerWordsHint;
  String savedLoraName(String name);

  // Progress
  String get cancelTooltip;
  String get retryTooltip;
  String get generationFailed;
  String get cancelled;
  String statusLabel(String status);

  // Error
  String get somethingWentWrong;
  String get genericError;
  String get networkError;
  String get serverError;
  String get notFound;
  String get timeoutError;
  String get comfyConnectionError;
  String get comfyNoServerError;

  // Image detail
  String get lorasCount;
  String imageMeta(String model, int width, int height, int seed);

  // Prompt History
  String get promptHistory;
  String get noPromptHistory;
  String get noPromptHistoryMsg;
  String get clearHistory;
  String get searchPrompts;
  String get promptHistoryTooltip;
}
