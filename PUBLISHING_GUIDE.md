# NetworkDebugger 发布指南

## 发布到 CocoaPods 的完整步骤

### 前期准备

#### 1. 注册 CocoaPods Trunk

```bash
# 注册账号（只需要做一次）
pod trunk register your.email@example.com 'Your Name' --description='MacBook Pro'

# 验证邮箱后，检查注册状态
pod trunk me
```

#### 2. 创建 GitHub 仓库

```bash
# 初始化 Git
git init
git add .
git commit -m "Initial commit"

# 创建 GitHub 仓库后
git remote add origin https://github.com/yourusername/NetworkDebugger.git
git branch -M main
git push -u origin main
```

#### 3. 创建 Git Tag

```bash
# 创建版本标签
git tag 1.0.0
git push origin 1.0.0
```

### 项目结构整理

确保你的项目结构如下：

```
NetworkDebugger/
├── NetworkDebugger/
│   ├── Classes/
│   │   ├── Core/
│   │   │   ├── NetworkInterceptor.swift
│   │   │   ├── NetworkInterceptorManager.swift
│   │   │   ├── WebSocketInterceptor.swift
│   │   │   └── RuntimeHooker.swift
│   │   ├── Models/
│   │   │   ├── InterceptedRequest.swift
│   │   │   └── WebSocketMessage.swift
│   │   ├── UI/
│   │   │   ├── FloatingButton.swift
│   │   │   ├── NetworkLogViewController.swift
│   │   │   ├── NetworkLogCell.swift
│   │   │   ├── NetworkLogDetailViewController.swift
│   │   │   ├── WebSocketMessageCell.swift
│   │   │   └── WebSocketMessageDetailViewController.swift
│   │   └── NetworkDebugger.swift
│   └── Assets/
│       └── (如果有资源文件)
├── Example/
│   └── NetworkDebuggerExample/
│       └── (示例项目)
├── Screenshots/
│   └── (截图)
├── NetworkDebugger.podspec
├── README.md
├── README_CN.md
├── LICENSE
├── CHANGELOG.md
└── .gitignore
```

### 验证 Podspec

```bash
# 本地验证
pod lib lint NetworkDebugger.podspec --verbose

# 如果有警告但想忽略
pod lib lint NetworkDebugger.podspec --allow-warnings

# 远程验证（需要先推送到 GitHub）
pod spec lint NetworkDebugger.podspec --verbose
```

### 常见验证错误及解决方案

#### 错误 1: 找不到源文件

```
ERROR | [iOS] file patterns: The `source_files` pattern did not match any file.
```

**解决方案：**
检查 podspec 中的 `s.source_files` 路径是否正确。

```ruby
# 正确的路径
s.source_files = 'NetworkDebugger/Classes/**/*'
```

#### 错误 2: Swift 版本不匹配

```
ERROR | [iOS] xcodebuild: Returned an unsuccessful exit code.
```

**解决方案：**
在 podspec 中指定 Swift 版本。

```ruby
s.swift_version = '5.0'
```

#### 错误 3: 部署目标版本

```
ERROR | [iOS] unknown: Encountered an unknown error
```

**解决方案：**
确保部署目标版本正确。

```ruby
s.ios.deployment_target = '13.0'
```

### 发布到 CocoaPods

```bash
# 推送到 CocoaPods Trunk
pod trunk push NetworkDebugger.podspec

# 如果有警告但想忽略
pod trunk push NetworkDebugger.podspec --allow-warnings

# 查看发布状态
pod trunk info NetworkDebugger
```

### 更新版本

#### 1. 修改代码后

```bash
# 更新版本号
# 编辑 NetworkDebugger.podspec，修改 s.version

# 提交更改
git add .
git commit -m "Update to version 1.0.1"
git push

# 创建新标签
git tag 1.0.1
git push origin 1.0.1

# 验证并发布
pod lib lint NetworkDebugger.podspec
pod trunk push NetworkDebugger.podspec
```

#### 2. 创建 CHANGELOG.md

```markdown
# Changelog

## [1.0.1] - 2026-03-05

### Added
- 新增功能描述

### Changed
- 修改内容描述

### Fixed
- 修复的 Bug 描述

## [1.0.0] - 2026-03-04

### Added
- 初始版本发布
- HTTP/HTTPS 拦截功能
- WebSocket 拦截功能
- 悬浮按钮 UI
```

### 创建示例项目

```bash
# 使用 CocoaPods 模板创建
pod lib create NetworkDebugger

# 或手动创建
cd Example
pod init
# 编辑 Podfile
pod install
```

示例项目的 Podfile：

```ruby
platform :ios, '13.0'
use_frameworks!

target 'NetworkDebuggerExample' do
  # 使用本地开发版本
  pod 'NetworkDebugger', :path => '../'
  
  # 或使用已发布版本
  # pod 'NetworkDebugger'
end
```

### 添加截图

在 `Screenshots/` 目录下添加：
- `floating_button.png` - 悬浮按钮
- `http_list.png` - HTTP 列表
- `http_detail.png` - HTTP 详情
- `websocket.png` - WebSocket 消息

### 创建 .gitignore

```gitignore
# Xcode
*.xcuserstate
*.xcworkspace
!default.xcworkspace
xcuserdata/
*.moved-aside
DerivedData/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# CocoaPods
Pods/
Podfile.lock

# Swift Package Manager
.build/
Package.resolved

# macOS
.DS_Store

# Other
*.swp
*~.nib
```

### 推广和维护

#### 1. 添加徽章

在 README.md 中添加：

```markdown
[![Version](https://img.shields.io/cocoapods/v/NetworkDebugger.svg?style=flat)](https://cocoapods.org/pods/NetworkDebugger)
[![License](https://img.shields.io/cocoapods/l/NetworkDebugger.svg?style=flat)](https://cocoapods.org/pods/NetworkDebugger)
[![Platform](https://img.shields.io/cocoapods/p/NetworkDebugger.svg?style=flat)](https://cocoapods.org/pods/NetworkDebugger)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
```

#### 2. 提交到 Awesome 列表

- [awesome-ios](https://github.com/vsouza/awesome-ios)
- [awesome-swift](https://github.com/matteocrippa/awesome-swift)

#### 3. 写博客文章

在以下平台发布介绍文章：
- 掘金
- CSDN
- 简书
- Medium

#### 4. 社交媒体推广

- Twitter
- 微博
- 开发者社区

### 持续维护

#### 定期更新

```bash
# 每次更新流程
1. 修改代码
2. 更新 CHANGELOG.md
3. 更新版本号（podspec）
4. 提交并推送
5. 创建新 tag
6. 验证 podspec
7. 发布到 CocoaPods
```

#### 处理 Issue

- 及时回复用户问题
- 修复 Bug
- 考虑新功能请求

#### 兼容性测试

- 测试不同 iOS 版本
- 测试不同 Xcode 版本
- 测试不同网络库

### 检查清单

发布前确认：

- [ ] 代码已测试
- [ ] README 完整
- [ ] LICENSE 文件存在
- [ ] CHANGELOG 已更新
- [ ] 截图已添加
- [ ] 示例项目可运行
- [ ] podspec 验证通过
- [ ] Git tag 已创建
- [ ] 版本号正确

### 有用的命令

```bash
# 搜索已发布的 Pod
pod search NetworkDebugger

# 查看 Pod 信息
pod trunk info NetworkDebugger

# 删除版本（慎用！）
pod trunk delete NetworkDebugger 1.0.0

# 添加协作者
pod trunk add-owner NetworkDebugger email@example.com

# 查看统计
pod trunk stats NetworkDebugger
```

### 参考资源

- [CocoaPods 官方指南](https://guides.cocoapods.org/)
- [如何创建 CocoaPods 库](https://guides.cocoapods.org/making/making-a-cocoapod.html)
- [Podspec 语法参考](https://guides.cocoapods.org/syntax/podspec.html)

---

祝你发布顺利！🎉
