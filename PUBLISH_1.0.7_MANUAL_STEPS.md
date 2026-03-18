# ZWB_LogTap 1.0.7 手动发布步骤

## ✅ 已完成的步骤

1. ✅ 代码已提交到 Git
2. ✅ 已创建 1.0.7 标签
3. ✅ 代码已推送到 GitHub
4. ✅ podspec 验证通过

## 📋 需要手动完成的步骤

### 1. 发布到 CocoaPods

在终端执行以下命令：

```bash
cd ~/Desktop/Github库/日志拦截工具
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

这个命令需要：
- 输入系统密码（如果需要）
- 等待 CocoaPods 验证和发布（可能需要几分钟）

### 2. 在 GitHub 上创建 Release

1. 访问：https://github.com/muskspace0806-prog/Log-interception/releases/new
2. 选择标签：`1.0.7`
3. Release 标题：`v1.0.7 - 响应解密与 URL 过滤`
4. 复制 `RELEASE_NOTES_1.0.7.md` 的内容作为 Release 说明
5. 点击"Publish release"

## 📝 Release 说明内容

复制以下内容到 GitHub Release：

---

# ZWB_LogTap 1.0.7

## 🎉 新功能

### 响应数据解密
- 支持 AES-128-CBC 解密
- 多环境解密配置（测试/正式环境）
- HTTP 响应 Body 自动解密
- WebSocket (IM) 消息自动解密

### URL 过滤
- 支持 URL 过滤规则（模糊匹配）
- 过滤规则持久化存储
- 支持 HTTP 和 WebSocket 过滤

### UI 优化
- URL 参数迁移到请求 Body 标签
- HTTP 详情页默认显示响应 Body
- 优化按钮布局
- 调整浮动按钮位置

## 📦 安装

```ruby
pod 'ZWB_LogTap', '~> 1.0.7'
```

---

## ✅ 发布完成后

发布成功后，更新以下文档：
- README.md（更新版本号和新功能说明）
- 通知团队成员更新依赖

