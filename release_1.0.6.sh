#!/bin/bash

# ZWB_LogTap 1.0.6 发布脚本

set -e

echo "🚀 开始发布 ZWB_LogTap 1.0.6"
echo ""

# 1. 检查工作目录是否干净
echo "📋 检查 Git 状态..."
if [[ -n $(git status -s) ]]; then
    echo "⚠️  工作目录有未提交的更改"
    git status -s
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 2. 确认版本号
echo ""
echo "📝 当前版本信息："
echo "  - podspec: $(grep "s.version" ZWB_LogTap.podspec | awk '{print $3}' | tr -d "'")"
echo "  - README: $(grep "badge/version" README.md | head -1 | sed 's/.*version-\([0-9.]*\)-.*/\1/')"
echo ""
read -p "版本号是否正确？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 请先更新版本号"
    exit 1
fi

# 3. 运行同步脚本
echo ""
echo "🔄 同步文件到当前项目..."
./sync_files.sh

# 4. 提交代码
echo ""
echo "📦 提交代码到 Git..."
git add .
git commit -m "Release 1.0.6

新功能：
- 环境切换功能（测试/正式环境）
- 调试工具集成（模拟弱网、Crash监控、内存监控）
- 分享功能（导出为txt文件）

优化：
- 优化入口按钮尺寸（40x40）
- 优化悬浮窗显示（独立UIWindow）
- 修复iOS 13+悬浮窗显示问题

详见 CHANGELOG.md"

# 5. 创建标签
echo ""
echo "🏷️  创建 Git 标签..."
git tag -a 1.0.6 -m "Release 1.0.6

新功能：
- 🌍 环境切换功能
- 🛠️ 调试工具集成
- 📤 分享功能

优化：
- 🎨 优化入口按钮和悬浮窗
- 🐛 修复悬浮窗显示问题"

# 6. 推送到 GitHub
echo ""
echo "⬆️  推送到 GitHub..."
git push origin main
git push origin 1.0.6

# 7. 验证 podspec
echo ""
echo "✅ 验证 podspec..."
pod lib lint ZWB_LogTap.podspec --allow-warnings

# 8. 发布到 CocoaPods
echo ""
echo "📤 发布到 CocoaPods..."
read -p "是否发布到 CocoaPods Trunk？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    pod trunk push ZWB_LogTap.podspec --allow-warnings
    echo ""
    echo "✅ 已发布到 CocoaPods"
else
    echo "⏭️  跳过 CocoaPods 发布"
    echo ""
    echo "手动发布命令："
    echo "  pod trunk push ZWB_LogTap.podspec --allow-warnings"
fi

# 9. 完成
echo ""
echo "🎉 发布完成！"
echo ""
echo "📋 发布信息："
echo "  - 版本: 1.0.6"
echo "  - GitHub: https://github.com/muskspace0806-prog/Log-interception"
echo "  - CocoaPods: https://cocoapods.org/pods/ZWB_LogTap"
echo ""
echo "📝 后续步骤："
echo "  1. 在 GitHub 上创建 Release（可选）"
echo "  2. 更新项目文档"
echo "  3. 通知用户更新"
echo ""
