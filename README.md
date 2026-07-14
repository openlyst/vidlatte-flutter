# Vidlatte

[中文文档](README.zh.md)

A standalone AI image generation app powered by ComfyUI. Connect to one or more ComfyUI servers, generate images with full control over models, LoRAs, ControlNet, and more — all from a clean cross-platform Flutter interface.

![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Web-lightgrey.svg)
![Flutter](https://img.shields.io/badge/Flutter-stable-blue.svg)
![Nightly](https://img.shields.io/badge/release-nightly-orange.svg)

## Features

- **Multi-server support** — connect to multiple ComfyUI instances, switch between them on the fly
- **Text-to-Image and Image-to-Image** — full txt2img and img2img workflows with reference image upload
- **Inpainting** — mask-based inpainting with adjustable brush size and denoise strength
- **ControlNet** — apply ControlNet models with control images and adjustable strength
- **LoRA management** — select multiple LoRAs with individual weight control, fetch trigger words automatically, hide unused LoRAs
- **Model browsing** — browse available checkpoints, LoRAs, and ControlNet models from each server
- **Generation queue** — queue multiple jobs, cancel or retry individual jobs
- **Auto Image mode** — automated batch generation with LLM-assisted prompt generation
- **LLM integration** — connect to OpenAI-compatible LLM servers (LM Studio, etc.) for prompt assistance
- **Gallery** — searchable, filterable gallery with collections, favorites, hidden images, and password-protected privacy lock
- **Studio** — organize generation sessions with persistent history per session
- **Prompt history** — quick access to previous prompts with one-click reuse
- **Hires-fix** — optional high-resolution fix pass on generated images
- **Responsive UI** — adaptive layout for phone, tablet, and desktop
- **Dark / Light / System theme** — follows system theme or override manually
- **Offline storage** — all data stored locally via Hive, no cloud dependency

## Screenshots

> TODO — add screenshots here

## Supported Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅ |
| iOS      | ✅ (no codesign in CI) |
| macOS    | ✅ |
| Linux    | ✅ |
| Windows  | ✅ |
| Web      | ✅ |

## Prerequisites

- Flutter stable channel (SDK ^3.12.2)
- Dart ^3.12.2
- A running ComfyUI instance accessible over the network
- (Optional) An OpenAI-compatible LLM server for Auto Image mode

## Installation

### Nightly Builds

Pre-built binaries are published automatically on every commit via GitHub Actions. Grab the latest from the [nightly release](https://github.com/openlyst/vidlatte-flutter/releases/tag/nightly).

### Building from Source

```bash
git clone https://github.com/openlyst/vidlatte-flutter.git
cd vidlatte-flutter
flutter pub get
flutter run
```

To build a release artifact for a specific platform:

```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build macos --release    # macOS
flutter build linux --release    # Linux
flutter build windows --release  # Windows
flutter build web --release      # Web
```

## Usage

1. Open the app and go to **Settings**
2. Add a ComfyUI server (URL, optional auth headers)
3. Tap the health check to verify connectivity
4. Go to **Create** and select a model from the dropdown
5. Enter a prompt, adjust settings (creativity, steps, dimensions, LoRAs) as needed
6. Tap **Generate** — images appear in the results panel and are saved to the gallery
7. (Optional) Enable **Auto Image** mode for LLM-assisted batch generation

For img2img or inpainting, toggle the mode in the create panel and provide a reference image.

## Architecture

Vidlatte uses a feature-based architecture with BLoC for state management:

```
lib/
├── app.dart                  # App entry point with BlocProvider setup
├── bloc/                     # BLoC layer (settings, servers, generation, gallery, studio, llm, autogen, prompt_history)
├── config/                   # Theme, constants, app config
├── data/                     # Models and data layer
├── i18n/                     # Localization (en, zh, ru)
├── presentation/             # UI layer
│   ├── navigation/           # GoRouter configuration
│   ├── pages/                # Create, Gallery, Studio, Settings, Browse, Inpaint
│   └── widgets/              # Reusable UI components
└── services/                 # ComfyUI service, LLM service, storage service
```

**Key technologies:**

- **State management:** flutter_bloc
- **Navigation:** go_router
- **HTTP:** dio, web_socket_channel
- **Storage:** Hive, shared_preferences, path_provider
- **UI:** Material 3, cached_network_image, photo_view, shimmer, flutter_staggered_grid_view

## Internationalization

The app supports English, Chinese (Simplified), and Russian. The language follows the system locale by default and can be overridden in Settings.

## Nightly Builds

A GitHub Actions workflow runs on every push to any branch. It builds all six platforms in parallel and publishes a GitHub release tagged `nightly` with all artifacts. The release is automatically replaced on each run, so it always reflects the latest commit.

If some platform builds fail, the release is still published as long as at least one build succeeds.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a merge request on GitLab

The repository is hosted on GitLab and mirrored to GitHub. Please open merge requests on GitLab.

## License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).
