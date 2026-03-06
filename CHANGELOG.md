# Changelog

All notable changes to ZWB_LogTap will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
