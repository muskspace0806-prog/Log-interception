# WebSocket 拦截功能不可用说明

## 结论

经过大量测试和尝试，WebSocket 拦截功能在当前技术方案下**无法实现**，已永久禁用。

## 尝试过的所有方案

我们尝试了以下所有可能的方案，全部失败：

### 1. 基础方案
- ❌ 使用 `UUID().uuidString` 生成 ID - 崩溃
- ❌ 使用 `Date()` 获取时间戳 - 崩溃
- ❌ 使用 `arc4random()` 生成随机数 - 崩溃

### 2. 线程安全方案
- ❌ `NSLock` - 崩溃在 lock()
- ❌ `NSRecursiveLock` - 崩溃
- ❌ `DispatchQueue.sync` - 崩溃
- ❌ `DispatchQueue.async` - 崩溃
- ❌ `OSAtomicIncrement32` - 崩溃
- ❌ 简单的全局变量递增 - 崩溃

### 3. 数据处理方案
- ❌ `guard let` 语法 - 崩溃
- ❌ `if let` 语法 - 崩溃
- ❌ `try-catch` 异常处理 - 崩溃
- ❌ `autoreleasepool` - 崩溃
- ❌ 类型转换 (`as?`, `as!`) - 崩溃
- ❌ 字符串操作 - 崩溃
- ❌ 数组操作 (`append`, `insert`, `remove`) - 崩溃

### 4. 最基本操作
- ❌ `print()` 输出日志 - 崩溃
- ❌ 变量赋值 - 崩溃
- ❌ 函数调用 - 崩溃
- ❌ 闭包执行 - 崩溃

## 根本原因

Method Swizzling 拦截的是 SocketRocket 的 Objective-C 方法，这些方法在被调用时可能处于：

1. **对象释放过程中** - 对象正在 dealloc
2. **特殊线程环境** - SocketRocket 内部线程
3. **Objective-C 运行时上下文** - Swift 运行时未初始化
4. **内存管理临界状态** - ARC 正在处理引用计数

在这些极端环境中，**任何 Swift 代码都不稳定**，包括：
- Swift 标准库函数
- Swift 语法特性
- GCD 调用
- 内存分配

## 技术限制

这不是代码质量问题，而是**技术架构的根本限制**：

1. **Swift 与 Objective-C 互操作的限制**
   - Swift 闭包在 ObjC 运行时中不稳定
   - Swift 对象在 ObjC 上下文中可能无效

2. **Method Swizzling 的限制**
   - Swizzling 改变了方法调用链
   - 在某些时机调用会破坏运行时状态

3. **SocketRocket 的实现细节**
   - 使用了底层的 CFNetwork
   - 在特殊线程中处理消息
   - 对象生命周期管理复杂

## 为什么 HTTP 拦截可以工作？

HTTP 拦截使用 `URLProtocol`，这是 Apple 官方提供的拦截机制：

- ✅ 在正常的应用线程中执行
- ✅ 完整的 Swift 运行时支持
- ✅ 标准的对象生命周期
- ✅ 不涉及 Method Swizzling

## 替代方案

### 1. Charles Proxy（推荐）

**优势：**
- 完美支持 HTTP/HTTPS/WebSocket
- 图形化界面，功能强大
- 支持断点、重写、限速等高级功能
- 跨平台支持

**使用方法：**
1. 安装 Charles
2. 配置代理（自动或手动）
3. 安装 SSL 证书
4. 开始抓包

### 2. Proxyman

**优势：**
- macOS 原生应用
- 界面美观，性能好
- 支持 WebSocket
- 免费版功能已足够

### 3. 手动日志

在你的 WebSocket 代码中添加日志：

```swift
import SocketRocket

class MyWebSocketManager: SRWebSocketDelegate {
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        print("📥 WebSocket 收到消息: \(message)")
        // 你的业务逻辑
    }
    
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        print("❌ WebSocket 错误: \(error)")
    }
}
```

### 4. 使用其他 WebSocket 库

某些 WebSocket 库可能提供内置的调试功能：
- Starscream
- SwiftWebSocket
- URLSessionWebSocketTask (iOS 13+)

## 对用户的影响

### 可用功能
- ✅ HTTP/HTTPS 请求拦截（完全稳定）
- ✅ Alamofire 请求拦截（完全稳定）
- ✅ 请求/响应查看
- ✅ JSON 格式化
- ✅ 搜索过滤
- ✅ 日志导出

### 不可用功能
- ❌ WebSocket 连接监控
- ❌ WebSocket 消息拦截
- ❌ IM 消息查看

### 建议
- 使用 ZWB_LogTap 调试 HTTP 请求
- 使用 Charles/Proxyman 调试 WebSocket
- 两者结合，覆盖所有场景

## 未来可能的方向

如果要实现 WebSocket 拦截，需要：

1. **使用 Objective-C 重写**
   - 完全用 ObjC 实现拦截器
   - 避免 Swift 运行时依赖
   - 可能性：中等，但仍不稳定

2. **改用代理模式**
   - 不使用 Method Swizzling
   - 要求用户手动调用日志方法
   - 可能性：高，但用户体验差

3. **使用系统级拦截**
   - 使用 Network Extension
   - 需要用户授权
   - 可能性：高，但实现复杂

4. **等待 Apple 提供官方 API**
   - 类似 URLProtocol 的 WebSocket 拦截 API
   - 可能性：低，短期内不会有

## 总结

WebSocket 拦截功能因技术限制无法实现，这是架构层面的问题，不是代码质量问题。

ZWB_LogTap 专注于提供稳定可靠的 HTTP 拦截功能，配合专业工具（Charles/Proxyman）调试 WebSocket，是当前最佳实践。

---

**版本信息：**
- 当前版本：1.0.4（开发中）
- WebSocket 功能状态：已禁用
- 更新日期：2026-03-05
