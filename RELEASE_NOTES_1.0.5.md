# ZWB_LogTap v1.0.5 发布说明

## 📅 发布日期
2026-03-06

## 🎯 版本概述
本次更新优化了请求详情页面的信息展示，将URL参数从"URL信息"tab迁移到"请求Body"tab中，使信息展示更加合理和直观。

## ✨ 主要更新

### Changed
- 🎨 **完善请求Body展示** - URL参数从"URL信息"tab迁移到"请求Body"tab中展示
- 📝 **优化详情页面布局** - "URL信息"tab现在只显示完整URL
- 📝 **"请求Body"tab优化** - 现在先显示URL参数，再显示请求Body内容

### Improved
- 🚀 提升用户体验，信息展示更加合理和直观
- 📊 URL参数和请求Body集中展示，便于查看完整的请求数据

## 📦 安装方式

### CocoaPods
```ruby
pod 'ZWB_LogTap', '~> 1.0.5', :configurations => ['Debug']
```

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/Log-interception.git", from: "1.0.5")
]
```

## 🔗 相关链接

- **GitHub Release**: https://github.com/muskspace0806-prog/Log-interception/releases/tag/1.0.5
- **CocoaPods**: https://cocoapods.org/pods/ZWB_LogTap
- **完整文档**: https://github.com/muskspace0806-prog/Log-interception

## 📝 详细变更

### 文件修改
- `ZWB_LogTap/Classes/UI/NetworkLogDetailViewController.swift`
  - 修改 `displayURLInfo()` 方法，只显示完整URL
  - 修改 `displayRequestBody()` 方法，先显示URL参数，再显示请求Body

### 版本更新
- `ZWB_LogTap.podspec` - 版本号更新为 1.0.5
- `README.md` - 更新版本号和更新日志
- `CHANGELOG.md` - 添加 1.0.5 版本说明

## 🎉 发布状态

✅ GitHub 代码已推送  
✅ Git Tag 已创建并推送  
✅ Podspec 验证通过  
✅ CocoaPods 发布成功  
✅ 文档已更新  

## 📊 发布信息

- **版本号**: 1.0.5
- **发布时间**: 2026-03-06 10:43
- **Git Commit**: be48c8c
- **Git Tag**: 1.0.5
- **CocoaPods 状态**: 已发布

## 🙏 致谢

感谢所有使用和支持 ZWB_LogTap 的开发者！

---

Made with ❤️ by ZWB
