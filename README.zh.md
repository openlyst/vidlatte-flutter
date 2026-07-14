# Vidlatte

[English](README.md) | [Русский](README.ru.md)

独立的 AI 图像生成应用，由 ComfyUI 驱动。连接一个或多个 ComfyUI 服务器，全面控制模型、LoRA、ControlNet 等参数，通过简洁的跨平台 Flutter 界面生成图像。

![许可证](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)
![平台](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Web-lightgrey.svg)
![Flutter](https://img.shields.io/badge/Flutter-stable-blue.svg)
![夜间构建](https://img.shields.io/badge/release-nightly-orange.svg)

## 功能

- **多服务器支持** — 连接多个 ComfyUI 实例，随时切换
- **文生图和图生图** — 完整的 txt2img 和 img2img 工作流，支持参考图上传
- **局部重绘** — 基于遮罩的 inpainting，可调整画笔大小和重绘强度
- **ControlNet** — 应用 ControlNet 模型，支持控制图和强度调节
- **LoRA 管理** — 选择多个 LoRA 并独立控制权重，自动获取触发词，隐藏不常用的 LoRA
- **模型浏览** — 浏览每个服务器上可用的检查点、LoRA 和 ControlNet 模型
- **生成队列** — 排队多个任务，可取消或重试单个任务
- **自动生图模式** — 结合 LLM 自动生成提示词的批量生成
- **LLM 集成** — 连接 OpenAI 兼容的 LLM 服务器（LM Studio 等）辅助生成提示词
- **画廊** — 可搜索、可筛选的画廊，支持合集、收藏、隐藏图片和密码保护的隐私锁
- **工作室** — 按会话组织生成历史，每个会话独立保存
- **提示词历史** — 快速访问之前的提示词，一键复用
- **高清修复** — 可选的高分辨率修复 pass
- **响应式界面** — 自适应手机、平板和桌面布局
- **深色 / 浅色 / 跟随系统主题** — 跟随系统主题或手动切换
- **离线存储** — 所有数据通过 Hive 本地存储，不依赖云端

## 截图

> TODO — 待添加截图

## 支持平台

| 平台 | 状态 |
|------|------|
| Android | ✅ |
| iOS | ✅（CI 中不签名） |
| macOS | ✅ |
| Linux | ✅ |
| Windows | ✅ |
| Web | ✅ |

## 前置条件

- Flutter stable 通道（SDK ^3.12.2）
- Dart ^3.12.2
- 一个可通过网络访问的 ComfyUI 实例
- （可选）OpenAI 兼容的 LLM 服务器，用于自动生图模式

## 安装

### 夜间构建

每次提交代码后，GitHub Actions 会自动构建并发布预编译的二进制文件。从 [nightly release](https://github.com/openlyst/vidlatte-flutter/releases/tag/nightly) 获取最新版本。

### 从源码构建

```bash
git clone https://github.com/openlyst/vidlatte-flutter.git
cd vidlatte-flutter
flutter pub get
flutter run
```

构建指定平台的 release 产物：

```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build macos --release    # macOS
flutter build linux --release    # Linux
flutter build windows --release  # Windows
flutter build web --release      # Web
```

## 使用方法

1. 打开应用，进入 **设置**
2. 添加 ComfyUI 服务器（URL，可选认证头）
3. 点击健康检查确认连接正常
4. 进入 **创建** 页面，从下拉菜单选择模型
5. 输入提示词，按需调整设置（创意度、步数、尺寸、LoRA）
6. 点击 **生成** — 图像出现在结果面板并自动保存到画廊
7. （可选）开启 **自动生图** 模式，使用 LLM 辅助批量生成

图生图或局部重绘：在创建面板中切换模式并提供参考图。

## 架构

Vidlatte 采用基于功能的架构，使用 BLoC 进行状态管理：

```
lib/
├── app.dart                  # 应用入口，BlocProvider 配置
├── bloc/                     # BLoC 层（设置、服务器、生成、画廊、工作室、LLM、自动生成、提示词历史）
├── config/                   # 主题、常量、应用配置
├── data/                     # 数据模型层
├── i18n/                     # 国际化（en、zh、ru）
├── presentation/             # UI 层
│   ├── navigation/           # GoRouter 路由配置
│   ├── pages/                # 创建、画廊、工作室、设置、浏览、局部重绘
│   └── widgets/              # 可复用 UI 组件
└── services/                 # ComfyUI 服务、LLM 服务、存储服务
```

**核心技术栈：**

- **状态管理：** flutter_bloc
- **导航：** go_router
- **网络：** dio, web_socket_channel
- **存储：** Hive, shared_preferences, path_provider
- **UI：** Material 3, cached_network_image, photo_view, shimmer, flutter_staggered_grid_view

## 国际化

应用支持英语、简体中文和俄语。默认跟随系统语言，也可在设置中手动切换。

## 夜间构建

GitHub Actions 工作流在每次推送到任意分支时运行，并行构建全部六个平台并发布标记为 `nightly` 的 GitHub Release，包含所有构建产物。每次运行会自动替换之前的 release，始终反映最新提交。

如果部分平台构建失败，只要至少一个平台构建成功，release 仍会发布。

## 贡献

1. Fork 本仓库
2. 创建功能分支（`git checkout -b feature/my-feature`）
3. 提交更改
4. 推送到分支（`git push origin feature/my-feature`）
5. 在 GitLab 上提交合并请求

本仓库托管在 GitLab 并镜像到 GitHub，请在 GitLab 上提交合并请求。

## 许可证

本项目基于 [GNU Affero General Public License v3.0](LICENSE) 许可证。
