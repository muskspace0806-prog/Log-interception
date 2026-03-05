#!/bin/bash

# ZWB_LogTap 发布脚本
# 使用方法：
# 1. 编辑下面的配置信息
# 2. 运行: chmod +x publish.sh
# 3. 运行: ./publish.sh

# ============================================
# 配置信息（请修改为你的信息）
# ============================================

GITHUB_USERNAME="muskspace0806-prog"        # 你的 GitHub 用户名
YOUR_EMAIL="muskspace0806@gmail.com"           # 你的邮箱
YOUR_NAME="ZWB"                               # 你的名字

# ============================================
# 检查配置
# ============================================

if [ "$GITHUB_USERNAME" = "YOUR_GITHUB_USERNAME" ]; then
    echo "❌ 错误: 请先编辑 publish.sh 文件，填入你的 GitHub 用户名"
    echo "   打开文件，修改 GITHUB_USERNAME 变量"
    exit 1
fi

if [ "$YOUR_EMAIL" = "your.email@example.com" ]; then
    echo "❌ 错误: 请先编辑 publish.sh 文件，填入你的邮箱"
    echo "   打开文件，修改 YOUR_EMAIL 变量"
    exit 1
fi

echo "============================================"
echo "ZWB_LogTap 发布脚本"
echo "============================================"
echo ""

# ============================================
# 步骤 1: 更新 Podspec
# ============================================

echo "📝 步骤 1: 更新 Podspec..."

# 备份原文件
cp ZWB_LogTap.podspec ZWB_LogTap.podspec.backup

# 替换 URL
sed -i '' "s|https://github.com/yourusername/ZWB_LogTap|https://github.com/$GITHUB_USERNAME/ZWB_LogTap|g" ZWB_LogTap.podspec

# 替换邮箱
sed -i '' "s|your.email@example.com|$YOUR_EMAIL|g" ZWB_LogTap.podspec

echo "✅ Podspec 已更新"
echo ""

# ============================================
# 步骤 2: 提交更改
# ============================================

echo "📝 步骤 2: 提交更改..."

git add ZWB_LogTap.podspec
git commit -m "Update podspec with correct information"

echo "✅ 更改已提交"
echo ""

# ============================================
# 步骤 3: 添加 GitHub 远程仓库
# ============================================

echo "📝 步骤 3: 配置 GitHub 远程仓库..."

# 检查是否已存在 origin
if git remote | grep -q "^origin$"; then
    echo "⚠️  远程仓库 origin 已存在，跳过添加"
else
    git remote add origin "https://github.com/$GITHUB_USERNAME/ZWB_LogTap.git"
    echo "✅ 已添加远程仓库"
fi

echo ""

# ============================================
# 步骤 4: 推送到 GitHub
# ============================================

echo "📝 步骤 4: 推送到 GitHub..."
echo ""
echo "⚠️  注意: 这一步需要你的 GitHub 认证"
echo "   如果失败，请确保："
echo "   1. 已在 GitHub 上创建了 ZWB_LogTap 仓库"
echo "   2. 已配置 SSH 密钥或 Personal Access Token"
echo ""
read -p "按 Enter 继续推送，或按 Ctrl+C 取消..."

# 推送代码
git push -u origin main

# 推送标签
git push origin 1.0.2

echo "✅ 代码已推送到 GitHub"
echo ""

# ============================================
# 步骤 5: 验证 Podspec
# ============================================

echo "📝 步骤 5: 验证 Podspec..."
echo ""

pod lib lint ZWB_LogTap.podspec --allow-warnings

if [ $? -eq 0 ]; then
    echo "✅ Podspec 验证通过"
else
    echo "❌ Podspec 验证失败"
    echo "   请查看上面的错误信息并修复"
    exit 1
fi

echo ""

# ============================================
# 步骤 6: 注册 CocoaPods Trunk
# ============================================

echo "📝 步骤 6: 注册 CocoaPods Trunk..."
echo ""
echo "⚠️  如果你已经注册过，可以跳过这一步"
echo ""
read -p "是否需要注册 CocoaPods Trunk? (y/n): " need_register

if [ "$need_register" = "y" ] || [ "$need_register" = "Y" ]; then
    pod trunk register "$YOUR_EMAIL" "$YOUR_NAME" --description="MacBook Pro"
    echo ""
    echo "✅ 注册请求已发送"
    echo "📧 请检查你的邮箱 $YOUR_EMAIL"
    echo "   点击邮件中的验证链接"
    echo ""
    read -p "验证完成后，按 Enter 继续..."
else
    echo "⏭️  跳过注册"
fi

echo ""

# ============================================
# 步骤 7: 发布到 CocoaPods
# ============================================

echo "📝 步骤 7: 发布到 CocoaPods..."
echo ""
echo "⚠️  这是最后一步！"
echo "   发布后，全世界的开发者都可以使用你的库了"
echo ""
read -p "确认发布? (y/n): " confirm_publish

if [ "$confirm_publish" = "y" ] || [ "$confirm_publish" = "Y" ]; then
    pod trunk push ZWB_LogTap.podspec --allow-warnings
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "============================================"
        echo "🎉 恭喜！发布成功！"
        echo "============================================"
        echo ""
        echo "现在其他开发者可以这样使用你的库："
        echo ""
        echo "  # Podfile"
        echo "  pod 'ZWB_LogTap', '~> 1.0.2'"
        echo ""
        echo "  # Swift"
        echo "  import ZWB_LogTap"
        echo "  ZWBLogTap.startIfDebug()"
        echo ""
        echo "GitHub: https://github.com/$GITHUB_USERNAME/ZWB_LogTap"
        echo "CocoaPods: https://cocoapods.org/pods/ZWB_LogTap"
        echo ""
    else
        echo "❌ 发布失败"
        echo "   请查看上面的错误信息"
        exit 1
    fi
else
    echo "⏭️  取消发布"
    echo "   你可以稍后手动运行: pod trunk push ZWB_LogTap.podspec --allow-warnings"
fi

echo ""
echo "✅ 脚本执行完成"
