import 'app_strings.dart';

class AppStringsEn extends AppStrings {
  @override
  String get appName => 'Vidlatte';

  @override
  String get create => 'Create';
  @override
  String get gallery => 'Gallery';
  @override
  String get studio => 'Studio';
  @override
  String get settings => 'Settings';
  @override
  String get browse => 'Browse';

  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get save => 'Save';
  @override
  String get edit => 'Edit';
  @override
  String get add => 'Add';
  @override
  String get done => 'Done';
  @override
  String get retry => 'Retry';
  @override
  String get remove => 'Remove';
  @override
  String get required_ => 'Required';
  @override
  String get loading => 'Loading...';
  @override
  String get search => 'Search';
  @override
  String get select => 'Select';
  @override
  String get new_ => 'New';
  @override
  String get close => 'Close';
  @override
  String get stop => 'Stop';
  @override
  String get start => 'Start';
  @override
  String get back => 'Back';
  @override
  String get rename => 'Rename';
  @override
  String get confirm => 'Confirm';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get none => 'None';
  @override
  String get default_ => 'Default';
  @override
  String get status => 'Status';
  @override
  String get healthy => 'Healthy';
  @override
  String get unhealthy => 'Unhealthy';
  @override
  String get error => 'Error';
  @override
  String get models => 'Models';
  @override
  String get os => 'OS';
  @override
  String get python => 'Python';
  @override
  String get ram => 'RAM';
  @override
  String get enabled => 'Enabled';
  @override
  String get test => 'Test';
  @override
  String get fetchModels => 'Fetch Models';
  @override
  String get setDefault => 'Set Default';
  @override
  String get healthCheck => 'Health Check';
  @override
  String get name => 'Name';
  @override
  String get url => 'URL';
  @override
  String get invalidUrl => 'Invalid URL';
  @override
  String get authType => 'Authentication';
  @override
  String get authNone => 'None';
  @override
  String get authBasic => 'Basic Auth';
  @override
  String get authBearer => 'Bearer Token';
  @override
  String get username => 'Username';
  @override
  String get authPassword => 'Password';
  @override
  String get authToken => 'Token';
  @override
  String get negativePrompt => 'Negative Prompt';
  @override
  String get negativePromptHint => 'What to avoid in the image';
  @override
  String get loraWeight => 'Strength';
  @override
  String get img2img => 'Image to Image';
  @override
  String get txt2img => 'Text to Image';
  @override
  String get selectRefImage => 'Select Reference Image';
  @override
  String get refImageHint => 'Upload or pick an image to transform';
  @override
  String get denoiseStrength => 'Denoise Strength';
  @override
  String get denoiseHint => 'Higher = more change, lower = more similar to original';
  @override
  String get uploadImage => 'Upload Image';
  @override
  String get pickFromGallery => 'Pick from Gallery';
  @override
  String get noRefImage => 'No reference image selected';
  @override
  String get removeRefImage => 'Remove';
  @override
  String get faceRestore => 'Face Restore';
  @override
  String get faceRestoreStrength => 'Strength';
  @override
  String get useCodeFormer => 'Use CodeFormer';
  @override
  String get upscaleImage => 'Upscale';
  @override
  String get upscaleModel => 'Upscale Model';
  @override
  String get upscaleScale => 'Scale';
  @override
  String get processing => 'Processing...';
  @override
  String get processingMsg => 'This may take a moment';
  @override
  String get faceRestoreDone => 'Face restoration complete';
  @override
  String get faceRestoreFailed => 'Face restoration failed';
  @override
  String get upscaleDone => 'Upscaling complete';
  @override
  String get upscaleFailed => 'Upscaling failed';
  @override
  String get noUpscaleModels => 'No upscale models found on server';
  @override
  String get inpaint => 'Inpaint';
  @override
  String get inpaintHint => 'Paint over areas to regenerate';
  @override
  String get brushSize => 'Brush Size';
  @override
  String get clearMask => 'Clear Mask';
  @override
  String get maskEraser => 'Eraser';
  @override
  String get inpaintDenoise => 'Inpaint Strength';
  @override
  String get inpaintDenoiseHint => 'How much to change the masked area';
  @override
  String get noInpaintImage => 'Select an image to start inpainting';
  @override
  String get selectInpaintImage => 'Select Image';
  @override
  String get controlnet => 'ControlNet';
  @override
  String get controlnetHint => 'Guide generation with a reference image';
  @override
  String get controlnetModel => 'ControlNet Model';
  @override
  String get controlnetStrength => 'Strength';
  @override
  String get controlImage => 'Control Image';
  @override
  String get noControlnetModels => 'No ControlNet models found on server';
  @override
  String get selectControlImage => 'Select Control Image';

  @override
  String get createTitle => 'Create';
  @override
  String get autoImageTitle => 'Auto Image';
  @override
  String get browseModelsLoras => 'Browse Models & LoRAs';
  @override
  String get autoImageTooltip => 'Auto Image';
  @override
  String get backToCreate => 'Back to Create';
  @override
  String get generate => 'Generate';
  @override
  String get addToQueue => 'Add to Queue';
  @override
  String get results => 'Results';
  @override
  String get noImagesYet => 'No Images Yet';
  @override
  String get noImagesYetMsg => 'Write a prompt and hit Generate to create your first image.';
  @override
  String get noComfyServer => 'No ComfyUI Server';
  @override
  String get noComfyServerMsg => 'Add a ComfyUI server in Settings to start generating images.';
  @override
  String get enterPrompt => 'Enter a prompt first.';
  @override
  String get selectModel => 'Select a model first.';
  @override
  String get modelNotAvailable => '"{model}" is not available on {server}. Select a model from the list.';
  String modelNotAvailableRaw(String model, String server) => '"$model" is not available on $server. Select a model from the list.';
  @override
  String get queue => 'Queue';
  @override
  String get describeImage => 'Describe the image you want to generate...';
  @override
  String get model => 'Model';
  @override
  String get server => 'Server';
  @override
  String get selectServer => 'Select server';
  @override
  String get selectModelHint => 'Select a model';
  @override
  String get loadingModels => 'Loading models...';
  @override
  String get loras => 'LoRAs';
  @override
  String get noLorasSelected => 'No LoRAs selected';
  @override
  String get creativityCfg => 'Creativity (CFG)';
  @override
  String get advanced => 'Advanced';
  @override
  String get customCfg => 'Custom CFG';
  @override
  String get customCfgSubtitleOn => 'Override creativity slider with a custom value';
  @override
  String get customCfgSubtitleOff => 'Use creativity slider value';
  @override
  String get cfgScale => 'CFG Scale';
  @override
  String get hiresFix => 'Hires Fix';
  @override
  String get hiresFixSubtitle => 'Upscale by 1.5x after generation';
  @override
  String get dimensions => 'Dimensions';
  @override
  String get steps => 'Steps';
  @override
  String get stepsWithDefault => 'Steps';

  @override
  String get autoImageSubtitle => 'AI-powered automated image generation';
  @override
  String get generationMode => 'Generation Mode';
  @override
  String get auto => 'Auto';
  @override
  String get variation => 'Variation';
  @override
  String get topicOptional => 'Topic / Idea (optional)';
  @override
  String get topicHint => 'e.g., cyberpunk city, fantasy portrait...';
  @override
  String get leaveEmptyRandom => 'Leave empty for completely random prompts';
  @override
  String get basePrompt => 'Base Prompt';
  @override
  String get basePromptHint => 'Paste your prompt here. The AI will create variations...';
  @override
  String get variationDesc => 'The AI will vary style, lighting, and details while preserving your core content';
  @override
  String get mustIncludeTags => 'Must Include Tags';
  @override
  String get mustIncludeHint => 'e.g., red hair, specific pose...';
  @override
  String get maxImages => 'Max Images';
  @override
  String get infiniteImages => 'Generate infinite images';
  @override
  String get llmServer => 'LLM Server';
  @override
  String get llmModel => 'LLM Model';
  @override
  String get imageServer => 'Image Server';
  @override
  String get imageModel => 'Image Model';
  @override
  String get noLlmServersConfigured => 'No LLM servers configured. Add one in Settings.';
  @override
  String get noComfyServersConfigured => 'No ComfyUI servers configured. Add one in Settings.';
  @override
  String get startGeneration => 'Start Generation';
  @override
  String get autoImageEmptyMsg => 'Configure settings and press Start to begin automated generation.';
  @override
  String get idle => 'Idle';
  @override
  String get generatingPrompt => 'Generating prompt...';
  @override
  String get generatingImage => 'Generating image...';
  @override
  String get waiting => 'Waiting...';
  @override
  String get paused => 'Paused';
  @override
  String get completed => 'Completed';
  @override
  String get currentPrompt => 'Current Prompt';
  @override
  String get modelNotOnServer => '"{model}" is not available on the selected server.';
  String modelNotOnServerRaw(String model) => '"$model" is not available on the selected server.';

  @override
  String get galleryTitle => 'Gallery';
  @override
  String get galleryEmpty => 'Gallery is Empty';
  @override
  String get galleryEmptyMsg => 'Generated images will appear here automatically.';
  @override
  String get searchPromptModelLora => 'Search by prompt, model, or LoRA...';
  @override
  String get all => 'All';
  @override
  String get favorites => 'Favorites';
  @override
  String get playlists => 'Playlists';
  @override
  String get locked => 'Locked';
  @override
  String get unlocked => 'Unlocked';
  @override
  String get noResults => 'No Results';
  @override
  String get noResultsMsg => 'Try a different search or filter.';
  @override
  String get noHiddenImages => 'No Hidden Images';
  @override
  String get noHiddenImagesMsg => 'Hide images from the card menu to see them here.';
  @override
  String get noPlaylists => 'No Playlists';
  @override
  String get noPlaylistsMsg => 'Create a playlist to organize your images.';
  @override
  String get newPlaylist => 'New Playlist';
  @override
  String get playlistName => 'Playlist name';
  @override
  String get playlistNameHint => 'e.g. Portraits, Landscapes...';
  @override
  String get renamePlaylist => 'Rename Playlist';
  @override
  String get deletePlaylist => 'Delete Playlist';
  @override
  String get deletePlaylistConfirm => 'Delete "{name}"? Images will remain in your gallery.';
  String deletePlaylistConfirmRaw(String name) => 'Delete "$name"? Images will remain in your gallery.';
  @override
  String get deleteImage => 'Delete Image';
  @override
  String get deleteImageMsg => 'This will permanently remove the image from your device.';
  @override
  String get incorrectPassword => 'Incorrect password';
  @override
  String get galleryLocked => 'Gallery Locked';
  @override
  String get galleryLockedMsg => 'Enter your password to view hidden images.';
  @override
  String get password => 'Password';
  @override
  String get unlock => 'Unlock';
  @override
  String get noHiddenImagesPlural => 'No Hidden Images';
  @override
  String hiddenImagesCount(int count) => '$count hidden image${count == 1 ? '' : 's'}';
  @override
  String imagesCount(int count) => '$count image${count == 1 ? '' : 's'}';
  @override
  String get addToPlaylist => 'Add to playlist';
  @override
  String get noPlaylistsYet => 'No playlists yet. Tap "New playlist" below to create one.';
  @override
  String get noPlaylistsYetNew => 'No playlists yet. Tap "New" to create one.';
  @override
  String get backToPlaylists => 'Back to playlists';
  @override
  String get deletePlaylistTooltip => 'Delete playlist';

  @override
  String get selectMode => 'Select';
  @override
  String get selectAll => 'Select All';
  @override
  String get deselectAll => 'Deselect All';
  @override
  String get bulkDelete => 'Delete Selected';
  @override
  String get bulkFavorite => 'Favorite Selected';
  @override
  String get bulkMoveToCollection => 'Move to Collection';
  @override
  String get selectedCount => 'selected';
  @override
  String confirmBulkDelete(int count) => 'Delete $count images?';

  @override
  String get studioTitle => 'Studio';
  @override
  String get noStudioSessions => 'No Studio Sessions';
  @override
  String get noStudioSessionsMsg => 'Create a session to organize your generations by project.';
  @override
  String get newSession => 'New Session';
  @override
  String get sessionName => 'Session name';
  @override
  String get selectSession => 'Select a Session';
  @override
  String get selectSessionMsg => 'Choose a session from the list to view its images.';
  @override
  String get sessions => 'Sessions';
  @override
  String get deleteSession => 'Delete Session';
  @override
  String get deleteSessionMsg => 'Are you sure? This will remove the session and its images.';
  @override
  String get sessionImages => 'Session Images';
  @override
  String get imagesLabel => 'images';

  @override
  String get settingsTitle => 'Settings';
  @override
  String get appearance => 'Appearance';
  @override
  String get appearanceSubtitle => 'Choose how Vidlatte looks.';
  @override
  String get system => 'System';
  @override
  String get light => 'Light';
  @override
  String get dark => 'Dark';
  @override
  String get language => 'Language';
  @override
  String get languageSubtitle => 'Choose the app language.';
  @override
  String get comfyuiServers => 'ComfyUI Servers';
  @override
  String get noServers => 'No Servers';
  @override
  String get noServersMsg => 'Add a ComfyUI server to start generating images.';
  @override
  String get addServer => 'Add Server';
  @override
  String get editServer => 'Edit Server';
  @override
  String get llmServers => 'LLM Servers';
  @override
  String get llmServersSubtitle => 'Connect to LM Studio or any OpenAI-compatible server for prompt generation.';
  @override
  String get noLlmServers => 'No LLM Servers';
  @override
  String get noLlmServersMsg => 'Add an LLM server to enable Auto Image generation.';
  @override
  String get addLlmServer => 'Add LLM Server';
  @override
  String get editLlmServer => 'Edit LLM Server';
  @override
  String get apiKeyOptional => 'API Key (optional)';
  @override
  String get apiKeyHint => 'Leave empty for local servers';
  @override
  String get defaultModelOptional => 'Default Model (optional)';
  @override
  String get defaultModelHint => 'e.g., llama-3-8b-instruct';
  @override
  String get deleteServer => 'Delete Server';
  @override
  String get deleteServerMsg => 'Are you sure you want to remove this server?';
  @override
  String get deleteLlmServer => 'Delete LLM Server';
  @override
  String get deleteLlmServerMsg => 'Are you sure you want to remove this server?';
  @override
  String get galleryPrivacy => 'Gallery Privacy';
  @override
  String get galleryPrivacyEnabled => 'Password protection enabled';
  @override
  String get galleryPrivacyDisabled => 'Set a password to hide images';
  @override
  String get galleryProtectedMsg => 'Your gallery is protected. Hidden images require a password to view.';
  @override
  String get galleryNoPasswordMsg => 'Set a password to lock hidden images. Without a password, hidden images are still visible.';
  @override
  String get changePassword => 'Change Password';
  @override
  String get setPassword => 'Set Password';
  @override
  String get currentPassword => 'Current password';
  @override
  String get newPassword => 'New password';
  @override
  String get confirmPassword => 'Confirm password';
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  @override
  String get currentPasswordIncorrect => 'Current password is incorrect';
  @override
  String get passwordUpdated => 'Password updated';
  @override
  String get passwordSet => 'Password set';
  @override
  String get removePassword => 'Remove Password';
  @override
  String get removePasswordMsg => 'Enter your current password to remove password protection.';
  @override
  String get incorrectPasswordMsg => 'Incorrect password';

  @override
  String get browseTitle => 'Browse';
  @override
  String get modelsTab => 'Models';
  @override
  String get lorasTab => 'LoRAs';
  @override
  String get noServerConnected => 'No Server Connected';
  @override
  String get noServerConnectedMsg => 'Add a ComfyUI server in Settings to browse available models.';
  @override
  String get noModelsFound => 'No Models Found';
  @override
  String get noModelsFoundMsg => 'Make sure your ComfyUI server has checkpoints loaded.';
  @override
  String get noLorasFound => 'No LoRAs Found';
  @override
  String get noLorasFoundMsg => 'Make sure your ComfyUI server has LoRA models loaded.';
  @override
  String get fetchAllTriggerWords => 'Fetch All Trigger Words';
  @override
  String fetchingTriggerWords(int count) => 'Fetching trigger words for $count LoRAs...';
  @override
  String fetchingTriggerWordsFor(String name) => 'Fetching trigger words for $name...';
  @override
  String get fetchTriggerWords => 'Fetch trigger words';
  @override
  String get show => 'Show';
  @override
  String get hide => 'Hide';
  @override
  String get editLora => 'Edit LoRA';
  @override
  String get copyName => 'Copy name';
  @override
  String copiedLabel(String label) => 'Copied: $label';
  @override
  String fromServer(String serverName) => 'From: $serverName';
  @override
  String get hidden => 'Hidden';

  @override
  String get selectLoras => 'Select LoRAs';
  @override
  String get searchByNameOrTriggers => 'Search by name or trigger words...';
  @override
  String get noLorasAvailable => 'No LoRAs available';
  @override
  String get noMatches => 'No matches';
  @override
  String maxLorasSelected(int max) => 'Max $max LoRAs selected';

  @override
  String get triggerWords => 'Trigger words';
  @override
  String get triggerWordsHint => 'Comma-separated, e.g. cat girl, anime style';
  @override
  String savedLoraName(String name) => 'Saved: $name';

  @override
  String get cancelTooltip => 'Cancel';
  @override
  String get retryTooltip => 'Retry';
  @override
  String get generationFailed => 'Generation failed';
  @override
  String get cancelled => 'Cancelled';
  @override
  String statusLabel(String status) => 'Status: $status';

  @override
  String get somethingWentWrong => 'Something went wrong';
  @override
  String get genericError => 'Something went wrong. Please try again.';
  @override
  String get networkError => 'No connection. Please check your network and try again.';
  @override
  String get serverError => 'Server error. Please try again later.';
  @override
  String get notFound => 'Resource not found.';
  @override
  String get timeoutError => 'Request timed out. Please try again.';
  @override
  String get comfyConnectionError => 'Could not connect to ComfyUI server. Check the URL and make sure it is running.';
  @override
  String get comfyNoServerError => 'No ComfyUI server configured. Add one in Settings.';

  @override
  String get lorasCount => 'LoRAs';
  @override
  String imageMeta(String model, int width, int height, int seed) => '$model · ${width}x$height · seed: $seed';

  @override
  String get promptHistory => 'Prompt History';
  @override
  String get noPromptHistory => 'No history yet';
  @override
  String get noPromptHistoryMsg => 'Your generated prompts will appear here';
  @override
  String get clearHistory => 'Clear All';
  @override
  String get searchPrompts => 'Search prompts...';
  @override
  String get promptHistoryTooltip => 'Prompt History';
}
