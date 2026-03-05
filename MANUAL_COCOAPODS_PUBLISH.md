# 手动发布 CocoaPods 指南

## 当前状态

✅ **已完成：**
- 代码已推送到 GitHub
- 标签 1.0.4 已创建并推送
- podspec 验证通过

❌ **遇到问题：**
- CocoaPods 环境错误：`cannot load such file -- ffi_c`
- Ruby 版本太旧（2.6.10），需要 Ruby 3.0+

## 解决方案

### 方案 1：升级 Ruby（推荐）

```bash
# 安装 Homebrew（如果没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 rbenv
brew install rbenv ruby-build

# 安装最新的 Ruby
rbenv install 3.3.0
rbenv global 3.3.0

# 重新安装 CocoaPods
gem install cocoapods

# 然后发布
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

### 方案 2：使用 CocoaPods 网页发布

1. 访问 https://trunk.cocoapods.org/
2. 登录你的账号
3. 手动上传 `ZWB_LogTap.podspec`

### 方案 3：等待自动同步

GitHub 上的 tag 已经创建，CocoaPods 可能会自动检测并同步（需要几小时到1天）。

## 验证发布

发布成功后，验证：

```bash
# 搜索 pod
pod search ZWB_LogTap

# 查看版本
pod spec cat ZWB_LogTap
```

## 临时解决方案

如果急需使用，可以直接从 GitHub 安装：

```ruby
# 在 Podfile 中
pod 'ZWB_LogTap', :git => 'https://github.com/muskspace0806-prog/Log-interception.git', :tag => '1.0.4'
```

## 当前可用链接

- GitHub Release: https://github.com/muskspace0806-prog/Log-interception/releases/tag/1.0.4
- GitHub Code: https://github.com/muskspace0806-prog/Log-interception/tree/1.0.4
- CocoaPods: https://cocoapods.org/pods/ZWB_LogTap (等待更新)

## 下次发布建议

1. 先升级 Ruby 到 3.0+
2. 重新安装 CocoaPods
3. 确保 `pod trunk push` 能正常工作
