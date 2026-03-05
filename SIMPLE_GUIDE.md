# 超简单发布指南

## 方式一：使用自动化脚本（推荐）

### 1. 编辑配置

打开 `publish.sh` 文件，修改前3行：

```bash
GITHUB_USERNAME="你的GitHub用户名"        # 比如: "zhangsan"
YOUR_EMAIL="你的邮箱@example.com"         # 比如: "zhangsan@gmail.com"
YOUR_NAME="ZWB"                           # 保持不变或改成你的名字
```

### 2. 在 GitHub 创建仓库

1. 访问: https://github.com/new
2. 仓库名输入: `ZWB_LogTap`
3. 选择 Public（公开）
4. 点击 "Create repository"

### 3. 运行脚本

在终端执行：

```bash
./publish.sh
```

按照提示操作即可！

---

## 方式二：手动执行（如果脚本失败）

### 步骤 1: 更新 Podspec

编辑 `ZWB_LogTap.podspec`，把这3行：

```ruby
s.homepage = 'https://github.com/yourusername/ZWB_LogTap'
s.author = { 'ZWB' => 'your.email@example.com' }
s.source = { :git => 'https://github.com/yourusername/ZWB_LogTap.git', :tag => s.version.to_s }
```

改成：

```ruby
s.homepage = 'https://github.com/你的用户名/ZWB_LogTap'
s.author = { 'ZWB' => '你的邮箱@example.com' }
s.source = { :git => 'https://github.com/你的用户名/ZWB_LogTap.git', :tag => s.version.to_s }
```

### 步骤 2: 在 GitHub 创建仓库

1. 访问: https://github.com/new
2. 仓库名: `ZWB_LogTap`
3. 选择 Public
4. 点击 "Create repository"

### 步骤 3: 推送代码

```bash
# 提交更改
git add ZWB_LogTap.podspec
git commit -m "Update podspec"

# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/ZWB_LogTap.git

# 推送代码
git push -u origin main

# 推送标签
git push origin 1.0.2
```

### 步骤 4: 验证 Podspec

```bash
pod lib lint ZWB_LogTap.podspec --allow-warnings
```

### 步骤 5: 注册 CocoaPods

```bash
# 注册（替换邮箱）
pod trunk register 你的邮箱@example.com 'ZWB'

# 检查邮箱，点击验证链接

# 验证注册
pod trunk me
```

### 步骤 6: 发布

```bash
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

---

## 常见问题

### Q: GitHub 推送失败？

**A:** 可能需要配置认证：

```bash
# 方式1: 使用 Personal Access Token
# 1. 访问: https://github.com/settings/tokens
# 2. 生成新 token
# 3. 推送时使用 token 作为密码

# 方式2: 使用 SSH
# 1. 生成 SSH 密钥: ssh-keygen -t ed25519 -C "your_email@example.com"
# 2. 添加到 GitHub: https://github.com/settings/keys
# 3. 使用 SSH URL: git@github.com:YOUR_USERNAME/ZWB_LogTap.git
```

### Q: Podspec 验证失败？

**A:** 查看错误信息：

```bash
pod lib lint ZWB_LogTap.podspec --verbose
```

常见原因：
- GitHub 仓库不存在或无法访问
- Git tag 没有推送
- 代码有编译错误

### Q: CocoaPods 注册没收到邮件？

**A:** 
- 检查垃圾邮件文件夹
- 等待几分钟
- 确认邮箱地址正确

### Q: 发布后多久能用？

**A:** 
- 发布成功后立即可用
- CocoaPods 索引更新可能需要几小时
- 可以先用 GitHub 地址测试：

```ruby
pod 'ZWB_LogTap', :git => 'https://github.com/YOUR_USERNAME/ZWB_LogTap.git', :tag => '1.0.2'
```

---

## 需要帮助？

- 查看详细指南: [MANUAL_STEPS.md](MANUAL_STEPS.md)
- 查看发布指南: [PUBLISHING_GUIDE.md](PUBLISHING_GUIDE.md)
- GitHub Issues: https://github.com/YOUR_USERNAME/ZWB_LogTap/issues

---

祝你发布顺利！🎉
