# WebSocket 手动日志记录指南

## 概述

由于自动拦截技术限制，ZWB_LogTap 提供了**手动日志记录 API**，让你在 SocketRocket 的代码中轻松添加日志。

## 优势

✅ **完全稳定** - 不使用 Method Swizzling，零崩溃风险  
✅ **简单易用** - 只需添加几行代码  
✅ **完整功能** - 支持所有 WebSocket 事件  
✅ **零性能影响** - 只在 Debug 模式下生效  

## 快速开始

### 1. 在 SocketRocket Delegate 中添加日志

```swift
import SocketRocket
import ZWB_LogTap

class MyWebSocketManager: NSObject, SRWebSocketDelegate {
    
    var webSocket: SRWebSocket?
    let wsURL = "wss://echo.websocket.org"
    
    // 连接
    func connect() {
        let url = URL(string: wsURL)!
        webSocket = SRWebSocket(url: url)
        webSocket?.delegate = self
        webSocket?.open()
        
        // 📝 记录连接
        ZWBLogTap.logWebSocketConnect(url: wsURL)
    }
    
    // 发送消息
    func sendMessage(_ message: String) {
        webSocket?.send(message)
        
        // 📝 记录发送
        ZWBLogTap.logWebSocketSend(url: wsURL, message: message)
    }
    
    // MARK: - SRWebSocketDelegate
    
    // 连接成功
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        print("WebSocket 已连接")
    }
    
    // 接收消息
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        // 📝 记录接收
        ZWBLogTap.logWebSocketReceive(url: wsURL, message: message)
        
        // 你的业务逻辑
        if let text = message as? String {
            print("收到文本: \(text)")
        } else if let data = message as? Data {
            print("收到数据: \(data.count) bytes")
        }
    }
    
    // 连接失败
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        // 📝 记录错误
        ZWBLogTap.logWebSocketError(url: wsURL, error: error.localizedDescription)
        
        print("WebSocket 错误: \(error)")
    }
    
    // 连接关闭
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        // 📝 记录断开
        let reasonText = reason ?? "正常关闭 (code: \(code))"
        ZWBLogTap.logWebSocketDisconnect(url: wsURL, reason: reasonText)
        
        print("WebSocket 已关闭")
    }
}
```

### 2. 查看日志

运行应用后，点击悬浮按钮，切换到 "IM" 标签，就能看到所有 WebSocket 日志了！

## API 参考

### 连接事件

```swift
// 记录 WebSocket 连接
ZWBLogTap.logWebSocketConnect(url: "wss://example.com")
```

### 发送消息

```swift
// 发送文本
ZWBLogTap.logWebSocketSend(url: "wss://example.com", message: "Hello")

// 发送数据
let data = "Hello".data(using: .utf8)!
ZWBLogTap.logWebSocketSend(url: "wss://example.com", message: data)
```

### 接收消息

```swift
// 接收文本
ZWBLogTap.logWebSocketReceive(url: "wss://example.com", message: "World")

// 接收数据
ZWBLogTap.logWebSocketReceive(url: "wss://example.com", message: data)
```

### 断开连接

```swift
// 正常断开
ZWBLogTap.logWebSocketDisconnect(url: "wss://example.com")

// 带原因断开
ZWBLogTap.logWebSocketDisconnect(url: "wss://example.com", reason: "用户主动关闭")
```

### 错误事件

```swift
// 记录错误
ZWBLogTap.logWebSocketError(url: "wss://example.com", error: "连接超时")
```

## 完整示例

### 简单的聊天应用

```swift
import UIKit
import SocketRocket
import ZWB_LogTap

class ChatViewController: UIViewController {
    
    var webSocket: SRWebSocket?
    let wsURL = "wss://chat.example.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectWebSocket()
    }
    
    func connectWebSocket() {
        let url = URL(string: wsURL)!
        webSocket = SRWebSocket(url: url)
        webSocket?.delegate = self
        webSocket?.open()
        
        // 记录连接
        ZWBLogTap.logWebSocketConnect(url: wsURL)
    }
    
    func sendChatMessage(_ text: String) {
        let message = ["type": "chat", "text": text]
        if let jsonData = try? JSONSerialization.data(withJSONObject: message),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webSocket?.send(jsonString)
            
            // 记录发送
            ZWBLogTap.logWebSocketSend(url: wsURL, message: jsonString)
        }
    }
}

extension ChatViewController: SRWebSocketDelegate {
    
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        print("✅ 聊天服务器已连接")
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        // 记录接收
        ZWBLogTap.logWebSocketReceive(url: wsURL, message: message)
        
        // 处理消息
        if let text = message as? String,
           let data = text.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            handleChatMessage(json)
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        // 记录错误
        ZWBLogTap.logWebSocketError(url: wsURL, error: error.localizedDescription)
        
        print("❌ 连接失败: \(error)")
    }
    
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        // 记录断开
        ZWBLogTap.logWebSocketDisconnect(url: wsURL, reason: reason)
        
        print("🔌 连接已断开")
    }
    
    func handleChatMessage(_ json: [String: Any]) {
        // 你的业务逻辑
    }
}
```

## 最佳实践

### 1. 只在 Debug 模式记录

```swift
func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
    #if DEBUG
    ZWBLogTap.logWebSocketReceive(url: wsURL, message: message)
    #endif
    
    // 业务逻辑
}
```

### 2. 封装日志方法

```swift
class WebSocketLogger {
    static func log(event: String, url: String, data: Any? = nil) {
        #if DEBUG
        switch event {
        case "connect":
            ZWBLogTap.logWebSocketConnect(url: url)
        case "send":
            if let data = data {
                ZWBLogTap.logWebSocketSend(url: url, message: data)
            }
        case "receive":
            if let data = data {
                ZWBLogTap.logWebSocketReceive(url: url, message: data)
            }
        case "disconnect":
            ZWBLogTap.logWebSocketDisconnect(url: url, reason: data as? String)
        case "error":
            if let error = data as? String {
                ZWBLogTap.logWebSocketError(url: url, error: error)
            }
        default:
            break
        }
        #endif
    }
}

// 使用
WebSocketLogger.log(event: "connect", url: wsURL)
WebSocketLogger.log(event: "send", url: wsURL, data: message)
```

### 3. 使用扩展简化调用

```swift
extension SRWebSocket {
    var urlString: String {
        return url?.absoluteString ?? "unknown"
    }
    
    func logSend(_ message: Any) {
        #if DEBUG
        ZWBLogTap.logWebSocketSend(url: urlString, message: message)
        #endif
        send(message)
    }
}

// 使用
webSocket?.logSend("Hello")  // 自动记录并发送
```

## 与自动拦截的对比

| 特性 | 自动拦截 | 手动记录 |
|------|---------|---------|
| 稳定性 | ❌ 崩溃 | ✅ 完全稳定 |
| 易用性 | ✅ 零配置 | ⚠️ 需要添加代码 |
| 性能 | ❌ 有影响 | ✅ 几乎无影响 |
| 灵活性 | ❌ 固定 | ✅ 可自定义 |
| 维护性 | ❌ 难维护 | ✅ 易维护 |

## 常见问题

**Q: 需要在每个地方都添加日志吗？**  
A: 只需要在 SocketRocket 的 delegate 方法中添加，通常只有 3-5 个地方。

**Q: 会影响性能吗？**  
A: 几乎没有影响，而且可以用 `#if DEBUG` 确保只在开发环境生效。

**Q: 可以记录二进制数据吗？**  
A: 可以，ZWB_LogTap 会自动处理 Data 类型。

**Q: 如何查看日志？**  
A: 点击悬浮按钮，切换到 "IM" 标签即可。

**Q: 可以导出日志吗？**  
A: 可以，点击 "导出" 按钮即可导出为 JSON。

## 工作量评估

对于一个典型的 WebSocket 实现：

- ✅ 添加连接日志：1 行代码
- ✅ 添加发送日志：1 行代码
- ✅ 添加接收日志：1 行代码
- ✅ 添加断开日志：1 行代码
- ✅ 添加错误日志：1 行代码

**总计：5 行代码，5 分钟完成！**

## 总结

手动日志记录是 WebSocket 调试的最佳方案：

- ✅ 完全稳定可靠
- ✅ 工作量极小
- ✅ 功能完整
- ✅ 易于维护

配合 ZWB_LogTap 的 HTTP 自动拦截，你可以轻松调试所有网络请求！

---

**版本信息：**
- 当前版本：1.0.4（开发中）
- 更新日期：2026-03-05
