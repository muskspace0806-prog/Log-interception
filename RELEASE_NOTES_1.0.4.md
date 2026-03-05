# ZWB_LogTap v1.0.4 Release Notes

## 🎉 主要更新

### ✅ 新增功能

- **Alamofire 自动拦截支持** - 无需配置，自动拦截所有 Alamofire 请求
- **WebSocket 手动日志记录 API** - 5 个简单方法，稳定可靠
  - `ZWBLogTap.logWebSocketConnect(url:)` - 记录连接
  - `ZWBLogTap.logWebSocketSend(url:message:)` - 记录发送
  - `ZWBLogTap.logWebSocketReceive(url:message:)` - 记录接收
  - `ZWBLogTap.logWebSocketDisconnect(url:reason:)` - 记录断开
  - `ZWBLogTap.logWebSocketError(url:error:)` - 记录错误

### ⚠️ 重要变更

- **WebSocket 自动拦截已禁用** - 由于 Method Swizzling 技术限制导致崩溃
- **改用手动日志记录方式** - 更稳定、零崩溃、易维护

### 🐛 Bug 修复

- 修复 URLSessionConfiguration Hook 的类型推断问题
- 修复详情页面标签按钮在小屏幕上被内容遮挡的问题
- 修复内容区域底部约束，确保填充到安全区域
- 修复 textView 内边距，避免与复制按钮重叠

### 🎨 UI 优化

- 优化详情页面布局，支持小屏幕设备
- 按钮容器高度增加到 120，可容纳三行按钮

### 📖 文档更新

- 新增 [WebSocket 手动日志记录完整指南](WEBSOCKET_MANUAL_LOGGING.md)
- 新增 [WebSocket 快速参考](QUICK_WEBSOCKET_GUIDE.md)
- 新增 [Alamofire 和 SocketRocket 支持说明](ALAMOFIRE_SOCKETROCKET_GUIDE.md)
- 新增 [WebSocket 技术限制说明](WEBSOCKET_NOT_SUPPORTED.md)
- 更新 README - 说明 WebSocket 使用方式和替代方案

## 📦 安装

### CocoaPods

```ruby
pod 'ZWB_LogTap', '~> 1.0.4', :configurations => ['Debug']
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/Log-interception.git", from: "1.0.4")
]
```

## 🚀 快速开始

### HTTP 拦截（自动）

```swift
import ZWB_LogTap

// 在 AppDelegate 中
ZWBLogTap.startIfDebug()
```

### WebSocket 日志（手动）

```swift
import SocketRocket
import ZWB_LogTap

func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
    // 📝 添加这一行记录日志
    ZWBLogTap.logWebSocketReceive(url: webSocket.url?.absoluteString ?? "", message: message)
    
    // 你的业务逻辑
}
```

## 🔗 链接

- **GitHub**: https://github.com/muskspace0806-prog/Log-interception
- **CocoaPods**: https://cocoapods.org/pods/ZWB_LogTap
- **完整文档**: [README.md](README.md)

## 💬 反馈

如有问题或建议，欢迎提交 [Issue](https://github.com/muskspace0806-prog/Log-interception/issues)

---

**发布日期**: 2026-03-05  
**版本**: 1.0.4
