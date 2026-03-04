# WebSocket (IM) 拦截功能使用指南

## 功能概述

新增了 WebSocket 拦截功能，可以监控和查看应用中的 IM（即时通讯）消息，包括 SocketRocket 等 WebSocket 库的收发内容。

## 支持的 WebSocket 库

- ✅ SocketRocket
- ✅ 其他基于 NSStream 的 WebSocket 实现
- ⚠️ 原生 URLSessionWebSocketTask（需要额外配置）

## 使用方法

### 1. 查看 WebSocket 消息

1. 长按悬浮按钮打开日志页面
2. 点击顶部的 **"IM"** 切换按钮
3. 即可看到所有 WebSocket 连接和消息记录

### 2. 消息类型

WebSocket 日志包含以下类型：

- 🔗 **连接** - WebSocket 连接建立
- 🔌 **断开** - WebSocket 连接关闭
- 📤 **发送** - 发送的消息
- 📥 **接收** - 接收的消息
- ❌ **错误** - 连接或传输错误

### 3. 过滤功能

在 IM 模式下，过滤器会自动切换为：

- 全部 - 显示所有消息
- 连接 - 只显示连接事件
- 发送 - 只显示发送的消息
- 接收 - 只显示接收的消息
- 错误 - 只显示错误信息

### 4. 搜索功能

可以搜索：
- WebSocket URL
- 消息内容
- 主机名

### 5. 查看详情

点击任意消息可以查看：
- 消息类型和时间
- 完整的 WebSocket URL
- 消息内容（自动格式化 JSON）
- 数据大小

## 技术实现

### Hook 机制

使用 Method Swizzling 技术 Hook SocketRocket 的关键方法：

```swift
// Hook 的方法
- open()      // 连接建立
- send(_:)    // 发送消息
- close()     // 关闭连接
```

### 数据记录

所有 WebSocket 消息都会被记录到内存中：
- 最多保存 1000 条记录
- 自动清理旧记录
- 支持实时更新

## 注意事项

### 1. 性能影响

WebSocket 拦截会略微增加消息处理的开销，建议：
- 仅在开发/测试环境使用
- 定期清空日志以释放内存

### 2. 隐私安全

IM 消息可能包含敏感信息：
- 不要在生产环境启用
- 不要截图或分享包含敏感信息的日志
- 使用编译条件控制：

```swift
#if DEBUG
WebSocketInterceptor.shared.startIntercepting()
#endif
```

### 3. 兼容性

如果你的项目使用了其他 WebSocket 库，可能需要：
- 修改 Hook 的类名
- 添加对应的 Swizzling 代码

## 自定义配置

### 修改最大记录数

```swift
WebSocketInterceptor.maxRecords = 500 // 默认 1000
```

### 添加自定义过滤

在 `WebSocketInterceptor.swift` 中添加过滤逻辑：

```swift
static func logSend(url: String, data: Any) {
    // 忽略心跳消息
    if let string = data as? String, string.contains("ping") {
        return
    }
    
    // 记录消息
    // ...
}
```

### Hook 其他 WebSocket 库

如果使用其他 WebSocket 库，可以添加对应的 Hook：

```swift
private func hookCustomWebSocket() {
    guard let socketClass = NSClassFromString("CustomWebSocket") else {
        return
    }
    
    // 添加 Swizzling 代码
}
```

## 常见问题

### Q: 为什么看不到 WebSocket 消息？

A: 可能的原因：
1. WebSocket 库不是 SocketRocket
2. Hook 失败（检查控制台日志）
3. 使用了原生的 URLSessionWebSocketTask

### Q: 如何拦截原生 URLSessionWebSocketTask？

A: 需要使用 URLProtocol 或 Hook URLSession 的 webSocketTask 方法。

### Q: 消息内容显示乱码怎么办？

A: 可能是二进制数据，可以在详情页面查看原始数据。

### Q: 如何导出 IM 日志？

A: 目前 IM 日志暂不支持导出，可以通过详情页面的"复制"功能复制单条消息。

## 示例代码

### 测试 WebSocket 连接

```swift
import SocketRocket

class TestViewController: UIViewController, SRWebSocketDelegate {
    var socket: SRWebSocket?
    
    func testWebSocket() {
        let url = URL(string: "wss://echo.websocket.org")!
        socket = SRWebSocket(url: url)
        socket?.delegate = self
        socket?.open()
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        print("WebSocket 已连接")
        webSocket.send("Hello, WebSocket!")
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        print("收到消息: \(message)")
    }
}
```

运行后，在 IM 日志中可以看到：
1. 🔗 连接到 wss://echo.websocket.org
2. 📤 发送 "Hello, WebSocket!"
3. 📥 接收 "Hello, WebSocket!"

## 更新日志

### v1.0.0
- ✅ 支持 SocketRocket 拦截
- ✅ 支持连接、发送、接收、断开、错误事件
- ✅ 支持 JSON 自动格式化
- ✅ 支持搜索和过滤
- ✅ 支持详情查看和复制

## 反馈

如有问题或建议，欢迎提交 Issue！
