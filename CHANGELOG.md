# Changelog

All notable changes to ZWB_LogTap will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
