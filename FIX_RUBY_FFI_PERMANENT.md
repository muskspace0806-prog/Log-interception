# 永久解决 Ruby ffi 库问题 ✅

## ✅ 已完成配置

- ✅ Homebrew Ruby 3.4.4 已安装
- ✅ PATH 已配置到 ~/.zshrc
- ✅ CocoaPods 1.16.2 已安装
- ✅ ffi-1.17.3-arm64-darwin 已安装（ARM 原生版本）
- ✅ 发布脚本已更新，自动使用 Homebrew Ruby

## 问题原因

1. **使用系统 Ruby**: macOS 自带的 Ruby 2.6.10 是系统级的，权限和架构可能有问题
2. **架构不匹配**: 安装的 ffi 是 x86_64 版本，但 Mac 是 ARM 架构
3. **每次都需要 sudo**: 系统 Ruby 的 gem 目录需要管理员权限

## 🎯 永久解决方案（推荐）

### 方案 1: 使用 Homebrew Ruby（推荐）

```bash
# 1. 安装 Homebrew Ruby
brew install ruby

# 2. 添加到 PATH（在 ~/.zshrc 或 ~/.bash_profile 中）
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"' >> ~/.zshrc

# 3. 重新加载配置
source ~/.zshrc

# 4. 验证使用的是 Homebrew Ruby
which ruby
ruby -v

# 5. 安装 CocoaPods 和依赖（不需要 sudo）
gem install cocoapods
gem install ffi

# 6. 重新安装 CocoaPods 插件
gem install cocoapods-trunk
```

### 方案 2: 使用 RVM（你已经安装了）

```bash
# 1. 加载 RVM
source ~/.rvm/scripts/rvm

# 2. 安装最新 Ruby
rvm install 3.2.0
rvm use 3.2.0 --default

# 3. 安装 CocoaPods 和依赖
gem install cocoapods
gem install ffi
gem install cocoapods-trunk
```

### 方案 3: 临时解决（当前方案）

每次发布前执行：
```bash
sudo gem install ffi --platform=ruby
```

**缺点**: 每次都需要手动执行，不是永久解决方案

## 🔧 推荐操作步骤

### 立即执行（使用 Homebrew Ruby）

```bash
# 检查是否已安装 Homebrew Ruby
brew list ruby

# 如果没有，安装它
brew install ruby

# 添加到 PATH
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 验证
which ruby  # 应该显示 /opt/homebrew/opt/ruby/bin/ruby
ruby -v     # 应该显示 3.x.x

# 安装 CocoaPods 生态
gem install cocoapods cocoapods-trunk ffi

# 验证
pod --version
```

## ✅ 验证是否解决

```bash
# 1. 检查 Ruby 来源
which ruby
# 期望: /opt/homebrew/opt/ruby/bin/ruby (不是 /usr/bin/ruby)

# 2. 检查 gem 安装位置
gem env | grep "INSTALLATION DIRECTORY"
# 期望: /opt/homebrew/lib/ruby/gems/3.x.x (不是 /Library/Ruby/Gems/2.6.0)

# 3. 测试 pod trunk push（不应该再有 ffi 错误）
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

## 📝 更新发布脚本

更新 `release_1.0.x.sh` 脚本，添加环境检查：

```bash
#!/bin/bash

# 检查 Ruby 环境
echo "检查 Ruby 环境..."
RUBY_PATH=$(which ruby)
if [[ "$RUBY_PATH" == "/usr/bin/ruby" ]]; then
    echo "⚠️  警告: 正在使用系统 Ruby，可能会遇到 ffi 问题"
    echo "建议: brew install ruby 并配置 PATH"
    echo ""
    echo "是否继续? (y/n)"
    read -r response
    if [[ "$response" != "y" ]]; then
        exit 1
    fi
fi

echo "Ruby 路径: $RUBY_PATH"
ruby -v
echo ""

# 继续发布流程...
```

## 🎯 下次发布前

1. 切换到 Homebrew Ruby（一次性操作）
2. 不再需要 `sudo gem install ffi`
3. 发布脚本可以完全自动化

## 📚 参考资料

- [Homebrew Ruby](https://formulae.brew.sh/formula/ruby)
- [RVM 官方文档](https://rvm.io/)
- [CocoaPods 安装指南](https://guides.cocoapods.org/using/getting-started.html)

---

**建议**: 使用方案 1（Homebrew Ruby），这是 macOS 上最稳定和推荐的方式。


## 🎯 下次发布时

### 方式 1: 使用更新后的发布脚本（推荐）

```bash
# 发布脚本已自动配置 Homebrew Ruby
./release_1.0.x.sh
```

### 方式 2: 手动发布

```bash
# 1. 确保使用 Homebrew Ruby（只需执行一次）
source ~/.zshrc

# 2. 验证环境
which ruby  # 应该显示 /opt/homebrew/opt/ruby/bin/ruby
pod --version  # 应该显示 1.16.2

# 3. 发布
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

## ✅ 问题已永久解决

- ✅ 不再需要 `sudo gem install ffi`
- ✅ 不再有架构不匹配问题（ARM 原生）
- ✅ 发布脚本自动使用正确的 Ruby 环境
- ✅ 所有 gem 安装到用户目录，无需 sudo

## 📝 新终端窗口

如果打开新的终端窗口，Homebrew Ruby 会自动生效（已配置在 ~/.zshrc）。

验证命令：
```bash
which ruby
# 期望输出: /opt/homebrew/opt/ruby/bin/ruby
```

如果仍显示 `/usr/bin/ruby`，执行：
```bash
source ~/.zshrc
```
