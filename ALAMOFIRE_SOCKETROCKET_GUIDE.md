# Alamofire 和 SocketRocket 拦截指南

## 支持的库

ZWB_LogTap 现已支持拦截以下网络库：

- ✅ **URLSession** - 原生网络库（完全支持）
- ✅ **Alamofire** - 流行的 HTTP 网络库（完全支持）
- ⚠️ **SocketRocket** - WebSocket 库（实验性支持）

## Alamofire 拦截

### 工作原理

Alamofire 使用自定义的 `URLSessionConfiguration`，ZWB_LogTap 通过 Method Swizzling 自动注入 `URLProtocol` 到所有配置中。

### 使用方法

无需任何额外配置，正常启动即可：

```swift
import ZWB_LogTap

// 在 AppDelegate 中
ZWBLogTap.startIfDebug()
```

### 验证拦截

启动后，控制台会显示：

```
✅ 网络拦截已启动（URLProtocol + Swizzling + Alamofire）
✅ 检测到 Alamofire，正在注入拦截器...
✅ URLSessionConfiguration Hook 成功
```

### Alamofire 请求示例

所有 Alamofire 请求都会被自动拦截：

```swift
import Alamofire

// GET 请求
AF.request("https://api.example.com/users").response { response in
    // 这个请求会被 ZWB_LogTap 拦截
}

// POST 请求
AF.request("https://api.example.com/login", 
           method: .post,
           parameters: ["username": "test", "password": "123456"],
           encoding: JSONEncoding.default).response { response in
    // 这个请求也会被拦截
}

// 上传
AF.upload(data, to: "https://api.example.com/upload").response { response in
    // 上传请求也会被拦截
}
```

## SocketRocket 拦截

### ⚠️ 重要提示

SocketRocket 拦截是**实验性功能**，默认禁用。需要手动启用。

### 启用方法

```swift
import ZWB_LogTap

var config = ZWBLogTap.Configuration()
config.interceptWebSocket = true  // 启用 WebSocket 拦截
ZWBLogTap.shared.start(with: config)
```

### 支持的 SocketRocket 版本

- ✅ SocketRocket 0.7.1（你的版本）
- ✅ SocketRocket 0.6.x
- ✅ SocketRocket 0.5.x

### Hook 的方法

ZWB_LogTap 会尝试 Hook 以下方法：

1. `open` - 连接建立
2. `send:` - 发送消息（通用）
3. `sendString:` - 发送字符串
4. `sendData:` - 发送二进制数据
5. `close` - 关闭连接
6. `closeWithCode:reason:` - 带原因关闭

### 验证拦截

启动后，控制台会显示：

```
⚠️ WebSocket 拦截是实验性功能，可能导致崩溃
⚠️ 如遇到问题，请使用 interceptWebSocket: false 禁用
ℹ️ 检测到 SocketRocket，正在 Hook...
  ✅ Hook open 成功
  ✅ Hook send: 成功
  ✅ Hook sendString: 成功
  ✅ Hook sendData: 成功
  ✅ Hook close 成功
✅ SocketRocket Hook 完成（实验性）
```

### SocketRocket 使用示例

```swift
import SocketRocket

let socket = SRWebSocket(url: URL(string: "wss://echo.websocket.org")!)
socket.delegate = self
socket.open()  // 会被拦截

// 发送消息
socket.send("Hello")  // 会被拦截
socket.sendString("World")  // 会被拦截

// 关闭
socket.close()  // 会被拦截
```

## 故障排查

### Alamofire 请求没有被拦截

1. **检查启动时机** - 确保在创建 Alamofire Session 之前启动 ZWB_LogTap
   ```swift
   // ❌ 错误：先创建 Session
   let session = Session.default
   ZWBLogTap.startIfDebug()
   
   // ✅ 正确：先启动拦截
   ZWBLogTap.startIfDebug()
   let session = Session.default
   ```

2. **检查控制台日志** - 确认是否显示 "检测到 Alamofire"

3. **尝试重启应用** - 有时需要完全重启应用

### SocketRocket 消息没有被拦截

1. **确认已启用** - 检查 `interceptWebSocket = true`

2. **查看控制台** - 确认 Hook 是否成功

3. **如果崩溃** - 立即禁用 WebSocket 拦截
   ```swift
   config.interceptWebSocket = false
   ```

4. **使用替代方案** - 考虑使用 Charles/Proxyman

### 部分请求没有被拦截

某些情况下请求可能无法被拦截：

- ❌ 使用了 `URLSession` 的 `ephemeralConfiguration` 且禁用了 `protocolClasses`
- ❌ 使用了底层的 `CFNetwork` API
- ❌ 使用了第三方的 C/C++ 网络库
- ❌ WebSocket 使用了非 SocketRocket 的实现

## 性能影响

### Alamofire 拦截
- 性能影响：< 1%
- 内存占用：每个请求约 1-5KB
- 推荐使用：✅ 是

### SocketRocket 拦截
- 性能影响：< 5%
- 内存占用：每条消息约 1-10KB
- 推荐使用：⚠️ 谨慎使用

## 最佳实践

1. **仅在 Debug 模式使用**
   ```swift
   #if DEBUG
   ZWBLogTap.startIfDebug()
   #endif
   ```

2. **限制记录数量**
   ```swift
   var config = ZWBLogTap.Configuration()
   config.maxRecords = 500  // 限制最多 500 条
   ```

3. **定期清空日志**
   ```swift
   // 在适当的时候清空
   ZWBLogTap.shared.clearAllLogs()
   ```

4. **WebSocket 谨慎启用**
   - 先在简单场景测试
   - 监控是否有崩溃
   - 如有问题立即禁用

## 技术细节

### Alamofire 拦截原理

1. Hook `URLSessionConfiguration.protocolClasses` getter
2. 自动注入 `NetworkInterceptor` 到所有配置
3. Alamofire 创建 Session 时会使用被 Hook 的配置
4. 所有请求自动通过 `NetworkInterceptor`

### SocketRocket 拦截原理

1. 使用 Method Swizzling Hook SRWebSocket 的方法
2. 在方法调用前记录参数
3. 调用原始方法继续执行
4. 不影响原有功能

## 常见问题

**Q: 为什么 Alamofire 拦截是自动的？**
A: 因为 Alamofire 底层使用 URLSession，我们 Hook 了配置创建过程。

**Q: 可以只拦截 Alamofire 不拦截 URLSession 吗？**
A: 不可以，它们使用相同的拦截机制。

**Q: SocketRocket 拦截为什么不稳定？**
A: Method Swizzling 在某些极端情况下可能与 Swift 运行时冲突。

**Q: 有其他 WebSocket 库支持吗？**
A: 目前只支持 SocketRocket，其他库需要单独适配。

## 版本信息

- 当前版本：1.0.4（开发中）
- Alamofire 支持：✅ 稳定
- SocketRocket 支持：⚠️ 实验性
- 更新日期：2026-03-05
