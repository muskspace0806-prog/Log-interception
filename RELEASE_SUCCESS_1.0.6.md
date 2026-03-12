# 🎉 ZWB_LogTap 1.0.6 发布成功！

发布时间：2026-03-06 19:52

## ✅ 发布完成

### GitHub
- ✅ 代码已提交（commit: 20c8c22）
- ✅ 标签已创建（tag: 1.0.6）
- ✅ 代码已推送到远程仓库
- 🔗 https://github.com/muskspace0806-prog/Log-interception

### CocoaPods
- ✅ podspec 验证通过
- ✅ 成功发布到 CocoaPods Trunk
- ✅ 版本 1.0.6 已上线
- 🔗 https://cocoapods.org/pods/ZWB_LogTap

## 📦 安装方式

### CocoaPods（推荐）

```ruby
# Podfile
pod 'ZWB_LogTap', '~> 1.0.6', :configurations => ['Debug']
```

然后运行：
```bash
pod install
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/Log-interception.git", from: "1.0.6")
]
```

### 直接使用 Git

```ruby
# Podfile
pod 'ZWB_LogTap', :git => 'https://github.com/muskspace0806-prog/Log-interception.git', :tag => '1.0.6'
```

## 🎁 新功能

### 1. 环境切换 🌍
- 悬浮按钮颜色区分（🔵 蓝色=测试，🔴 红色=正式）
- 在"调试工具"页面新增"环境切换"入口
- 提供闭包回调，用户可自定义切换后的逻辑

### 2. 调试工具集成 🛠️
- **模拟弱网**：断网、限速、延迟
- **Crash 监控**：自动捕获崩溃，查看历史记录
- **内存监控**：实时显示内存使用情况

### 3. 分享功能 📤
- 所有详情页面支持导出为 txt 文件
- 支持隔空投送和分享到其他应用

## 🎨 优化改进

- 入口按钮尺寸优化（40x40）
- 悬浮窗使用独立 UIWindow，始终在最顶层
- 界面文字优化（"辅助"→"工具"）

## 🐛 Bug 修复

- 修复悬浮窗在 iOS 13+ 无法显示的问题
- 修复详情页面分享按钮丢失的问题

## 📸 截图

所有截图已更新：
- 首页测试入口
- 调试工具列表
- HTTP 列表页和详情页
- IM 列表页和详情页
- 模拟弱网
- 内存监控
- Crash 日志

## 📚 文档

- [README.md](README.md) - 项目介绍
- [CHANGELOG.md](CHANGELOG.md) - 完整更新日志
- [RELEASE_NOTES_1.0.6.md](RELEASE_NOTES_1.0.6.md) - 发布说明
- [ENVIRONMENT_SWITCHING_GUIDE.md](ENVIRONMENT_SWITCHING_GUIDE.md) - 环境切换指南

## 🔍 验证安装

创建测试项目验证：

```ruby
# Podfile
source 'https://cdn.cocoapods.org/'
platform :ios, '13.0'

target 'TestApp' do
  use_frameworks!
  pod 'ZWB_LogTap', '~> 1.0.6', :configurations => ['Debug']
end
```

```bash
pod install
```

在 AppDelegate 中：

```swift
import ZWB_LogTap

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    #if DEBUG
    // 启动调试工具
    ZWBLogTap.start(defaultEnvironment: .test)
    
    // 设置环境切换回调
    ZWBLogTap.shared.setEnvironmentSwitchCallback { env in
        print("环境已切换到: \(env.name)")
    }
    #endif
    
    return true
}
```

## 🎯 下一步

1. ✅ 监控 CocoaPods 安装情况
2. ✅ 收集用户反馈
3. ✅ 准备下一个版本的功能

## 🙏 致谢

感谢所有使用和支持 ZWB_LogTap 的开发者！

## 📞 反馈

如有问题或建议：
- GitHub Issues: https://github.com/muskspace0806-prog/Log-interception/issues
- CocoaPods: https://cocoapods.org/pods/ZWB_LogTap

---

**🎉 发布成功！祝使用愉快！**
