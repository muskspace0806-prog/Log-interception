# ZWB_LogTap 发布步骤清单

## ✅ 已完成的工作

我已经为你准备好了以下文件：

1. ✅ **ZWB_LogTap.podspec** - CocoaPods 配置文件（版本 1.0.2）
2. ✅ **ZWBLogTap.swift** - 重命名的主入口类
3. ✅ **README.md** - 完整的项目说明文档
4. ✅ **CHANGELOG.md** - 版本更新日志
5. ✅ **LICENSE** - MIT 许可证
6. ✅ **QUICK_START.md** - 快速开始指南
7. ✅ **PROJECT_STRUCTURE.md** - 项目结构说明
8. ✅ **PUBLISHING_GUIDE.md** - 详细的发布指南
9. ✅ **.gitignore** - Git 忽略文件配置

## 📋 接下来需要做的事情

### 第一步：整理项目结构

需要将现有代码按照以下结构重新组织：

```
ZWB_LogTap/
├── ZWB_LogTap/
│   └── Classes/
│       ├── Core/
│       │   ├── NetworkInterceptor.swift
│       │   ├── NetworkInterceptorManager.swift
│       │   ├── WebSocketInterceptor.swift
│       │   └── RuntimeHooker.swift
│       ├── Models/
│       │   ├── InterceptedRequest.swift
│       │   └── WebSocketMessage.swift
│       ├── UI/
│       │   ├── FloatingButton.swift
│       │   ├── NetworkLogViewController.swift
│       │   ├── NetworkLogCell.swift
│       │   ├── NetworkLogDetailViewController.swift
│       │   ├── WebSocketMessageCell.swift
│       │   └── WebSocketMessageDetailViewController.swift
│       └── ZWBLogTap.swift
```

**操作步骤：**

```bash
# 1. 创建目录结构
mkdir -p ZWB_LogTap/Classes/Core
mkdir -p ZWB_LogTap/Classes/Models
mkdir -p ZWB_LogTap/Classes/UI

# 2. 移动文件到对应目录
# Core 模块
mv 日志拦截工具/NetworkInterceptor.swift ZWB_LogTap/Classes/Core/
mv 日志拦截工具/NetworkInterceptorManager.swift ZWB_LogTap/Classes/Core/
mv 日志拦截工具/WebSocketInterceptor.swift ZWB_LogTap/Classes/Core/
mv 日志拦截工具/RuntimeHooker.swift ZWB_LogTap/Classes/Core/

# Models 模块
mv 日志拦截工具/InterceptedRequest.swift ZWB_LogTap/Classes/Models/
mv 日志拦截工具/WebSocketMessage.swift ZWB_LogTap/Classes/Models/

# UI 模块
mv 日志拦截工具/FloatingButton.swift ZWB_LogTap/Classes/UI/
mv 日志拦截工具/NetworkLogViewController.swift ZWB_LogTap/Classes/UI/
mv 日志拦截工具/NetworkLogCell.swift ZWB_LogTap/Classes/UI/
mv 日志拦截工具/NetworkLogDetailViewController.swift ZWB_LogTap/Classes/UI/
mv 日志拦截工具/WebSocketMessageCell.swift ZWB_LogTap/Classes/UI/
mv 日志拦截工具/WebSocketMessageDetailViewController.swift ZWB_LogTap/Classes/UI/

# 主入口
mv 日志拦截工具/ZWBLogTap.swift ZWB_LogTap/Classes/
```

### 第二步：创建 GitHub 仓库

1. **在 GitHub 上创建新仓库**
   - 仓库名：`ZWB_LogTap`
   - 描述：A powerful iOS network debugging tool for HTTP and WebSocket
   - 公开仓库
   - 不要初始化 README（我们已经有了）

2. **初始化本地 Git 仓库**

```bash
# 初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit - ZWB_LogTap v1.0.2"

# 添加远程仓库（替换为你的 GitHub 用户名）
git remote add origin https://github.com/你的用户名/ZWB_LogTap.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

3. **创建版本标签**

```bash
# 创建 1.0.2 标签
git tag 1.0.2

# 推送标签
git push origin 1.0.2
```

### 第三步：准备截图

在 `Screenshots/` 目录下添加以下截图：

1. **floating_button.png** - 悬浮按钮截图
2. **http_list.png** - HTTP 日志列表截图
3. **http_detail.png** - HTTP 详情页面截图
4. **websocket.png** - WebSocket 消息截图

**建议尺寸：** 750x1334 (iPhone 8) 或 1125x2436 (iPhone X)

### 第四步：创建示例项目（可选但推荐）

```bash
# 创建示例项目目录
mkdir -p Example/ZWB_LogTapExample

# 在 Example 目录下创建一个简单的 iOS 项目
# 在 Podfile 中使用本地路径引用
```

示例 Podfile：

```ruby
platform :ios, '13.0'
use_frameworks!

target 'ZWB_LogTapExample' do
  pod 'ZWB_LogTap', :path => '../'
end
```

### 第五步：验证 Podspec

```bash
# 本地验证
pod lib lint ZWB_LogTap.podspec --verbose

# 如果有警告但想忽略
pod lib lint ZWB_LogTap.podspec --allow-warnings

# 远程验证（需要先推送到 GitHub）
pod spec lint ZWB_LogTap.podspec --verbose
```

**常见问题解决：**

如果验证失败，检查：
- [ ] 文件路径是否正确
- [ ] Git tag 是否已创建
- [ ] GitHub 仓库是否可访问
- [ ] Swift 版本是否匹配

### 第六步：注册 CocoaPods Trunk

```bash
# 注册账号（只需要做一次）
pod trunk register 你的邮箱@example.com 'ZWB' --description='MacBook Pro'

# 检查邮箱，点击验证链接

# 验证注册状态
pod trunk me
```

### 第七步：发布到 CocoaPods

```bash
# 推送到 CocoaPods Trunk
pod trunk push ZWB_LogTap.podspec

# 如果有警告但想忽略
pod trunk push ZWB_LogTap.podspec --allow-warnings

# 查看发布状态
pod trunk info ZWB_LogTap
```

### 第八步：验证安装

创建一个新项目测试安装：

```ruby
# Podfile
pod 'ZWB_LogTap', '~> 1.0.2'
```

```bash
pod install
```

### 第九步：推广

1. **更新 README 徽章**
   - 等待 CocoaPods 索引完成（可能需要几小时）
   - 徽章会自动生效

2. **写博客文章**
   - 掘金
   - CSDN
   - 简书

3. **提交到 Awesome 列表**
   - [awesome-ios](https://github.com/vsouza/awesome-ios)
   - [awesome-swift](https://github.com/matteocrippa/awesome-swift)

4. **社交媒体**
   - Twitter
   - 微博
   - 开发者社区

## 📝 检查清单

发布前确认：

- [ ] 代码已整理到正确的目录结构
- [ ] 所有文件都已提交到 Git
- [ ] Git tag 1.0.2 已创建
- [ ] GitHub 仓库已创建并推送
- [ ] 截图已添加
- [ ] Podspec 验证通过
- [ ] CocoaPods Trunk 已注册
- [ ] 已成功发布到 CocoaPods

## 🆘 需要帮助？

如果遇到问题：

1. 查看 [PUBLISHING_GUIDE.md](PUBLISHING_GUIDE.md) 详细指南
2. 查看 [CocoaPods 官方文档](https://guides.cocoapods.org/)
3. 在 GitHub 上提 Issue

## 📞 联系方式

- GitHub: https://github.com/你的用户名/ZWB_LogTap
- Email: 你的邮箱@example.com

---

祝你发布顺利！🎉

如果一切顺利，大约 1-2 小时后，其他开发者就可以通过以下方式使用你的库了：

```ruby
pod 'ZWB_LogTap', '~> 1.0.2'
```

```swift
import ZWB_LogTap

ZWBLogTap.startIfDebug()
```
