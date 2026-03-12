# 手动发布 1.0.6 到 CocoaPods

## ✅ 已完成的步骤

1. ✅ 代码已提交到 Git
2. ✅ 标签 1.0.6 已创建
3. ✅ 代码已推送到 GitHub
4. ✅ podspec 验证通过

## ⚠️ 当前问题

遇到 FFI 依赖问题：`cannot load such file -- ffi_c`

这是系统 Ruby 的已知问题。

## 🔧 解决方案

### 方案一：使用 rbenv（推荐）

```bash
# 1. 安装 rbenv（如果还没安装）
brew install rbenv ruby-build

# 2. 安装最新的 Ruby
rbenv install 3.3.0
rbenv global 3.3.0

# 3. 重新安装 CocoaPods
gem install cocoapods

# 4. 发布
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

### 方案二：修复系统 Ruby 的 FFI

```bash
# 1. 卸载旧的 ffi
sudo gem uninstall ffi

# 2. 重新安装 ffi
sudo gem install ffi

# 3. 发布
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

### 方案三：使用 Homebrew Ruby

```bash
# 1. 确保 Homebrew Ruby 在 PATH 中
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# 2. 使用 Homebrew Ruby 安装 CocoaPods
gem install cocoapods

# 3. 发布
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

### 方案四：跳过 CDN 更新

```bash
# 使用 --skip-import-validation 和 --verbose
pod trunk push ZWB_LogTap.podspec --allow-warnings --skip-import-validation --verbose
```

## 📝 发布命令

修复 Ruby 环境后，运行：

```bash
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

## ✅ 验证发布

发布成功后，验证：

```bash
# 1. 搜索版本
pod search ZWB_LogTap

# 2. 查看详情
pod spec cat ZWB_LogTap

# 3. 尝试安装
pod try ZWB_LogTap
```

## 📋 发布状态

- [x] 代码已提交
- [x] 标签已创建
- [x] GitHub 已更新
- [x] podspec 已验证
- [ ] CocoaPods 已发布 ⬅️ 需要手动完成

## 🔗 相关链接

- GitHub: https://github.com/muskspace0806-prog/Log-interception
- Tag 1.0.6: https://github.com/muskspace0806-prog/Log-interception/releases/tag/1.0.6
- CocoaPods: https://cocoapods.org/pods/ZWB_LogTap

## 💡 临时解决方案

如果急需发布，可以：

1. 在另一台 Mac 上发布
2. 使用 Docker 容器发布
3. 请其他有正常 Ruby 环境的开发者帮忙发布

## 📞 需要帮助？

如果问题持续，可以：
1. 查看 CocoaPods 官方文档
2. 在 CocoaPods GitHub 提 Issue
3. 联系 CocoaPods 社区

---

**注意：** 代码已经成功推送到 GitHub，用户可以通过 Git 直接使用。CocoaPods 发布只是为了方便安装。
