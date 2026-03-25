# Changelog

All notable changes to ZWB_LogTap will be documented in this file.

## [1.2.2] - 2026-03-18

### Added
- IM 列表消息行优先显示 `Route: roomMicCharmPush` 格式，字体加大加粗
- IM 过滤支持 route 字段匹配（过滤 heartbeat 同时过滤 IM 心跳消息）

### Changed
- 悬浮入口按钮从 40×40 放大至 50×50

## [1.2.1] - 2026-03-18

### Fixed
- 响应 Body 内容区域支持滚动，JSON 结构完整展示不截断
- 内容少时填满屏幕，内容多时自动撑高

## [1.2.0] - 2026-03-18

### Changed
- 首页工具栏 `过滤` 按钮改为 `切换`，点击直接弹出环境切换确认框
- URL 过滤功能移至调试工具列表（工具 → URL 过滤）

### Fixed
- IM 消息详情：URL、主机、路径为空时自动跳过，修复参数 UI 重叠问题

## [1.1.9] - 2026-03-18

### Fixed
- 修复重启后解密配置未生效的问题（解密配置设置移至 isEnabled 检查之前）



### Added
- 环境状态持久化：切换测试/正式环境后，重启 app 自动恢复上次的环境（蓝色/红色按钮）
- URL 过滤默认规则：首次安装自动写入 `/v1/heartbeat` 和 `format/webp`，用户可在 UI 中删除

### Changed
- `start()` 不再每次覆盖环境，优先恢复持久化的环境记录
- URL 参数从"URL 信息"标签迁移到"请求 Body"标签显示

### Fixed
- 修复 app 重启后环境重置为测试环境的问题
- 修复切换正式环境后解密配置未生效的问题


### Added
- 响应数据解密功能（支持 AES-128-CBC）
- 多环境解密配置（测试/正式环境可配置不同的 Key 和 IV）
- HTTP 响应 Body 自动解密
- WebSocket (IM) 消息自动解密
- URL 过滤功能（支持模糊匹配）
- URL 过滤规则管理（添加/删除/持久化）
- 新增 `AESCrypto.swift` - AES 加解密实现
- 新增 `URLFilterManager.swift` - URL 过滤管理器
- 新增 `URLFilterViewController.swift` - URL 过滤设置页面

### Changed
- URL 参数从"URL 信息"标签迁移到"请求 Body"标签显示
- HTTP 详情页默认显示"响应 Body"标签
- 优化按钮布局，"过滤"按钮移至左侧
- 调整浮动按钮底部距离，避免与 tabBar 重叠
- `EnvironmentManager` 支持多环境解密配置
- `InterceptedRequest` 和 `WebSocketMessage` 支持解密

### Fixed
- 修复浮动按钮可能与 tabBar 重叠的问题
- 优化按钮布局，避免拥挤

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.6] - 2026-03-06

### Added
- 🌍 环境切换功能 - 支持测试/正式环境快速切换
  - 悬浮按钮颜色区分（蓝色=测试，红色=正式）
  - 在"调试工具"页面新增"环境切换"入口
  - 提供闭包回调，用户可自定义切换后的逻辑
  - 支持 `.test`、`.production`、`.custom(String)` 三种环境类型
- 🛠️ 调试工具集成
  - 模拟弱网功能（断网、限速、延迟）
  - Crash 日志监控和查看
  - 内存监控（实时显示内存使用情况）
  - 悬浮窗实时显示监控数据
- 📤 分享功能 - 所有详情页面支持导出为 txt 文件分享

### Changed
- 🎨 优化入口按钮 - 尺寸调整为 40x40，更加精致
- 🎨 优化悬浮窗 - 使用独立 UIWindow 确保始终在最顶层
- 📝 "辅助"改名为"工具" - 更符合功能定位

### Fixed
- 🐛 修复悬浮窗在 iOS 13+ 无法显示的问题
- 🐛 修复详情页面分享按钮丢失的问题

### Improved
- 🚀 提升用户体验，功能更加完善和易用
- 🔧 环境管理更加灵活，支持多种使用场景

## [1.0.5] - 2026-03-06

### Changed
- 🎨 完善请求Body展示 - URL参数从"URL信息"tab迁移到"请求Body"tab中展示
- 📝 优化详情页面布局 - "URL信息"tab现在只显示完整URL
- 📝 "请求Body"tab现在先显示URL参数，再显示请求Body内容

### Improved
- 🚀 提升用户体验，信息展示更加合理和直观

## [1.0.4] - 2026-03-05

### Added
- ✅ Alamofire 自动拦截支持 - 无需配置，自动拦截所有 Alamofire 请求
- ✅ WebSocket 手动日志记录 API - 5 个简单方法，稳定可靠
  - `ZWBLogTap.logWebSocketConnect(url:)` - 记录连接
  - `ZWBLogTap.logWebSocketSend(url:message:)` - 记录发送
  - `ZWBLogTap.logWebSocketReceive(url:message:)` - 记录接收
  - `ZWBLogTap.logWebSocketDisconnect(url:reason:)` - 记录断开
  - `ZWBLogTap.logWebSocketError(url:error:)` - 记录错误

### Changed
- ⚠️ WebSocket 自动拦截已禁用 - 由于 Method Swizzling 技术限制导致崩溃
- 📝 改用手动日志记录方式 - 更稳定、零崩溃、易维护
- 🎨 优化详情页面布局 - 支持小屏幕设备，按钮容器高度增加到 120

### Fixed
- 🐛 修复 URLSessionConfiguration Hook 的类型推断问题
- 🐛 修复详情页面标签按钮在小屏幕上被内容遮挡的问题
- 🐛 修复内容区域底部约束，确保填充到安全区域
- 🐛 修复 textView 内边距，避免与复制按钮重叠

### Documentation
- 📖 新增 [WebSocket 手动日志记录完整指南](WEBSOCKET_MANUAL_LOGGING.md)
- 📖 新增 [WebSocket 快速参考](QUICK_WEBSOCKET_GUIDE.md)
- 📖 新增 [Alamofire 和 SocketRocket 支持说明](ALAMOFIRE_SOCKETROCKET_GUIDE.md)
- 📖 新增 [WebSocket 技术限制说明](WEBSOCKET_NOT_SUPPORTED.md)
- 📖 更新 README - 说明 WebSocket 使用方式和替代方案

## [1.0.3] - 2026-03-04

### Added
- ✅ 错误请求 URL 自动标红显示
  - HTTP 请求失败（404、500 等状态码）URL 显示为红色
  - 网络错误（超时、无效域名等）URL 显示为红色
  - WebSocket 错误消息 URL 和内容显示为红色
  - 一眼识别失败请求，快速定位问题

### Improved
- 🎨 优化错误请求的视觉展示效果
- 🚀 提升调试体验，更易发现和排查问题

## [1.0.2] - 2026-03-04

### Added
- 🎉 初始版本发布
- ✅ HTTP/HTTPS 请求拦截功能
  - 支持 URLSession 所有请求
  - 支持 Alamofire、AFNetworking 等第三方库
  - 自动记录请求和响应数据
- ✅ WebSocket 拦截功能
  - 支持 SocketRocket 库
  - 监控连接、发送、接收、断开、错误事件
  - 实时显示消息内容
- ✅ 悬浮按钮 UI
  - 可拖拽移动
  - 自动吸附到屏幕边缘
  - 点击打开日志页面
- ✅ 日志列表页面
  - HTTP/IM 模式切换
  - 搜索功能
  - 过滤功能（按方法、状态、类型）
  - 清空日志
  - 导出 JSON
- ✅ 日志详情页面
  - 7 个标签页（基本信息、URL、Headers、Body 等）
  - JSON 自动格式化
  - 复制功能
- ✅ 核心功能
  - 零配置启动
  - 仅 Debug 模式
  - 内存管理（最多 1000 条记录）
  - 线程安全

### Technical Details
- iOS 13.0+ 支持
- Swift 5.0
- 基于 URLProtocol 实现 HTTP 拦截
- 基于 Method Swizzling 实现 WebSocket 拦截
- 使用 UIKit 构建 UI

## [Unreleased]

### Planned
- [ ] 支持 gRPC 拦截
- [ ] 支持 GraphQL 查询格式化
- [ ] 添加性能分析功能
- [ ] 支持自定义主题
- [ ] 添加请求重放功能
- [ ] 支持 Mock 数据
- [ ] 添加统计图表
- [ ] 支持导出为 HAR 格式
- [ ] 添加请求对比功能
- [ ] 支持 cURL 命令导出

---

[1.0.3]: https://github.com/muskspace0806-prog/Log-interception/releases/tag/1.0.3
[1.0.2]: https://github.com/muskspace0806-prog/Log-interception/releases/tag/1.0.2
