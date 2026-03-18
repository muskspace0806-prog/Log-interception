#!/bin/bash

# ZWB_LogTap 发布脚本模板
# 使用方法: ./release_template.sh 1.0.x "发布说明"

set -e

# 设置 Homebrew Ruby 环境（避免 ffi 问题）
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

# 检查参数
if [ -z "$1" ]; then
    echo "❌ 错误: 请提供版本号"
    echo "使用方法: ./release_template.sh 1.0.x \"发布说明\""
    exit 1
fi

VERSION="$1"
RELEASE_NOTES="${2:-Release version ${VERSION}}"

echo "🚀 开始发布 ZWB_LogTap ${VERSION}..."
echo ""

# 验证 Ruby 环境
RUBY_PATH=$(which ruby)
echo "Ruby 路径: $RUBY_PATH"
if [[ "$RUBY_PATH" == "/usr/bin/ruby" ]]; then
    echo "❌ 错误: 正在使用系统 Ruby，可能会遇到 ffi 问题"
    echo "请先执行: source ~/.zshrc 或重新打开终端"
    exit 1
fi
echo "✅ 使用 Homebrew Ruby $(ruby -v | cut -d' ' -f2)"
echo ""

# 1. 检查工作目录是否干净
echo "📋 步骤 1: 检查 Git 状态..."
if [[ -n $(git status -s) ]]; then
    echo "⚠️  工作目录有未提交的更改"
    git status -s
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 发布已取消"
        exit 1
    fi
fi

# 2. 更新 podspec 版本号
echo ""
echo "📋 步骤 2: 更新 podspec 版本号..."
sed -i '' "s/s.version.*=.*/s.version          = '${VERSION}'/" ZWB_LogTap.podspec
echo "✅ podspec 版本号已更新为 ${VERSION}"

# 3. 验证 podspec
echo ""
echo "📋 步骤 3: 验证 podspec..."
pod lib lint ZWB_LogTap.podspec --allow-warnings

if [ $? -ne 0 ]; then
    echo "❌ podspec 验证失败"
    exit 1
fi

echo "✅ podspec 验证通过"

# 4. 提交更改
echo ""
echo "📋 步骤 4: 提交更改到 Git..."
git add .
git commit -m "${RELEASE_NOTES}"

# 5. 创建标签
echo ""
echo "📋 步骤 5: 创建 Git 标签..."
git tag -a ${VERSION} -m "Release ${VERSION}"

# 6. 推送到远程
echo ""
echo "📋 步骤 6: 推送到 GitHub..."
git push origin main
git push origin ${VERSION}

echo "✅ 代码已推送到 GitHub"

# 7. 发布到 CocoaPods
echo ""
echo "📋 步骤 7: 发布到 CocoaPods..."
read -p "是否发布到 CocoaPods? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    pod trunk push ZWB_LogTap.podspec --allow-warnings
    
    if [ $? -eq 0 ]; then
        echo "✅ 已成功发布到 CocoaPods"
        
        # 验证发布
        echo ""
        echo "📋 验证发布..."
        pod trunk info ZWB_LogTap
    else
        echo "❌ CocoaPods 发布失败"
        exit 1
    fi
else
    echo "⏭️  跳过 CocoaPods 发布"
fi

# 完成
echo ""
echo "🎉 ZWB_LogTap ${VERSION} 发布完成！"
echo ""
echo "📝 后续步骤:"
echo "1. 在 GitHub 上创建 Release"
echo "   https://github.com/muskspace0806-prog/Log-interception/releases/new"
echo "2. 选择标签: ${VERSION}"
echo "3. 添加 Release 说明"
echo ""
