#!/bin/bash

# ZWB_LogTap 1.0.7 发布脚本

set -e

VERSION="1.0.7"
echo "🚀 开始发布 ZWB_LogTap ${VERSION}..."

# 1. 检查工作目录是否干净
echo ""
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

# 2. 验证 podspec
echo ""
echo "📋 步骤 2: 验证 podspec..."
pod lib lint ZWB_LogTap.podspec --allow-warnings

if [ $? -ne 0 ]; then
    echo "❌ podspec 验证失败"
    exit 1
fi

echo "✅ podspec 验证通过"

# 3. 提交更改
echo ""
echo "📋 步骤 3: 提交更改到 Git..."
git add .
git commit -m "Release version ${VERSION}

新功能:
- 响应数据解密功能（AES-128-CBC）
- 多环境解密配置
- URL 过滤功能
- URL 过滤规则管理

优化:
- URL 参数迁移到请求 Body 标签
- HTTP 详情页默认显示响应 Body
- 优化按钮布局
- 调整浮动按钮底部距离

修复:
- 修复浮动按钮与 tabBar 重叠问题
"

# 4. 创建标签
echo ""
echo "📋 步骤 4: 创建 Git 标签..."
git tag -a ${VERSION} -m "Release ${VERSION}"

# 5. 推送到远程
echo ""
echo "📋 步骤 5: 推送到 GitHub..."
git push origin main
git push origin ${VERSION}

echo "✅ 代码已推送到 GitHub"

# 6. 发布到 CocoaPods
echo ""
echo "📋 步骤 6: 发布到 CocoaPods..."
read -p "是否发布到 CocoaPods? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    pod trunk push ZWB_LogTap.podspec --allow-warnings
    
    if [ $? -eq 0 ]; then
        echo "✅ 已成功发布到 CocoaPods"
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
echo "1. 在 GitHub 上创建 Release (https://github.com/YOUR_USERNAME/ZWB_LogTap/releases/new)"
echo "2. 使用标签: ${VERSION}"
echo "3. 复制 RELEASE_NOTES_1.0.7.md 的内容作为 Release 说明"
echo ""
