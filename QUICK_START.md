# ZWB_LogTap 快速开始指南

## 5 分钟快速集成

### 步骤 1: 安装

在 `Podfile` 中添加：

```ruby
pod 'ZWB_LogTap', '~> 1.0.2', :configurations => ['Debug']
```

运行：

```bash
pod install
```

### 步骤 2: 启动

在 `AppDelegate.swift` 中添加一行代码：

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    ZWBLogTap.startIfDebug()  // 就这一行！
    
    return true
}
```

### 步骤 3: 运行

运行你的应用，你会看到：

1. 右下角出现一个蓝色的悬浮按钮 📊
2. 点击按钮打开日志页面
3. 所有网络请求都会被自动拦截和记录

## 使用示例

### 查看 HTTP 请求

```swift
// 发起一个网络请求
URLSession.shared.dataTask(with: URL(string: "https://api.github.com/users/apple")!) { data, response, error in
    // 处理响应
}.resume()

// 点击悬浮按钮，在 HTTP 标签下查看这个请求
```

### 查看 WebSocket 消息

```swift
// 如果你使用 SocketRocket
let socket = SRWebSocket(url: URL(string: "wss://echo.websocket.org")!)
socket?.open()
socket?.send("Hello")

// 点击悬浮按钮，切换到 IM 标签查看消息
```

### 编程方式访问

```swift
// 获取所有请求
let requests = ZWBLogTap.shared.getAllHTTPRequests()
print("共拦截 \(requests.count) 个请求")

// 清空日志
ZWBLogTap.shared.clearAllLogs()

// 导出日志
if let json = ZWBLogTap.shared.exportLogsAsJSON() {
    // 保存或分享 JSON
}
```

## 常见场景

### 场景 1: 调试 API 接口

```swift
// 1. 启动 ZWB_LogTap
ZWBLogTap.startIfDebug()

// 2. 发起请求
fetchUserData()

// 3. 点击悬浮按钮查看
// - 请求 URL 和参数
// - 请求 Headers
// - 响应状态码
// - 响应数据（自动格式化 JSON）
```

### 场景 2: 排查网络问题

```swift
// 查看失败的请求
let requests = ZWBLogTap.shared.getAllHTTPRequests()
let failedRequests = requests.filter { ($0.statusCode ?? 0) >= 400 }

for request in failedRequests {
    print("失败请求: \(request.url)")
    print("状态码: \(request.statusCode ?? 0)")
    print("错误: \(request.error ?? "无")")
}
```

### 场景 3: 监控 WebSocket

```swift
// 1. 启动 ZWB_LogTap（会自动拦截 SocketRocket）
ZWBLogTap.startIfDebug()

// 2. 使用 SocketRocket
let socket = SRWebSocket(url: wsURL)
socket?.open()

// 3. 在 IM 标签查看
// - 连接事件
// - 发送的消息
// - 接收的消息
// - 断开事件
```

## 高级配置

### 自定义配置

```swift
var config = ZWBLogTap.Configuration()
config.showFloatingButton = true
config.interceptHTTP = true
config.interceptWebSocket = true
config.maxRecords = 500  // 只保留最近 500 条

ZWBLogTap.shared.start(with: config)
```

### 不显示悬浮按钮

```swift
ZWBLogTap.start(showFloatingButton: false)

// 需要时手动显示日志
ZWBLogTap.shared.showLogViewController()
```

### 只拦截 HTTP

```swift
ZWBLogTap.start(
    interceptHTTP: true,
    interceptWebSocket: false
)
```

## 提示和技巧

### 💡 提示 1: 搜索功能

在日志列表页面，使用搜索框快速找到目标请求：
- 搜索 URL
- 搜索请求内容
- 搜索响应内容

### 💡 提示 2: 过滤功能

使用过滤器快速筛选：
- HTTP 模式：全部、GET、POST、成功、失败
- IM 模式：全部、连接、发送、接收、错误

### 💡 提示 3: 复制功能

在详情页面点击复制按钮，快速复制：
- HTTP: 当前标签页的内容
- IM: 消息内容

### 💡 提示 4: 导出日志

```swift
if let json = ZWBLogTap.shared.exportLogsAsJSON() {
    // 保存到文件
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("logs.json")
    try? json.write(to: url, atomically: true, encoding: .utf8)
    
    // 或分享
    let activityVC = UIActivityViewController(activityItems: [json], applicationActivities: nil)
    present(activityVC, animated: true)
}
```

## 故障排除

### 问题 1: 看不到悬浮按钮

**解决方案：**
- 确保在 Debug 模式下运行
- 检查是否调用了 `ZWBLogTap.startIfDebug()`
- 等待 0.5 秒让按钮显示

### 问题 2: 看不到某些请求

**解决方案：**
- 确保使用的是 URLSession
- 检查是否使用了 CFNetwork 直接调用
- 查看控制台是否有错误信息

### 问题 3: WebSocket 消息没有显示

**解决方案：**
- 确保使用的是 SocketRocket 库
- 检查是否启用了 WebSocket 拦截
- 查看控制台是否有 Hook 成功的日志

## 下一步

- 查看 [完整文档](README.md)
- 查看 [API 文档](API.md)
- 查看 [常见问题](FAQ.md)
- 提交 [Issue](https://github.com/yourusername/ZWB_LogTap/issues)

---

需要帮助？[提交 Issue](https://github.com/yourusername/ZWB_LogTap/issues/new)
