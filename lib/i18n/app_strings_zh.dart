import 'app_strings.dart';

class AppStringsZh extends AppStrings {
  @override
  String get appName => 'Vidlatte';

  @override
  String get create => '创作';
  @override
  String get gallery => '画廊';
  @override
  String get studio => '工作室';
  @override
  String get settings => '设置';
  @override
  String get browse => '浏览';

  @override
  String get cancel => '取消';
  @override
  String get delete => '删除';
  @override
  String get save => '保存';
  @override
  String get edit => '编辑';
  @override
  String get add => '添加';
  @override
  String get done => '完成';
  @override
  String get retry => '重试';
  @override
  String get remove => '移除';
  @override
  String get required_ => '必填';
  @override
  String get loading => '加载中...';
  @override
  String get search => '搜索';
  @override
  String get select => '选择';
  @override
  String get new_ => '新建';
  @override
  String get close => '关闭';
  @override
  String get stop => '停止';
  @override
  String get start => '开始';
  @override
  String get back => '返回';
  @override
  String get rename => '重命名';
  @override
  String get confirm => '确认';
  @override
  String get yes => '是';
  @override
  String get no => '否';
  @override
  String get none => '无';
  @override
  String get default_ => '默认';
  @override
  String get status => '状态';
  @override
  String get healthy => '健康';
  @override
  String get unhealthy => '异常';
  @override
  String get error => '错误';
  @override
  String get models => '模型';
  @override
  String get os => '系统';
  @override
  String get python => 'Python';
  @override
  String get ram => '内存';
  @override
  String get enabled => '启用';
  @override
  String get test => '测试';
  @override
  String get fetchModels => '获取模型';
  @override
  String get setDefault => '设为默认';
  @override
  String get healthCheck => '健康检查';
  @override
  String get name => '名称';
  @override
  String get url => '地址';
  @override
  String get invalidUrl => '无效地址';
  @override
  String get authType => '认证方式';
  @override
  String get authNone => '无';
  @override
  String get authBasic => '基本认证';
  @override
  String get authBearer => 'Bearer 令牌';
  @override
  String get username => '用户名';
  @override
  String get authPassword => '密码';
  @override
  String get authToken => '令牌';
  @override
  String get negativePrompt => '反向提示词';
  @override
  String get negativePromptHint => '不想在图片中出现的内容';
  @override
  String get loraWeight => '强度';
  @override
  String get img2img => '图生图';
  @override
  String get txt2img => '文生图';
  @override
  String get selectRefImage => '选择参考图片';
  @override
  String get refImageHint => '上传或选择一张图片进行变换';
  @override
  String get denoiseStrength => '重绘幅度';
  @override
  String get denoiseHint => '越高变化越大，越低越接近原图';
  @override
  String get uploadImage => '上传图片';
  @override
  String get pickFromGallery => '从图库选择';
  @override
  String get noRefImage => '未选择参考图片';
  @override
  String get removeRefImage => '移除';

  @override
  String get createTitle => '创作';
  @override
  String get autoImageTitle => '自动生成';
  @override
  String get browseModelsLoras => '浏览模型和LoRA';
  @override
  String get autoImageTooltip => '自动生成';
  @override
  String get backToCreate => '返回创作';
  @override
  String get generate => '生成';
  @override
  String get addToQueue => '加入队列';
  @override
  String get results => '结果';
  @override
  String get noImagesYet => '暂无图片';
  @override
  String get noImagesYetMsg => '输入提示词并点击生成来创建你的第一张图片。';
  @override
  String get noComfyServer => '无ComfyUI服务器';
  @override
  String get noComfyServerMsg => '在设置中添加ComfyUI服务器以开始生成图片。';
  @override
  String get enterPrompt => '请先输入提示词。';
  @override
  String get selectModel => '请先选择模型。';
  @override
  String get modelNotAvailable => '"{model}"在{server}上不可用，请从列表中选择模型。';
  String modelNotAvailableRaw(String model, String server) => '"$model"在$server上不可用，请从列表中选择模型。';
  @override
  String get queue => '队列';
  @override
  String get describeImage => '描述你想生成的图片...';
  @override
  String get model => '模型';
  @override
  String get server => '服务器';
  @override
  String get selectServer => '选择服务器';
  @override
  String get selectModelHint => '选择模型';
  @override
  String get loadingModels => '加载模型中...';
  @override
  String get loras => 'LoRA';
  @override
  String get noLorasSelected => '未选择LoRA';
  @override
  String get creativityCfg => '创意度（CFG）';
  @override
  String get advanced => '高级设置';
  @override
  String get customCfg => '自定义CFG';
  @override
  String get customCfgSubtitleOn => '用自定义值覆盖创意度滑块';
  @override
  String get customCfgSubtitleOff => '使用创意度滑块值';
  @override
  String get cfgScale => 'CFG值';
  @override
  String get hiresFix => '高清修复';
  @override
  String get hiresFixSubtitle => '生成后放大1.5倍';
  @override
  String get dimensions => '尺寸';
  @override
  String get steps => '步数';
  @override
  String get stepsWithDefault => '步数';

  @override
  String get autoImageSubtitle => 'AI驱动的自动图片生成';
  @override
  String get generationMode => '生成模式';
  @override
  String get auto => '自动';
  @override
  String get variation => '变体';
  @override
  String get topicOptional => '主题/想法（可选）';
  @override
  String get topicHint => '例如：赛博朋克城市，奇幻肖像...';
  @override
  String get leaveEmptyRandom => '留空则完全随机生成提示词';
  @override
  String get basePrompt => '基础提示词';
  @override
  String get basePromptHint => '在此粘贴你的提示词，AI将创建变体...';
  @override
  String get variationDesc => 'AI将变换风格、光照和细节，同时保留你的核心内容';
  @override
  String get mustIncludeTags => '必须包含的标签';
  @override
  String get mustIncludeHint => '例如：红发，特定姿势...';
  @override
  String get maxImages => '最大图片数';
  @override
  String get llmServer => 'LLM服务器';
  @override
  String get llmModel => 'LLM模型';
  @override
  String get imageServer => '图片服务器';
  @override
  String get imageModel => '图片模型';
  @override
  String get noLlmServersConfigured => '未配置LLM服务器，请在设置中添加。';
  @override
  String get noComfyServersConfigured => '未配置ComfyUI服务器，请在设置中添加。';
  @override
  String get startGeneration => '开始生成';
  @override
  String get autoImageEmptyMsg => '配置设置并点击开始以启动自动生成。';
  @override
  String get idle => '空闲';
  @override
  String get generatingPrompt => '生成提示词中...';
  @override
  String get generatingImage => '生成图片中...';
  @override
  String get waiting => '等待中...';
  @override
  String get paused => '已暂停';
  @override
  String get completed => '已完成';
  @override
  String get currentPrompt => '当前提示词';
  @override
  String get modelNotOnServer => '"{model}"在所选服务器上不可用。';
  String modelNotOnServerRaw(String model) => '"$model"在所选服务器上不可用。';

  @override
  String get galleryTitle => '画廊';
  @override
  String get galleryEmpty => '画廊为空';
  @override
  String get galleryEmptyMsg => '生成的图片将自动出现在这里。';
  @override
  String get searchPromptModelLora => '按提示词、模型或LoRA搜索...';
  @override
  String get all => '全部';
  @override
  String get favorites => '收藏';
  @override
  String get playlists => '播放列表';
  @override
  String get locked => '已锁定';
  @override
  String get unlocked => '已解锁';
  @override
  String get noResults => '无结果';
  @override
  String get noResultsMsg => '尝试其他搜索或筛选条件。';
  @override
  String get noHiddenImages => '无隐藏图片';
  @override
  String get noHiddenImagesMsg => '从卡片菜单隐藏图片即可在此查看。';
  @override
  String get noPlaylists => '无播放列表';
  @override
  String get noPlaylistsMsg => '创建播放列表来整理你的图片。';
  @override
  String get newPlaylist => '新建播放列表';
  @override
  String get playlistName => '播放列表名称';
  @override
  String get playlistNameHint => '例如：人像，风景...';
  @override
  String get renamePlaylist => '重命名播放列表';
  @override
  String get deletePlaylist => '删除播放列表';
  @override
  String get deletePlaylistConfirm => '删除"{name}"？图片将保留在画廊中。';
  String deletePlaylistConfirmRaw(String name) => '删除"$name"？图片将保留在画廊中。';
  @override
  String get deleteImage => '删除图片';
  @override
  String get deleteImageMsg => '这将从你的设备永久移除该图片。';
  @override
  String get incorrectPassword => '密码错误';
  @override
  String get galleryLocked => '画廊已锁定';
  @override
  String get galleryLockedMsg => '输入密码以查看隐藏图片。';
  @override
  String get password => '密码';
  @override
  String get unlock => '解锁';
  @override
  String get noHiddenImagesPlural => '无隐藏图片';
  @override
  String hiddenImagesCount(int count) => '$count张隐藏图片';
  @override
  String imagesCount(int count) => '$count张图片';
  @override
  String get addToPlaylist => '添加到播放列表';
  @override
  String get noPlaylistsYet => '暂无播放列表。点击下方"新建播放列表"创建。';
  @override
  String get noPlaylistsYetNew => '暂无播放列表。点击"新建"创建。';
  @override
  String get backToPlaylists => '返回播放列表';
  @override
  String get deletePlaylistTooltip => '删除播放列表';

  @override
  String get studioTitle => '工作室';
  @override
  String get noStudioSessions => '无工作室会话';
  @override
  String get noStudioSessionsMsg => '创建会话以按项目整理你的生成。';
  @override
  String get newSession => '新建会话';
  @override
  String get sessionName => '会话名称';
  @override
  String get selectSession => '选择会话';
  @override
  String get selectSessionMsg => '从列表中选择会话以查看其图片。';
  @override
  String get sessions => '会话';
  @override
  String get deleteSession => '删除会话';
  @override
  String get deleteSessionMsg => '确定吗？这将移除该会话及其图片。';
  @override
  String get sessionImages => '会话图片';
  @override
  String get imagesLabel => '张图片';

  @override
  String get settingsTitle => '设置';
  @override
  String get appearance => '外观';
  @override
  String get appearanceSubtitle => '选择Vidlatte的外观。';
  @override
  String get system => '跟随系统';
  @override
  String get light => '浅色';
  @override
  String get dark => '深色';
  @override
  String get language => '语言';
  @override
  String get languageSubtitle => '选择应用语言。';
  @override
  String get comfyuiServers => 'ComfyUI服务器';
  @override
  String get noServers => '无服务器';
  @override
  String get noServersMsg => '添加ComfyUI服务器以开始生成图片。';
  @override
  String get addServer => '添加服务器';
  @override
  String get editServer => '编辑服务器';
  @override
  String get llmServers => 'LLM服务器';
  @override
  String get llmServersSubtitle => '连接LM Studio或任何兼容OpenAI的服务器以生成提示词。';
  @override
  String get noLlmServers => '无LLM服务器';
  @override
  String get noLlmServersMsg => '添加LLM服务器以启用自动生成。';
  @override
  String get addLlmServer => '添加LLM服务器';
  @override
  String get editLlmServer => '编辑LLM服务器';
  @override
  String get apiKeyOptional => 'API密钥（可选）';
  @override
  String get apiKeyHint => '本地服务器留空即可';
  @override
  String get defaultModelOptional => '默认模型（可选）';
  @override
  String get defaultModelHint => '例如：llama-3-8b-instruct';
  @override
  String get deleteServer => '删除服务器';
  @override
  String get deleteServerMsg => '确定要移除此服务器吗？';
  @override
  String get deleteLlmServer => '删除LLM服务器';
  @override
  String get deleteLlmServerMsg => '确定要移除此服务器吗？';
  @override
  String get galleryPrivacy => '画廊隐私';
  @override
  String get galleryPrivacyEnabled => '已启用密码保护';
  @override
  String get galleryPrivacyDisabled => '设置密码以隐藏图片';
  @override
  String get galleryProtectedMsg => '你的画廊已受保护。查看隐藏图片需要密码。';
  @override
  String get galleryNoPasswordMsg => '设置密码以锁定隐藏图片。未设密码时，隐藏图片仍可见。';
  @override
  String get changePassword => '修改密码';
  @override
  String get setPassword => '设置密码';
  @override
  String get currentPassword => '当前密码';
  @override
  String get newPassword => '新密码';
  @override
  String get confirmPassword => '确认密码';
  @override
  String get passwordsDoNotMatch => '两次密码不一致';
  @override
  String get currentPasswordIncorrect => '当前密码不正确';
  @override
  String get passwordUpdated => '密码已更新';
  @override
  String get passwordSet => '密码已设置';
  @override
  String get removePassword => '移除密码';
  @override
  String get removePasswordMsg => '输入当前密码以移除密码保护。';
  @override
  String get incorrectPasswordMsg => '密码错误';

  @override
  String get browseTitle => '浏览';
  @override
  String get modelsTab => '模型';
  @override
  String get lorasTab => 'LoRA';
  @override
  String get noServerConnected => '未连接服务器';
  @override
  String get noServerConnectedMsg => '在设置中添加ComfyUI服务器以浏览可用模型。';
  @override
  String get noModelsFound => '未找到模型';
  @override
  String get noModelsFoundMsg => '请确保ComfyUI服务器已加载检查点。';
  @override
  String get noLorasFound => '未找到LoRA';
  @override
  String get noLorasFoundMsg => '请确保ComfyUI服务器已加载LoRA模型。';
  @override
  String get fetchAllTriggerWords => '获取所有触发词';
  @override
  String fetchingTriggerWords(int count) => '正在获取$count个LoRA的触发词...';
  @override
  String fetchingTriggerWordsFor(String name) => '正在获取$name的触发词...';
  @override
  String get fetchTriggerWords => '获取触发词';
  @override
  String get show => '显示';
  @override
  String get hide => '隐藏';
  @override
  String get editLora => '编辑LoRA';
  @override
  String get copyName => '复制名称';
  @override
  String copiedLabel(String label) => '已复制：$label';
  @override
  String fromServer(String serverName) => '来自：$serverName';
  @override
  String get hidden => '已隐藏';

  @override
  String get selectLoras => '选择LoRA';
  @override
  String get searchByNameOrTriggers => '按名称或触发词搜索...';
  @override
  String get noLorasAvailable => '无可用LoRA';
  @override
  String get noMatches => '无匹配结果';
  @override
  String maxLorasSelected(int max) => '最多选择$max个LoRA';

  @override
  String get triggerWords => '触发词';
  @override
  String get triggerWordsHint => '逗号分隔，例如：猫娘，动漫风格';
  @override
  String savedLoraName(String name) => '已保存：$name';

  @override
  String get cancelTooltip => '取消';
  @override
  String get retryTooltip => '重试';
  @override
  String get generationFailed => '生成失败';
  @override
  String get cancelled => '已取消';
  @override
  String statusLabel(String status) => '状态：$status';

  @override
  String get somethingWentWrong => '出错了';
  @override
  String get genericError => '出错了，请重试。';
  @override
  String get networkError => '无网络连接，请检查网络后重试。';
  @override
  String get serverError => '服务器错误，请稍后重试。';
  @override
  String get notFound => '未找到资源。';
  @override
  String get timeoutError => '请求超时，请重试。';
  @override
  String get comfyConnectionError => '无法连接到ComfyUI服务器，请检查地址并确保其正在运行。';
  @override
  String get comfyNoServerError => '未配置ComfyUI服务器，请在设置中添加。';

  @override
  String get lorasCount => 'LoRA';
  @override
  String imageMeta(String model, int width, int height, int seed) => '$model · ${width}x$height · 种子：$seed';
}
