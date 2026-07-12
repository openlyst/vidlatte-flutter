import 'app_strings.dart';

class AppStringsRu extends AppStrings {
  @override
  String get appName => 'Vidlatte';

  @override
  String get create => 'Создать';
  @override
  String get gallery => 'Галерея';
  @override
  String get studio => 'Студия';
  @override
  String get settings => 'Настройки';
  @override
  String get browse => 'Обзор';

  @override
  String get cancel => 'Отмена';
  @override
  String get delete => 'Удалить';
  @override
  String get save => 'Сохранить';
  @override
  String get edit => 'Изменить';
  @override
  String get add => 'Добавить';
  @override
  String get done => 'Готово';
  @override
  String get retry => 'Повторить';
  @override
  String get remove => 'Удалить';
  @override
  String get required_ => 'Обязательно';
  @override
  String get loading => 'Загрузка...';
  @override
  String get search => 'Поиск';
  @override
  String get select => 'Выбрать';
  @override
  String get new_ => 'Новый';
  @override
  String get close => 'Закрыть';
  @override
  String get stop => 'Стоп';
  @override
  String get start => 'Старт';
  @override
  String get back => 'Назад';
  @override
  String get rename => 'Переименовать';
  @override
  String get confirm => 'Подтвердить';
  @override
  String get yes => 'Да';
  @override
  String get no => 'Нет';
  @override
  String get none => 'Нет';
  @override
  String get default_ => 'По умолчанию';
  @override
  String get status => 'Статус';
  @override
  String get healthy => 'Работает';
  @override
  String get unhealthy => 'Недоступен';
  @override
  String get error => 'Ошибка';
  @override
  String get models => 'Модели';
  @override
  String get os => 'ОС';
  @override
  String get python => 'Python';
  @override
  String get ram => 'ОЗУ';
  @override
  String get enabled => 'Включено';
  @override
  String get test => 'Проверить';
  @override
  String get fetchModels => 'Загрузить модели';
  @override
  String get setDefault => 'По умолчанию';
  @override
  String get healthCheck => 'Проверка';
  @override
  String get name => 'Название';
  @override
  String get url => 'URL';
  @override
  String get invalidUrl => 'Неверный URL';
  @override
  String get authType => 'Аутентификация';
  @override
  String get authNone => 'Нет';
  @override
  String get authBasic => 'Basic Auth';
  @override
  String get authBearer => 'Bearer токен';
  @override
  String get username => 'Имя пользователя';
  @override
  String get authPassword => 'Пароль';
  @override
  String get authToken => 'Токен';
  @override
  String get negativePrompt => 'Негативный промпт';
  @override
  String get negativePromptHint => 'Что исключить из изображения';
  @override
  String get loraWeight => 'Сила';
  @override
  String get img2img => 'Изображение в изображение';
  @override
  String get txt2img => 'Текст в изображение';
  @override
  String get selectRefImage => 'Выбрать исходное изображение';
  @override
  String get refImageHint => 'Загрузите или выберите изображение для преобразования';
  @override
  String get denoiseStrength => 'Сила денойза';
  @override
  String get denoiseHint => 'Выше = больше изменений, ниже = ближе к оригиналу';
  @override
  String get uploadImage => 'Загрузить изображение';
  @override
  String get pickFromGallery => 'Выбрать из галереи';
  @override
  String get noRefImage => 'Исходное изображение не выбрано';
  @override
  String get removeRefImage => 'Убрать';
  @override
  String get faceRestore => 'Восстановление лиц';
  @override
  String get faceRestoreStrength => 'Сила';
  @override
  String get useCodeFormer => 'Использовать CodeFormer';
  @override
  String get upscaleImage => 'Апскейл';
  @override
  String get upscaleModel => 'Модель апскейла';
  @override
  String get upscaleScale => 'Масштаб';
  @override
  String get processing => 'Обработка...';
  @override
  String get processingMsg => 'Это может занять время';
  @override
  String get faceRestoreDone => 'Восстановление лиц завершено';
  @override
  String get faceRestoreFailed => 'Ошибка восстановления лиц';
  @override
  String get upscaleDone => 'Апскейл завершён';
  @override
  String get upscaleFailed => 'Ошибка апскейла';

  @override
  String get createTitle => 'Создать';
  @override
  String get autoImageTitle => 'Авто';
  @override
  String get browseModelsLoras => 'Обзор моделей и LoRA';
  @override
  String get autoImageTooltip => 'Авто-изображение';
  @override
  String get backToCreate => 'Вернуться к созданию';
  @override
  String get generate => 'Создать';
  @override
  String get addToQueue => 'В очередь';
  @override
  String get results => 'Результаты';
  @override
  String get noImagesYet => 'Нет изображений';
  @override
  String get noImagesYetMsg => 'Введите промпт и нажмите «Создать» для генерации первого изображения.';
  @override
  String get noComfyServer => 'Нет сервера ComfyUI';
  @override
  String get noComfyServerMsg => 'Добавьте сервер ComfyUI в настройках, чтобы начать генерацию.';
  @override
  String get enterPrompt => 'Сначала введите промпт.';
  @override
  String get selectModel => 'Сначала выберите модель.';
  @override
  String get modelNotAvailable => '«{model}» недоступен на {server}. Выберите модель из списка.';
  String modelNotAvailableRaw(String model, String server) => '«$model» недоступен на $server. Выберите модель из списка.';
  @override
  String get queue => 'Очередь';
  @override
  String get describeImage => 'Опишите изображение, которое хотите создать...';
  @override
  String get model => 'Модель';
  @override
  String get server => 'Сервер';
  @override
  String get selectServer => 'Выберите сервер';
  @override
  String get selectModelHint => 'Выберите модель';
  @override
  String get loadingModels => 'Загрузка моделей...';
  @override
  String get loras => 'LoRA';
  @override
  String get noLorasSelected => 'LoRA не выбраны';
  @override
  String get creativityCfg => 'Креативность (CFG)';
  @override
  String get advanced => 'Дополнительно';
  @override
  String get customCfg => 'Свой CFG';
  @override
  String get customCfgSubtitleOn => 'Переопределить ползунок креативности своим значением';
  @override
  String get customCfgSubtitleOff => 'Использовать значение ползунка';
  @override
  String get cfgScale => 'Значение CFG';
  @override
  String get hiresFix => 'Hires Fix';
  @override
  String get hiresFixSubtitle => 'Увеличить в 1.5x после генерации';
  @override
  String get dimensions => 'Размер';
  @override
  String get steps => 'Шаги';
  @override
  String get stepsWithDefault => 'Шаги';

  @override
  String get autoImageSubtitle => 'Автоматическая генерация изображений с ИИ';
  @override
  String get generationMode => 'Режим генерации';
  @override
  String get auto => 'Авто';
  @override
  String get variation => 'Вариации';
  @override
  String get topicOptional => 'Тема / Идея (необязательно)';
  @override
  String get topicHint => 'напр.: киберпанк город, фэнтези портрет...';
  @override
  String get leaveEmptyRandom => 'Оставьте пустым для случайных промптов';
  @override
  String get basePrompt => 'Базовый промпт';
  @override
  String get basePromptHint => 'Вставьте промпт сюда. ИИ создаст вариации...';
  @override
  String get variationDesc => 'ИИ изменит стиль, освещение и детали, сохранив основное содержание';
  @override
  String get mustIncludeTags => 'Обязательные теги';
  @override
  String get mustIncludeHint => 'напр.: рыжие волосы, поза...';
  @override
  String get maxImages => 'Макс. изображений';
  @override
  String get llmServer => 'LLM-сервер';
  @override
  String get llmModel => 'LLM-модель';
  @override
  String get imageServer => 'Сервер изображений';
  @override
  String get imageModel => 'Модель изображений';
  @override
  String get noLlmServersConfigured => 'LLM-серверы не настроены. Добавьте в настройках.';
  @override
  String get noComfyServersConfigured => 'ComfyUI-серверы не настроены. Добавьте в настройках.';
  @override
  String get startGeneration => 'Начать генерацию';
  @override
  String get autoImageEmptyMsg => 'Настройте параметры и нажмите «Старт» для автоматической генерации.';
  @override
  String get idle => 'Ожидание';
  @override
  String get generatingPrompt => 'Генерация промпта...';
  @override
  String get generatingImage => 'Генерация изображения...';
  @override
  String get waiting => 'Ожидание...';
  @override
  String get paused => 'Пауза';
  @override
  String get completed => 'Завершено';
  @override
  String get currentPrompt => 'Текущий промпт';
  @override
  String get modelNotOnServer => '«{model}» недоступен на выбранном сервере.';
  String modelNotOnServerRaw(String model) => '«$model» недоступен на выбранном сервере.';

  @override
  String get galleryTitle => 'Галерея';
  @override
  String get galleryEmpty => 'Галерея пуста';
  @override
  String get galleryEmptyMsg => 'Сгенерированные изображения появятся здесь автоматически.';
  @override
  String get searchPromptModelLora => 'Поиск по промпту, модели или LoRA...';
  @override
  String get all => 'Все';
  @override
  String get favorites => 'Избранное';
  @override
  String get playlists => 'Плейлисты';
  @override
  String get locked => 'Заблокировано';
  @override
  String get unlocked => 'Разблокировано';
  @override
  String get noResults => 'Нет результатов';
  @override
  String get noResultsMsg => 'Попробуйте другой поиск или фильтр.';
  @override
  String get noHiddenImages => 'Нет скрытых изображений';
  @override
  String get noHiddenImagesMsg => 'Скройте изображения из меню карточки, чтобы увидеть их здесь.';
  @override
  String get noPlaylists => 'Нет плейлистов';
  @override
  String get noPlaylistsMsg => 'Создайте плейлист для организации изображений.';
  @override
  String get newPlaylist => 'Новый плейлист';
  @override
  String get playlistName => 'Название плейлиста';
  @override
  String get playlistNameHint => 'напр.: Портреты, Пейзажи...';
  @override
  String get renamePlaylist => 'Переименовать плейлист';
  @override
  String get deletePlaylist => 'Удалить плейлист';
  @override
  String get deletePlaylistConfirm => 'Удалить «{name}»? Изображения останутся в галерее.';
  String deletePlaylistConfirmRaw(String name) => 'Удалить «$name»? Изображения останутся в галерее.';
  @override
  String get deleteImage => 'Удалить изображение';
  @override
  String get deleteImageMsg => 'Это навсегда удалит изображение с вашего устройства.';
  @override
  String get incorrectPassword => 'Неверный пароль';
  @override
  String get galleryLocked => 'Галерея заблокирована';
  @override
  String get galleryLockedMsg => 'Введите пароль для просмотра скрытых изображений.';
  @override
  String get password => 'Пароль';
  @override
  String get unlock => 'Разблокировать';
  @override
  String get noHiddenImagesPlural => 'Нет скрытых изображений';
  @override
  String hiddenImagesCount(int count) => '$count скрытых изображений';
  @override
  String imagesCount(int count) {
    if (count == 1) return '$count изображение';
    if (count >= 2 && count <= 4) return '$count изображения';
    return '$count изображений';
  }
  @override
  String get addToPlaylist => 'В плейлист';
  @override
  String get noPlaylistsYet => 'Нет плейлистов. Нажмите «Новый плейлист» ниже, чтобы создать.';
  @override
  String get noPlaylistsYetNew => 'Нет плейлистов. Нажмите «Новый», чтобы создать.';
  @override
  String get backToPlaylists => 'Назад к плейлистам';
  @override
  String get deletePlaylistTooltip => 'Удалить плейлист';

  @override
  String get selectMode => 'Выбрать';
  @override
  String get selectAll => 'Выбрать все';
  @override
  String get deselectAll => 'Снять выделение';
  @override
  String get bulkDelete => 'Удалить выбранные';
  @override
  String get bulkFavorite => 'В избранное';
  @override
  String get bulkMoveToCollection => 'В коллекцию';
  @override
  String get selectedCount => 'выбрано';
  @override
  String confirmBulkDelete(int count) => 'Удалить $count изображений?';

  @override
  String get studioTitle => 'Студия';
  @override
  String get noStudioSessions => 'Нет сессий студии';
  @override
  String get noStudioSessionsMsg => 'Создайте сессию для организации генераций по проектам.';
  @override
  String get newSession => 'Новая сессия';
  @override
  String get sessionName => 'Название сессии';
  @override
  String get selectSession => 'Выберите сессию';
  @override
  String get selectSessionMsg => 'Выберите сессию из списка для просмотра изображений.';
  @override
  String get sessions => 'Сессии';
  @override
  String get deleteSession => 'Удалить сессию';
  @override
  String get deleteSessionMsg => 'Уверены? Это удалит сессию и её изображения.';
  @override
  String get sessionImages => 'Изображения сессии';
  @override
  String get imagesLabel => 'изображений';

  @override
  String get settingsTitle => 'Настройки';
  @override
  String get appearance => 'Оформление';
  @override
  String get appearanceSubtitle => 'Выберите внешний вид Vidlatte.';
  @override
  String get system => 'Системная';
  @override
  String get light => 'Светлая';
  @override
  String get dark => 'Тёмная';
  @override
  String get language => 'Язык';
  @override
  String get languageSubtitle => 'Выберите язык приложения.';
  @override
  String get comfyuiServers => 'Серверы ComfyUI';
  @override
  String get noServers => 'Нет серверов';
  @override
  String get noServersMsg => 'Добавьте сервер ComfyUI для генерации изображений.';
  @override
  String get addServer => 'Добавить сервер';
  @override
  String get editServer => 'Изменить сервер';
  @override
  String get llmServers => 'LLM-серверы';
  @override
  String get llmServersSubtitle => 'Подключитесь к LM Studio или любому OpenAI-совместимому серверу для генерации промптов.';
  @override
  String get noLlmServers => 'Нет LLM-серверов';
  @override
  String get noLlmServersMsg => 'Добавьте LLM-сервер для автоматической генерации.';
  @override
  String get addLlmServer => 'Добавить LLM-сервер';
  @override
  String get editLlmServer => 'Изменить LLM-сервер';
  @override
  String get apiKeyOptional => 'API-ключ (необязательно)';
  @override
  String get apiKeyHint => 'Оставьте пустым для локальных серверов';
  @override
  String get defaultModelOptional => 'Модель по умолчанию (необязательно)';
  @override
  String get defaultModelHint => 'напр.: llama-3-8b-instruct';
  @override
  String get deleteServer => 'Удалить сервер';
  @override
  String get deleteServerMsg => 'Уверены, что хотите удалить этот сервер?';
  @override
  String get deleteLlmServer => 'Удалить LLM-сервер';
  @override
  String get deleteLlmServerMsg => 'Уверены, что хотите удалить этот сервер?';
  @override
  String get galleryPrivacy => 'Приватность галереи';
  @override
  String get galleryPrivacyEnabled => 'Защита паролем включена';
  @override
  String get galleryPrivacyDisabled => 'Установите пароль для скрытия изображений';
  @override
  String get galleryProtectedMsg => 'Галерея защищена. Для просмотра скрытых изображений требуется пароль.';
  @override
  String get galleryNoPasswordMsg => 'Установите пароль для скрытия изображений. Без пароля скрытые изображения остаются видимыми.';
  @override
  String get changePassword => 'Изменить пароль';
  @override
  String get setPassword => 'Установить пароль';
  @override
  String get currentPassword => 'Текущий пароль';
  @override
  String get newPassword => 'Новый пароль';
  @override
  String get confirmPassword => 'Подтвердите пароль';
  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';
  @override
  String get currentPasswordIncorrect => 'Текущий пароль неверен';
  @override
  String get passwordUpdated => 'Пароль обновлён';
  @override
  String get passwordSet => 'Пароль установлен';
  @override
  String get removePassword => 'Удалить пароль';
  @override
  String get removePasswordMsg => 'Введите текущий пароль для снятия защиты.';
  @override
  String get incorrectPasswordMsg => 'Неверный пароль';

  @override
  String get browseTitle => 'Обзор';
  @override
  String get modelsTab => 'Модели';
  @override
  String get lorasTab => 'LoRA';
  @override
  String get noServerConnected => 'Сервер не подключён';
  @override
  String get noServerConnectedMsg => 'Добавьте сервер ComfyUI в настройках для просмотра моделей.';
  @override
  String get noModelsFound => 'Модели не найдены';
  @override
  String get noModelsFoundMsg => 'Убедитесь, что на сервере ComfyUI загружены чекпойнты.';
  @override
  String get noLorasFound => 'LoRA не найдены';
  @override
  String get noLorasFoundMsg => 'Убедитесь, что на сервере ComfyUI загружены модели LoRA.';
  @override
  String get fetchAllTriggerWords => 'Получить все триггер-слова';
  @override
  String fetchingTriggerWords(int count) => 'Получение триггер-слов для $count LoRA...';
  @override
  String fetchingTriggerWordsFor(String name) => 'Получение триггер-слов для $name...';
  @override
  String get fetchTriggerWords => 'Получить триггер-слова';
  @override
  String get show => 'Показать';
  @override
  String get hide => 'Скрыть';
  @override
  String get editLora => 'Изменить LoRA';
  @override
  String get copyName => 'Копировать название';
  @override
  String copiedLabel(String label) => 'Скопировано: $label';
  @override
  String fromServer(String serverName) => 'С: $serverName';
  @override
  String get hidden => 'Скрыто';

  @override
  String get selectLoras => 'Выбрать LoRA';
  @override
  String get searchByNameOrTriggers => 'Поиск по названию или триггер-словам...';
  @override
  String get noLorasAvailable => 'Нет доступных LoRA';
  @override
  String get noMatches => 'Нет совпадений';
  @override
  String maxLorasSelected(int max) => 'Максимум $max LoRA выбрано';

  @override
  String get triggerWords => 'Триггер-слова';
  @override
  String get triggerWordsHint => 'Через запятую, напр.: cat girl, anime style';
  @override
  String savedLoraName(String name) => 'Сохранено: $name';

  @override
  String get cancelTooltip => 'Отмена';
  @override
  String get retryTooltip => 'Повторить';
  @override
  String get generationFailed => 'Генерация не удалась';
  @override
  String get cancelled => 'Отменено';
  @override
  String statusLabel(String status) => 'Статус: $status';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';
  @override
  String get genericError => 'Что-то пошло не так. Попробуйте снова.';
  @override
  String get networkError => 'Нет соединения. Проверьте сеть и попробуйте снова.';
  @override
  String get serverError => 'Ошибка сервера. Попробуйте позже.';
  @override
  String get notFound => 'Ресурс не найден.';
  @override
  String get timeoutError => 'Время запроса истекло. Попробуйте снова.';
  @override
  String get comfyConnectionError => 'Не удалось подключиться к серверу ComfyUI. Проверьте URL и убедитесь, что сервер запущен.';
  @override
  String get comfyNoServerError => 'Сервер ComfyUI не настроен. Добавьте в настройках.';

  @override
  String get lorasCount => 'LoRA';
  @override
  String imageMeta(String model, int width, int height, int seed) => '$model · ${width}x$height · сид: $seed';

  @override
  String get promptHistory => 'История промптов';
  @override
  String get noPromptHistory => 'Истории нет';
  @override
  String get noPromptHistoryMsg => 'Сгенерированные промпты появятся здесь';
  @override
  String get clearHistory => 'Очистить всё';
  @override
  String get searchPrompts => 'Поиск промптов...';
  @override
  String get promptHistoryTooltip => 'История промптов';
}
