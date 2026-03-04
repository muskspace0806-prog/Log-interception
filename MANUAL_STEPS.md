# ZWB_LogTap 手动完成步骤

## ✅ 已自动完成的工作

我已经帮你完成了以下工作：

1. ✅ **项目结构整理** - 所有代码文件已移动到正确的目录
   ```
   ZWB_LogTap/
   ├── Classes/
   │   ├── Core/        (4个文件)
   │   ├── Models/      (2个文件)
   │   ├── UI/          (6个文件)
   │   └── ZWBLogTap.swift
   ```

2. ✅ **Git 仓库初始化** - 已创建本地 Git 仓库并提交
3. ✅ **版本标签** - 已创建 1.0.2 标签
4. ✅ **访问权限修复** - 模型类已设为 public
5. ✅ **文档准备** - 所有必要文档已创建
6. ✅ **代码错误修复** - 修复了 WebSocketMessage.swift 中的类型错误
7. ✅ **Podspec 验证通过** - 本地验证已成功通过

## 📋 需要你手动完成的步骤

### 步骤 1: 添加截图（重要！）

在 `Screenshots/` 目录下添加以下截图：

1. **floating_button.png** - 悬浮按钮截图
2. **http_list.png** - HTTP 日志列表截图
3. **http_detail.png** - HTTP 详情页面截图
4. **websocket.png** - WebSocket 消息截图

**如何截图：**
- 运行你的应用
- 使用 Cmd+S (模拟器) 或 电源键+音量上键 (真机)
- 将截图重命名并放到 Screenshots 目录

### 步骤 2: 创建 GitHub 仓库

1. **在 GitHub 上创建新仓库**
   - 访问: https://github.com/new
   - 仓库名: `ZWB_LogTap`
   - 描述: `A powerful iOS network debugging tool for HTTP and WebSocket`
   - 选择: Public（公开）
   - 不要勾选 "Initialize this repository with a README"

2. **连接到远程仓库**

打开终端，在项目目录执行：

```bash
# 添加远程仓库（替换 YOUR_USERNAME 为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/ZWB_LogTap.git

# 推送代码
git push -u origin main

# 推送标签
git push origin 1.0.2
```

### 步骤 3: 更新 Podspec 中的 URL

编辑 `ZWB_LogTap.podspec` 文件，将以下内容：

```ruby
s.homepage         = 'https://github.com/yourusername/ZWB_LogTap'
s.author           = { 'ZWB' => 'your.email@example.com' }
s.source           = { :git => 'https://github.com/yourusername/ZWB_LogTap.git', :tag => s.version.to_s }
```

替换为你的实际信息：

```ruby
s.homepage         = 'https://github.com/YOUR_USERNAME/ZWB_LogTap'
s.author           = { 'ZWB' => 'your_email@example.com' }
s.source           = { :git => 'https://github.com/YOUR_USERNAME/ZWB_LogTap.git', :tag => s.version.to_s }
```

然后提交更改：

```bash
git add ZWB_LogTap.podspec
git commit -m "Update podspec with correct GitHub URL"
git push
```

### 步骤 4: 验证 Podspec

```bash
# 本地验证
pod lib lint ZWB_LogTap.podspec --allow-warnings

# 远程验证
pod spec lint ZWB_LogTap.podspec --allow-warnings
```

如果验证失败，查看错误信息并修复。

### 步骤 5: 注册 CocoaPods Trunk（一次性操作）

```bash
# 注册账号
pod trunk register your_email@example.com 'ZWB' --description='MacBook Pro'

# 检查邮箱，点击验证链接

# 验证注册状态
pod trunk me
```

### 步骤 6: 发布到 CocoaPods

```bash
# 推送到 CocoaPods
pod trunk push ZWB_LogTap.podspec --allow-warnings

# 查看发布状态
pod trunk info ZWB_LogTap
```

### 步骤 7: 验证安装

创建一个新项目测试：

```ruby
# Podfile
platform :ios, '13.0'
use_frameworks!

target 'TestApp' do
  pod 'ZWB_LogTap', '~> 1.0.2'
end
```

```bash
pod install
```

### 步骤 8: 更新 README 中的截图链接

等待 CocoaPods 索引完成后（可能需要几小时），更新 README.md 中的截图链接。

## 🔍 故障排除

### 问题 1: Podspec 验证失败

**解决方案：**
- 检查 GitHub 仓库是否可访问
- 确保 Git tag 已推送
- 查看详细错误信息：`pod lib lint --verbose`

### 问题 2: 无法推送到 GitHub

**解决方案：**
- 检查 GitHub 仓库是否已创建
- 确认 remote URL 是否正确：`git remote -v`
- 可能需要配置 SSH 密钥或使用 Personal Access Token

### 问题 3: CocoaPods 注册失败

**解决方案：**
- 检查邮箱是否正确
- 查看垃圾邮件文件夹
- 等待几分钟后重试

## 📞 需要帮助？

如果遇到问题：

1. 查看 [PUBLISHING_GUIDE.md](PUBLISHING_GUIDE.md) 详细指南
2. 查看 [CocoaPods 官方文档](https://guides.cocoapods.org/)
3. 在 GitHub 上提 Issue

## ✨ 完成后

发布成功后，其他开发者就可以这样使用你的库了：

```ruby
pod 'ZWB_LogTap', '~> 1.0.2'
```

```swift
import ZWB_LogTap

ZWBLogTap.startIfDebug()
```

---

祝你发布顺利！🎉
