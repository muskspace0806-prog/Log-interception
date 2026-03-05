# WebSocket 日志快速指南

## 5 行代码搞定 WebSocket 日志

### 1. 连接时
```swift
webSocket?.open()
ZWBLogTap.logWebSocketConnect(url: "wss://example.com")
```

### 2. 发送时
```swift
webSocket?.send(message)
ZWBLogTap.logWebSocketSend(url: "wss://example.com", message: message)
```

### 3. 接收时
```swift
func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
    ZWBLogTap.logWebSocketReceive(url: "wss://example.com", message: message)
}
```

### 4. 断开时
```swift
func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
    ZWBLogTap.logWebSocketDisconnect(url: "wss://example.com", reason: reason)
}
```

### 5. 错误时
```swift
func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
    ZWBLogTap.logWebSocketError(url: "wss://example.com", error: error.localizedDescription)
}
```

## 完成！

点击悬浮按钮 → 切换到 "IM" 标签 → 查看所有 WebSocket 日志

详细文档：[WEBSOCKET_MANUAL_LOGGING.md](WEBSOCKET_MANUAL_LOGGING.md)
