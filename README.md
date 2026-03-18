# ZWB_LogTap

[![Version](https://img.shields.io/badge/version-1.1.8-blue.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![Platform](https://img.shields.io/badge/platform-iOS%2013.0%2B-lightgrey.svg)](https://github.com/muskspace0806-prog/Log-interception)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![CocoaPods](https://img.shields.io/badge/pod-1.1.8-blue.svg)](https://cocoapods.org/pods/ZWB_LogTap)

一个功能强大的 iOS 网络调试工具，支持 HTTP/HTTPS 和 WebSocket 实时拦截与查看。

[English](README_EN.md) | 中文文档

## ✨ 功能特性

- ✅ **HTTP/HTTPS 拦截** - 拦截所有 URLSession 网络请求（稳定）
- ✅ **Alamofire 支持** - 自动拦截 Alamofire 请求（稳定）
- ❌ **WebSocket 拦截** - 由于技术限制已禁用，建议使用专业工具
- ✅ **环境切换** - 支持测试/正式环境快速切换，按钮颜色区分
- ✅ **响应数据解密** - 支持 AES-128-CBC 解密，多环境配置
- ✅ **URL 过滤** - 支持过滤指定 URL，不显示在日志列表
- ✅ **模拟弱网** - 支持断网、限速、延迟等网络模拟
- ✅ **Crash 监控** - 自动捕获并记录应用崩溃日志
- ✅ **内存监控** - 实时监控内存使用情况
- ✅ **失败请求高亮** - 错误请求 URL 自动标红，一目了然
- ✅ **实时查看** - 实时显示请求和响应数据
- ✅ **JSON 格式化** - 自动格式化 JSON 数据，易于阅读
- ✅ **搜索过滤** - 快速搜索和过滤网络请求
- ✅ **日志导出** - 支持导出日志为 JSON 格式
- ✅ **悬浮按钮** - 可拖拽的悬浮按钮，随时查看日志
- ✅ **零配置** - 一行代码即可启动
- ✅ **仅 Debug** - 只在开发环境使用，不影响生产环境

## 📱 预览

### 主界面和调试工具

<p align="center">
  <img src="Screenshots/首页测试入口.png" width="250" alt="首页">
  <img src="Screenshots/调试工具列表.png" width="250" alt="调试工具">
  <img src="Screenshots/http列表页.png" width="250" alt="HTTP列表">
</p>

### HTTP 网络日志

<p align="center">
  <img src="Screenshots/http详情页.png" width="300" alt="HTTP详情">
</p>

**特性：**
- ✅ 失败请求 URL 自动标红（404、500、网络错误等）
- ✅ 状态码颜色区分（绿色=成功，红色=错误）
- ✅ 请求耗时实时显示
- ✅ 支持 GET、POST、PUT、DELETE 等方法
- ✅ JSON 自动格式化
- ✅ 完整的请求/响应详情查看
- ✅ 支持复制和分享功能

### WebSocket 消息

<p align="center">
  <img src="Screenshots/IM列表.png" width="300" alt="IM列表">
  <img src="Screenshots/IM详情页.png" width="300" alt="IM详情">
</p>

**特性：**
- ✅ 错误消息 URL 和内容自动标红
- ✅ 消息类型图标区分（连接、发送、接收、错误）
- ✅ JSON 自动格式化
- ✅ 消息大小实时显示
- ✅ 完整的消息内容查看
- ✅ 支持复制和分享功能

### 调试工具

<p align="center">
  <img src="Screenshots/模拟弱网.png" width="250" alt="模拟弱网">
  <img src="Screenshots/内存检测.png" width="250" alt="内存监控">
  <img src="Screenshots/crash日志.png" width="250" alt="Crash日志">
</p>

**特性：**
- ✅ 模拟弱网：断网、限速、延迟
- ✅ 内存监控：实时显示内存使用
- ✅ Crash 日志：自动捕获崩溃
- ✅ 环境切换：测试/正式环境快速切换
- ✅ 悬浮窗：实时显示监控数据

### 界面特性
- ✅ 悬浮按钮，可拖拽移动，颜色区分环境
- ✅ HTTP/IM 模式快速切换
- ✅ 搜索和过滤功能
- ✅ 一键清空和导出日志
- ✅ 完整的调试工具集成

## 📦 安装

### CocoaPods

在你的 `Podfile` 中添加：

```ruby
# 仅在 Debug 模式下使用
pod 'ZWB_LogTap', '~> 1.0.7', :configurations => ['Debug']
```

然后运行：

```bash
pod install
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/Log-interception.git", from: "1.0.7")
]
```

### 手动安装

将 `ZWB_LogTap/Classes` 文件夹拖入你的项目。

## 🚀 快速开始

### 基础使用

在 `AppDelegate.swift` 中：

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 方式 1: 仅在 Debug 模式下自动启动（推荐）
    ZWBLogTap.startIfDebug()
    
    // 方式 2: 手动启动
    #if DEBUG
    ZWBLogTap.shared.start()
    #endif
    
    return true
}
```

就这么简单！运行应用后，你会在右下角看到一个蓝色的悬浮按钮 📊。

### 高级配置

```swift
import ZWB_LogTap

// 自定义配置
var config = ZWBLogTap.Configuration()
config.showFloatingButton = true          // 显示悬浮按钮
config.interceptHTTP = true               // 拦截 HTTP 请求
config.maxRecords = 1000                  // 最大记录数
config.defaultEnvironment = .test         // 默认环境（测试/正式）

ZWBLogTap.shared.start(with: config)

// 或使用便捷方法
ZWBLogTap.start(
    showFloatingButton: true,
    interceptHTTP: true,
    maxRecords: 500,
    defaultEnvironment: .test
)
```

### 🌍 环境切换与响应解密

支持在测试环境和正式环境之间快速切换，悬浮按钮颜色自动区分：
- 🔵 **蓝色按钮** = 测试环境
- 🔴 **红色按钮** = 正式环境

**基础配置（不需要解密）：**

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 启动调试工具，默认测试环境
    ZWBLogTap.start(defaultEnvironment: .test)
    
    return true
}
```

**配置多环境响应数据解密：**

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 配置测试环境解密
    let testConfig = ZWBLogTap.ResponseDecryptionConfig(
        aesKey: "test_aes_key_16b",      // 测试环境 AES Key（16字节）
        aesIV: "test_aes_iv__16b",       // 测试环境 AES IV（16字节）
        encryptedFieldName: "ed",        // 加密数据的字段名
        enabled: true
    )
    
    // 配置正式环境解密
    let prodConfig = ZWBLogTap.ResponseDecryptionConfig(
        aesKey: "prod_aes_key_16b",      // 正式环境 AES Key（16字节）
        aesIV: "prod_aes_iv__16b",       // 正式环境 AES IV（16字节）
        encryptedFieldName: "ed",
        enabled: true
    )
    
    // 启动时配置多环境解密
    ZWBLogTap.start(
        defaultEnvironment: .test,
        decryptionConfigs: [
            .test: testConfig,
            .production: prodConfig
        ]
    )
    
    return true
}
```

**设置环境切换回调：**

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 启动调试工具
    ZWBLogTap.start(defaultEnvironment: .test)
    
    // 设置环境切换回调
    ZWBLogTap.shared.setEnvironmentSwitchCallback { newEnvironment in
        switch newEnvironment {
        case .test:
            // 切换到测试环境
            APIManager.shared.baseURL = "https://test-api.example.com"
            print("🔵 已切换到测试环境")
            
        case .production:
            // 切换到正式环境
            APIManager.shared.baseURL = "https://api.example.com"
            print("🔴 已切换到正式环境")
            
        case .custom(let name):
            print("🟠 自定义环境: \(name)")
        }
        
        // 重新初始化网络层、清空缓存等
        NetworkManager.shared.reinitialize()
    }
    
    return true
}
```

**响应数据解密工作原理：**

1. **仅在正式环境启用** - 测试环境不进行解密
2. **自动识别加密格式** - 检查响应是否为 `{"ed": "加密字符串"}` 格式
3. **Base64 解码** - 将加密字符串进行 Base64 解码
4. **AES-256-CBC 解密** - 使用配置的 Key 和 IV 进行解密
5. **显示结果** - 在日志面板中显示解密后的 JSON

**加密响应示例：**

```json
{
  "ed": "mdlIOnMCcscqcn4biCloPy1d7cl+LHM5Jq299gHUwaC..."
}
```

解密后显示为：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "userId": "12345",
    "userName": "张三"
  }
}
```

**详细文档：** 
- 📖 [环境切换完整指南](ENVIRONMENT_SWITCHING_GUIDE.md)
- 📖 [响应解密功能说明](ENVIRONMENT_FEATURE_SUMMARY.md)
- 📖 [解密功能测试指南](DECRYPTION_TEST_GUIDE.md)

### 🔍 URL 过滤功能

支持过滤不需要的 URL 请求，让日志列表更清晰：

**使用方法：**

1. 点击日志面板顶部的"过滤"按钮
2. 点击"添加"输入要过滤的 URL（支持部分匹配）
3. 匹配的 URL 请求将不再显示在日志列表中
4. 点击规则右侧的 ✕ 可删除过滤规则

**特性：**
- ✅ 支持模糊匹配（不区分大小写）
- ✅ 支持 HTTP 和 WebSocket 消息过滤
- ✅ 过滤规则持久化存储
- ✅ 可随时添加/删除过滤规则

**示例：**
- 过滤 `analytics` - 将过滤所有包含 "analytics" 的 URL
- 过滤 `api.example.com/log` - 将过滤所有包含该路径的请求
- 过滤 `tracking` - 将过滤所有包含 "tracking" 的请求

### ❌ WebSocket 拦截说明

WebSocket 拦截功能由于技术限制已**永久禁用**。

**原因：**
- Method Swizzling 在 Swift 环境下极度不稳定
- 即使最简单的操作（print、变量赋值）都会导致崩溃
- 无法在 SocketRocket 的 Hook 回调中执行任何 Swift 代码

**✅ 推荐方案：手动日志记录**

在你的 SocketRocket delegate 中添加几行代码即可：

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
    
    // 接收消息
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        // 📝 记录接收 - 只需添加这一行！
        ZWBLogTap.logWebSocketReceive(url: webSocket.url?.absoluteString ?? "", message: message)
        
        // 你的业务逻辑
        if let text = message as? String {
            print("收到文本: \(text)")
        }
    }
    
    // 连接失败
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        // 📝 记录错误
        ZWBLogTap.logWebSocketError(url: webSocket.url?.absoluteString ?? "", error: error.localizedDescription)
    }
    
    // 连接关闭
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        // 📝 记录断开
        ZWBLogTap.logWebSocketDisconnect(url: webSocket.url?.absoluteString ?? "", reason: reason)
    }
}
```

**WebSocket 手动日志 API：**

```swift
// 1. 记录连接
ZWBLogTap.logWebSocketConnect(url: "wss://example.com")

// 2. 记录发送
ZWBLogTap.logWebSocketSend(url: "wss://example.com", message: "Hello")

// 3. 记录接收
ZWBLogTap.logWebSocketReceive(url: "wss://example.com", message: "World")

// 4. 记录断开
ZWBLogTap.logWebSocketDisconnect(url: "wss://example.com", reason: "正常关闭")

// 5. 记录错误
ZWBLogTap.logWebSocketError(url: "wss://example.com", error: "连接超时")
```

**查看日志：**
1. 运行应用
2. 点击右下角悬浮按钮 📊
3. 切换到 "IM" 标签
4. 查看所有 WebSocket 消息

**详细文档：**
- 📖 [WebSocket 手动日志完整指南](WEBSOCKET_MANUAL_LOGGING.md)
- 📋 [快速参考](QUICK_WEBSOCKET_GUIDE.md)

**其他替代方案：**
- ✅ **Charles Proxy** - 专业的网络调试工具，完美支持 WebSocket
- ✅ **Proxyman** - macOS 原生网络调试工具

## 📖 使用方法

### 查看日志

1. **点击悬浮按钮** - 打开日志列表页面
2. **切换 HTTP/IM** - 查看不同类型的日志
3. **点击列表项** - 查看详细信息
4. **搜索和过滤** - 快速找到目标请求
5. **复制内容** - 点击复制按钮复制数据

### 编程方式访问

```swift
// 显示日志页面
ZWBLogTap.shared.showLogViewController()

// 获取所有 HTTP 请求
let requests = ZWBLogTap.shared.getAllHTTPRequests()

// 获取所有 WebSocket 消息
let messages = ZWBLogTap.shared.getAllWebSocketMessages()

// 清空日志
ZWBLogTap.shared.clearAllLogs()

// 导出日志为 JSON
if let json = ZWBLogTap.shared.exportLogsAsJSON() {
    print(json)
}

// 停止调试工具
ZWBLogTap.shared.stop()
```

## 🔧 支持的网络库

### HTTP/HTTPS
- ✅ URLSession (原生)
- ✅ Alamofire
- ✅ AFNetworking
- ✅ 其他基于 URLSession 的库

### WebSocket
- ✅ SocketRocket
- ⚠️ URLSessionWebSocketTask (需要额外配置)
- ✅ 其他基于 NSStream 的实现

## 💡 最佳实践

### 1. 仅在 Debug 模式使用

```swift
#if DEBUG
ZWBLogTap.shared.start()
#endif
```

### 2. 在 Podfile 中限制配置

```ruby
pod 'ZWB_LogTap', '~> 1.0.3', :configurations => ['Debug']
```

### 3. 内存管理

```swift
func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    #if DEBUG
    ZWBLogTap.shared.clearAllLogs()
    #endif
}
```

### 4. 自定义过滤

如果需要忽略某些请求，可以修改 `NetworkInterceptor.swift`:

```swift
override class func canInit(with request: URLRequest) -> Bool {
    // 忽略特定域名
    if request.url?.host?.contains("analytics.com") == true {
        return false
    }
    return true
}
```

## ⚠️ 注意事项

1. **仅用于开发/测试** - 不要在生产环境启用
2. **性能影响** - 拦截会略微增加网络请求开销
3. **内存占用** - 大量请求会占用内存，定期清空日志
4. **隐私安全** - 日志可能包含敏感信息，注意保护
5. **App Store** - 上架前确保已禁用或移除

## 📋 系统要求

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📝 更新日志

### [1.0.7] - 2026-03-12

#### Added
- ✅ 响应数据解密功能增强
  - 支持多环境解密配置（测试/正式环境可配置不同的 Key 和 IV）
  - 支持 AES-128-CBC 解密算法
  - HTTP 响应 Body 自动解密
  - WebSocket (IM) 消息自动解密
  - 解密失败时安全回退到原始数据
  - 默认不解密，按需配置
- ✅ URL 过滤功能
  - 支持添加 URL 过滤规则（模糊匹配）
  - 过滤的 URL 请求不会显示在日志面板
  - 支持 HTTP 和 WebSocket 消息过滤
  - 过滤规则持久化存储
  - 可随时添加/删除过滤规则
- ✅ 新增文件
  - `AESCrypto.swift` - AES 加解密实现
  - `URLFilterManager.swift` - URL 过滤管理器
  - `URLFilterViewController.swift` - URL 过滤设置页面

#### Changed
- 🎨 URL 参数从"URL 信息"标签迁移到"请求 Body"标签显示
- 🎨 HTTP 详情页默认显示"响应 Body"标签
- 🎨 优化按钮布局，"过滤"按钮移至左侧
- 🎨 调整浮动按钮底部距离，避免与 tabBar 重叠

#### Fixed
- 🐛 修复浮动按钮可能与 tabBar 重叠的问题
- 🐛 优化按钮布局，避免拥挤

#### Improved
- 🚀 提升多环境调试体验，支持不同环境使用不同解密配置
- 🚀 提升用户体验，可过滤不需要的 URL 请求

### [1.0.6] - 2026-03-12

#### Added
- ✅ 响应数据解密功能 - 支持在正式环境中自动解密加密的响应数据
  - 支持 AES-256-CBC 解密算法
  - 自动识别加密格式 `{"ed": "加密字符串"}`
  - 仅在正式环境启用，测试环境不解密
  - 解密失败时显示原始数据
- ✅ 新增 `ResponseDecryptionConfig` 配置类
  - 配置 AES Key、IV 和加密字段名
  - 灵活的初始化方式
- ✅ 新增 `AESCrypto.swift` - 标准的 CommonCrypto AES 实现
  - 支持 AES-256-CBC 加密/解密
  - 兼容 Objective-C 风格 API

#### Changed
- 🎨 优化环境管理器 - 添加解密配置管理
- 📝 更新文档 - 添加响应解密功能说明

#### Improved
- 🚀 提升正式环境调试体验，可直接查看解密后的响应数据

### [1.0.5] - 2026-03-06

#### Changed
- 🎨 完善请求Body展示 - URL参数从"URL信息"tab迁移到"请求Body"tab中展示
- 📝 优化详情页面布局 - "URL信息"tab现在只显示完整URL
- 📝 "请求Body"tab现在先显示URL参数，再显示请求Body内容

#### Improved
- 🚀 提升用户体验，信息展示更加合理和直观

### [1.0.4] - 2026-03-05

#### Added
- ✅ Alamofire 自动拦截支持 - 无需配置，自动拦截所有 Alamofire 请求
- ✅ WebSocket 手动日志记录 API - 5 个简单方法，稳定可靠
  - `ZWBLogTap.logWebSocketConnect(url:)` - 记录连接
  - `ZWBLogTap.logWebSocketSend(url:message:)` - 记录发送
  - `ZWBLogTap.logWebSocketReceive(url:message:)` - 记录接收
  - `ZWBLogTap.logWebSocketDisconnect(url:reason:)` - 记录断开
  - `ZWBLogTap.logWebSocketError(url:error:)` - 记录错误

#### Changed
- ⚠️ WebSocket 自动拦截已禁用 - 由于 Method Swizzling 技术限制导致崩溃
- 📝 改用手动日志记录方式 - 更稳定、零崩溃、易维护

#### Fixed
- 🐛 修复详情页面标签按钮在小屏幕上被内容遮挡的问题
- 🐛 修复内容区域底部约束，确保填充到安全区域

### [1.0.3] - 2026-03-04

#### Added
- 错误请求 URL 自动标红显示
- WebSocket 错误消息高亮显示
- 优化错误请求的视觉展示

### [1.0.2] - 2026-03-04

#### Added
- 初始版本发布
- HTTP/HTTPS 拦截功能
- WebSocket 拦截功能（支持 SocketRocket）
- 悬浮按钮 UI
- 日志列表和详情页面
- JSON 自动格式化
- 搜索和过滤功能
- 日志导出功能

## 📄 许可证

ZWB_LogTap 使用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 👨‍💻 作者

ZWB - [@muskspace0806-prog](https://github.com/muskspace0806-prog)

项目链接: [https://github.com/muskspace0806-prog/Log-interception](https://github.com/muskspace0806-prog/Log-interception)

CocoaPods: [https://cocoapods.org/pods/ZWB_LogTap](https://cocoapods.org/pods/ZWB_LogTap)

## 🙏 致谢

- 感谢所有贡献者

## ⭐️ 支持

如果这个项目对你有帮助，请给个 Star！

---

Made with ❤️ by ZWB
