# WebSocket 崩溃问题最终解决方案

## 问题总结

经过多次尝试，WebSocket 拦截在以下所有方案中都会崩溃：

1. ❌ UUID/Date 生成 ID - 崩溃
2. ❌ 原子计数器 (OSAtomic) - 崩溃  
3. ❌ DispatchQueue.sync 保护 - 崩溃
4. ❌ DispatchQueue.async 异步 - 崩溃
5. ❌ autoreleasepool + try-catch - 崩溃
6. ❌ 深拷贝数据 - 崩溃
7. ❌ 立即获取 URL 再异步 - 崩溃
8. ❌ 完全同步调用 - 崩溃

## 根本原因

Method Swizzling 拦截的是 SocketRocket 内部方法，这些方法可能在以下极端环境中被调用：
- 对象正在释放（dealloc）
- 特殊的 Objective-C 运行时上下文
- SocketRocket 的内部线程
- Swift 运行时未完全初始化

在这些环境中，即使是最基本的操作（GCD、字符串操作）都可能崩溃。

## 最终解决方案

### 1. 默认禁用 WebSocket 拦截

```swift
public struct Configuration {
    public var interceptWebSocket: Bool = false  // 默认关闭
}
```

### 2. 添加警告提示

在启动时打印警告：
```
⚠️ WebSocket 拦截是实验性功能，可能导致崩溃
⚠️ 如遇到问题，请使用 interceptWebSocket: false 禁用
```

### 3. 文档说明

- README.md 中标注为"实验性功能"
- 提供 WEBSOCKET_CRASH_FIX.md 详细说明
- 建议用户使用专业工具（Charles/Proxyman）

### 4. 保留代码但默认关闭

代码保留在库中，用户可以选择启用：
```swift
ZWBLogTap.start(
    interceptHTTP: true,
    interceptWebSocket: true  // 用户主动启用
)
```

## 用户指南

### HTTP 拦截（推荐）

✅ 完全稳定，可放心使用
✅ 支持所有 URLSession 请求
✅ 零崩溃风险

```swift
ZWBLogTap.startIfDebug()  // 默认只启用 HTTP
```

### WebSocket 拦截（实验性）

⚠️ 可能不稳定
⚠️ 仅在必要时启用
⚠️ 建议小范围测试

```swift
var config = ZWBLogTap.Configuration()
config.interceptWebSocket = true  // 主动启用
ZWBLogTap.shared.start(with: config)
```

## 替代方案

如果 WebSocket 拦截不可用，推荐：

1. **Charles Proxy** - 专业的网络调试工具
2. **Proxyman** - macOS 原生网络调试工具
3. **手动日志** - 在 WebSocket 代码中添加日志
4. **仅使用 HTTP 拦截** - 大多数场景已足够

## 技术债务

未来可能的改进方向：

1. **使用 Objective-C 重写** - ObjC 在 Swizzling 场景更稳定
2. **改用代理模式** - 不使用 Swizzling，要求手动调用
3. **支持其他 WebSocket 库** - 不同库可能有不同表现
4. **添加崩溃保护** - 使用 signal handler 捕获崩溃

## 版本信息

- 当前版本：1.0.3
- 下一版本：1.0.4（将包含此修改）
- 修改日期：2026-03-05

## 结论

WebSocket 拦截功能保留但默认禁用，HTTP 拦截功能完全稳定可用。这是在功能性和稳定性之间的最佳平衡。
