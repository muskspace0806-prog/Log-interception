# iOS 网络日志拦截工具

一个功能强大的 iOS 网络请求拦截和日志查看工具，类似 Android 的 HTTP 拦截工具。

## 功能特性

### 核心功能
- ✅ 拦截所有 URLSession 网络请求（包括 GET、POST、PUT、DELETE 等）
- ✅ 拦截 WebSocket 连接和消息（支持 SocketRocket）
- ✅ 实时记录请求和响应数据
- ✅ 实时记录 IM 消息收发
- ✅ 支持查看请求/响应 Headers
- ✅ 支持查看请求/响应 Body（JSON 自动格式化）
- ✅ 支持查看 WebSocket 消息内容
- ✅ 显示请求耗时和状态码
- ✅ 支持搜索和过滤功能
- ✅ 支持导出日志为 JSON 格式
- ✅ HTTP/IM 日志分类查看

### UI 特性
- 🎯 可拖拽的悬浮按钮入口
- 🎯 点击悬浮按钮隐藏
- 🎯 长按悬浮按钮显示日志列表
- 🎯 自动吸附到屏幕边缘
- 🎯 完整的日志列表和详情页面

## 文件说明

### 核心文件
1. **NetworkInterceptor.swift** - 网络拦截核心类（基于 URLProtocol）
2. **WebSocketInterceptor.swift** - WebSocket 拦截核心类（基于 Method Swizzling）
3. **InterceptedRequest.swift** - 拦截请求数据模型
4. **WebSocketMessage.swift** - WebSocket 消息数据模型
5. **NetworkInterceptorManager.swift** - 拦截管理器

### UI 文件
6. **FloatingButton.swift** - 可拖拽悬浮按钮
7. **NetworkLogViewController.swift** - 日志列表页面（支持 HTTP/IM 切换）
8. **NetworkLogCell.swift** - HTTP 日志列表单元格
9. **WebSocketMessageCell.swift** - IM 消息列表单元格
10. **NetworkLogDetailViewController.swift** - HTTP 日志详情页面
11. **WebSocketMessageDetailViewController.swift** - IM 消息详情页面

### 更新文件
8. **AppDelegate_Updated.swift** - 更新后的 AppDelegate（启动拦截）
9. **SceneDelegate_Updated.swift** - 更新后的 SceneDelegate（显示悬浮按钮）
10. **ViewController_Updated.swift** - 更新后的 ViewController（测试页面）

## 安装步骤

### 1. 添加文件到项目
将以下文件添加到你的 Xcode 项目中：
- NetworkInterceptor.swift
- InterceptedRequest.swift
- NetworkInterceptorManager.swift
- FloatingButton.swift
- NetworkLogViewController.swift
- NetworkLogCell.swift
- NetworkLogDetailViewController.swift

### 2. 替换现有文件
用以下文件替换项目中的对应文件：
- 用 `AppDelegate_Updated.swift` 的内容替换 `AppDelegate.swift`
- 用 `SceneDelegate_Updated.swift` 的内容替换 `SceneDelegate.swift`
- 用 `ViewController_Updated.swift` 的内容替换 `ViewController.swift`

### 3. 编译运行
直接运行项目即可。

## 使用方法

### 基本使用
1. 启动应用后，会在右下角看到一个蓝色的悬浮按钮（📊）
2. **点击**悬浮按钮 → 隐藏按钮
3. **长按**悬浮按钮 → 显示网络日志列表
4. 悬浮按钮可以**拖拽**到任意位置，会自动吸附到屏幕边缘

### 日志列表功能
- HTTP/IM 切换：点击顶部切换按钮查看不同类型的日志
- 搜索框：搜索 URL、请求、响应内容或 IM 消息
- 过滤器：
  - HTTP 模式：按请求方法（GET/POST）或状态（成功/失败）过滤
  - IM 模式：按消息类型（连接/发送/接收/错误）过滤
- 点击列表项：查看详细信息
- 清空按钮：清空当前类型的所有日志
- 导出按钮：导出日志为 JSON 格式（仅 HTTP）

### 日志详情功能
详情页面包含 7 个标签页：
1. **基本信息** - 时间、路由、请求类型、状态码、耗时等
2. **URL信息** - 完整 URL 和 URL 参数
3. **请求Headers** - 所有请求头信息
4. **请求Body** - 请求体内容（JSON 自动格式化）
5. **响应Headers** - 所有响应头信息
6. **响应Body** - 响应体内容（JSON 自动格式化）
7. **异常信息** - 错误信息（如果有）

### IM 消息详情功能
显示 WebSocket 消息的完整信息：
- 消息类型（连接/发送/接收/断开/错误）
- 时间戳
- WebSocket URL
- 消息内容（JSON 自动格式化）
- 数据大小
- 支持复制消息内容

## 技术实现

### URLProtocol 拦截
使用 iOS 原生的 URLProtocol 机制拦截网络请求：
- 可以拦截所有通过 URLSession 发起的请求
- 支持第三方网络库（如 Alamofire、AFNetworking）
- 不影响原有网络请求的正常执行

### 数据存储
- 内存存储，最多保存 1000 条记录
- 自动清理旧记录，保持性能
- 支持导出为 JSON 文件

### UI 设计
- 采用原生 UIKit 实现
- 支持深色模式
- 流畅的动画效果
- 响应式布局

## 限制说明

### 可以拦截
✅ URLSession 发起的所有请求
✅ 基于 URLSession 的第三方库（Alamofire、AFNetworking 等）
✅ WKWebView 的请求（需要额外配置）
✅ SocketRocket WebSocket 连接和消息
✅ 基于 NSStream 的 WebSocket 实现

### 无法拦截
❌ CFNetwork 直接调用
❌ 原生 URLSessionWebSocketTask（需要额外配置）
❌ 系统级别的网络请求

## 高级功能（可选）

### 拦截 WebSocket 连接
已内置 SocketRocket 拦截支持，自动启动。详见 [WebSocket 拦截指南](WEBSOCKET_GUIDE.md)。

如需拦截其他 WebSocket 库：
```swift
// 在 WebSocketInterceptor.swift 中添加对应的 Hook
private func hookCustomWebSocket() {
    guard let socketClass = NSClassFromString("YourWebSocketClass") else {
        return
    }
    // 添加 Swizzling 代码
}
```

### Runtime Hook
如果需要拦截更底层的网络调用，可以使用 Method Swizzling：
```swift
// 在 AppDelegate 中添加
RuntimeHooker.hookNSURLSession()
```

## 测试

运行应用后：
1. 点击"测试网络请求"按钮
2. 长按悬浮按钮查看拦截到的请求
3. 可以看到 GitHub API 和 httpbin.org 的测试请求

## 注意事项

1. **性能影响**：拦截会略微增加网络请求的开销，建议仅在开发/测试环境使用
2. **内存占用**：大量请求会占用内存，定期清空日志
3. **隐私安全**：日志可能包含敏感信息，不要在生产环境启用
4. **App Store**：如果要上架 App Store，建议使用编译条件控制：

```swift
#if DEBUG
NetworkInterceptorManager.shared.startIntercepting()
#endif
```

## 自定义配置

### 修改最大记录数
```swift
NetworkInterceptor.maxRecords = 500 // 默认 1000
```

### 修改悬浮按钮样式
在 `FloatingButton.swift` 的 `setupUI()` 方法中修改：
```swift
backgroundColor = .systemRed // 修改颜色
setTitle("🔍", for: .normal) // 修改图标
```

### 添加自定义过滤规则
在 `NetworkInterceptor.swift` 的 `canInit` 方法中添加：
```swift
override class func canInit(with request: URLRequest) -> Bool {
    // 忽略特定域名
    if request.url?.host?.contains("example.com") == true {
        return false
    }
    
    // 其他过滤逻辑...
    return true
}
```

## 常见问题

### Q: 为什么看不到某些请求？
A: 可能是使用了 CFNetwork 或 Socket 直接连接，URLProtocol 无法拦截。

### Q: 如何拦截 WKWebView 的请求？
A: 需要自定义 WKURLSchemeHandler 或使用 WKWebView 的代理方法。

### Q: 为什么看不到 WebSocket 消息？
A: 确保你的项目使用了 SocketRocket，或者需要添加对其他 WebSocket 库的 Hook 支持。

### Q: 悬浮按钮被其他视图遮挡怎么办？
A: 确保悬浮按钮添加到最顶层的 window 上，可以在 SceneDelegate 中调整。

### Q: 如何在生产环境禁用？
A: 使用编译条件或配置文件控制是否启动拦截器。

## 相关文档

- [WebSocket 拦截指南](WEBSOCKET_GUIDE.md) - 详细的 IM 拦截功能说明
- [快速开始](QUICK_START.md) - 快速上手指南
- [安装指南](INSTALLATION_GUIDE.md) - 详细安装步骤

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
