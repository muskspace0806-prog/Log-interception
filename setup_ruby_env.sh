#!/bin/bash

# 设置 Homebrew Ruby 环境
# 这个脚本会在发布脚本中自动调用

echo "🔧 设置 Ruby 环境..."

# 添加 Homebrew Ruby 到 PATH
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

# 验证 Ruby 版本
RUBY_PATH=$(which ruby)
RUBY_VERSION=$(ruby -v)

echo "Ruby 路径: $RUBY_PATH"
echo "Ruby 版本: $RUBY_VERSION"

# 检查是否使用系统 Ruby
if [[ "$RUBY_PATH" == "/usr/bin/ruby" ]]; then
    echo "❌ 错误: 仍在使用系统 Ruby"
    echo "请确保已执行以下命令："
    echo "  source ~/.zshrc"
    echo "或者重新打开终端"
    exit 1
fi

# 检查是否使用 Homebrew Ruby
if [[ "$RUBY_PATH" == "/opt/homebrew/opt/ruby/bin/ruby" ]]; then
    echo "✅ 正在使用 Homebrew Ruby"
else
    echo "⚠️  警告: Ruby 路径不是预期的 Homebrew 路径"
fi

# 验证 CocoaPods
if command -v pod &> /dev/null; then
    POD_VERSION=$(pod --version)
    echo "✅ CocoaPods 版本: $POD_VERSION"
else
    echo "❌ 错误: CocoaPods 未安装"
    echo "请执行: gem install cocoapods cocoapods-trunk"
    exit 1
fi

echo "✅ Ruby 环境配置完成"
echo ""
