# WebSocket 拦截功能说明

## ⚠️ 重要提示

WebSocket 拦截是**实验性功能**，默认已禁用。由于 Method Swizzling 在某些环境下可能不稳定，建议谨慎使用。

## 为什么默认禁用？

经过大量测试发现，WebSocket 拦截在以下情况下可能崩溃：
- 高频消息场景（每秒 100+ 条）
- 特定的 SocketRocket 版本
- 某些线程环境
- 对象释放时机问题

## 如何启用？

如果你确实需要 WebSocket 拦截功能，可以这样启用：

```swift
// 方式 1：使用配置
var config = ZWBLogTap.Configuration()
config.interceptWebSocket = true  // 启用 WebSocket 拦截
ZWBLogTap.shared.start(with: config)

// 方式 2：使用便捷方法
ZWBLogTap.start(
    interceptHTTP: true,
    interceptWebSocket: true  // 启用 WebSocket 拦截
)
```

## 稳定性建议

1. **仅在开发环境使用** - 不要在生产环境启用
2. **小范围测试** - 先在简单场景测试
3. **监控崩溃** - 如遇崩溃立即禁用
4. **HTTP 拦截稳定** - HTTP 拦截功能完全稳定，可放心使用

## 技术细节

WebSocket 拦截使用 Method Swizzling 技术拦截 SocketRocket 的方法调用。由于 Swizzling 在运行时修改方法实现，在某些极端情况下可能与 Swift 运行时冲突。

## 替代方案

如果 WebSocket 拦截不稳定，建议：
1. 只使用 HTTP 拦截功能
2. 使用 Charles/Proxyman 等专业工具调试 WebSocket
3. 在 WebSocket 代码中手动添加日志
