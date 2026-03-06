# ZWB_LogTap 1.0.6 发布说明

发布日期：2026-03-06

## 🎉 新功能

### 1. 环境切换功能 🌍

支持在测试环境和正式环境之间快速切换，提升开发效率。

**特性：**
- 悬浮按钮颜色区分（🔵 蓝色=测试环境，🔴 红色=正式环境）
- 在"调试工具"页面新增"环境切换"入口
- 提供闭包回调，用户可自定义切换后的逻辑
- 支持 `.test`、`.production`、`.custom(String)` 三种环境类型

**使用示例：**
```swift
// 设置环境切换回调
ZWBLogTap.shared.setEnvironmentSwitchCallback { newEnvironment in
    switch newEnvironment {
    case .test:
        APIManager.shared.baseURL = "https://test-api.example.com"
    case .production:
        APIManager.shared.baseURL = "https://api.example.com"
    case .custom(let name):
        print("自定义环境: \(name)")
    }
}

// 主动切换环境
ZWBLogTap.shared.switchEnvironment()
```

**详细文档：** [环境切换完整指南](ENVIRONMENT_SWITCHING_GUIDE.md)

### 2. 调试工具集成 🛠️

集成了三个强大的调试工具，帮助开发者快速定位问题。

#### 2.1 模拟弱网 🌐
- 断网模式：模拟完全断网
- 限速模式：自定义请求/响应速度
- 延迟模式：自定义网络延迟
- 悬浮窗实时显示当前网络状态

#### 2.2 Crash 监控 💥
- 自动捕获应用崩溃
- 记录崩溃原因、时间、版本、调用栈
- 支持查看历史崩溃记录
- 支持复制和分享崩溃日志

#### 2.3 内存监控 💾
- 实时监控内存使用情况
- 显示当前使用/总内存
- 悬浮窗实时更新数据
- 帮助发现内存泄漏

### 3. 分享功能 📤

所有详情页面都支持导出为 txt 文件分享。

**支持的页面：**
- HTTP 请求详情
- WebSocket 消息详情
- Crash 日志详情

**特性：**
- 导出为 txt 格式
- 支持隔空投送
- 支持分享到其他应用
- 只分享当前选中的 tab 内容

## 🎨 优化改进

### 1. 入口按钮优化
- 尺寸从 60x60 调整为 40x40，更加精致
- 根据环境显示不同颜色（蓝色/红色）
- 使用独立 UIWindow 确保始终在最顶层

### 2. 悬浮窗优化
- 使用独立 UIWindow 确保始终在最顶层
- 支持拖拽移动
- 不阻挡页面其他区域的交互
- 尺寸优化为 160x90

### 3. 界面优化
- "辅助"改名为"工具"，更符合功能定位
- 添加"工具"按钮入口
- 优化调试工具列表布局

## 🐛 Bug 修复

### 1. 修复悬浮窗在 iOS 13+ 无法显示的问题
- 正确关联 UIWindowScene
- 确保悬浮窗在所有场景下都能正常显示

### 2. 修复详情页面分享按钮丢失的问题
- 重新添加分享按钮
- 优化按钮布局

## 📸 截图更新

所有截图已更新为最新版本：
- 首页测试入口
- 调试工具列表
- HTTP 列表页
- HTTP 详情页
- IM 列表页
- IM 详情页
- 模拟弱网
- 内存监控
- Crash 日志

## 📦 安装

### CocoaPods

```ruby
pod 'ZWB_LogTap', '~> 1.0.6', :configurations => ['Debug']
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/Log-interception.git", from: "1.0.6")
]
```

## 🔄 升级指南

### 从 1.0.5 升级

1. 更新 Podfile：
   ```ruby
   pod 'ZWB_LogTap', '~> 1.0.6', :configurations => ['Debug']
   ```

2. 运行：
   ```bash
   pod update ZWB_LogTap
   ```

3. 可选：设置环境切换回调
   ```swift
   ZWBLogTap.shared.setEnvironmentSwitchCallback { env in
       // 处理环境切换
   }
   ```

### 破坏性变更

无破坏性变更，完全向后兼容。

## 📚 文档

- [README](README.md) - 项目介绍和快速开始
- [CHANGELOG](CHANGELOG.md) - 完整更新日志
- [环境切换指南](ENVIRONMENT_SWITCHING_GUIDE.md) - 环境切换功能详细说明
- [调试工具实现](DEBUG_TOOLS_IMPLEMENTATION.md) - 调试工具技术细节

## 🙏 致谢

感谢所有使用和支持 ZWB_LogTap 的开发者！

如有问题或建议，欢迎提 Issue：
https://github.com/muskspace0806-prog/Log-interception/issues

## 📝 下一步计划

- [ ] 支持更多网络库（如 Moya）
- [ ] 添加性能监控功能
- [ ] 支持自定义主题
- [ ] 添加更多网络模拟场景

---

**完整更新日志：** [CHANGELOG.md](CHANGELOG.md)
