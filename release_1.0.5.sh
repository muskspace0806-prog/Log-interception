#!/bin/bash

# 发布 ZWB_LogTap 1.0.5 版本脚本

set -e  # 遇到错误立即退出

VERSION="1.0.5"
REPO_URL="https://github.com/muskspace0806-prog/Log-interception.git"

echo "=========================================="
echo "开始发布 ZWB_LogTap v${VERSION}"
echo "=========================================="

# 1. 检查是否有未提交的更改
echo ""
echo "步骤 1: 检查工作区状态..."
if [[ -n $(git status -s) ]]; then
    echo "发现未提交的更改，正在提交..."
    git add .
    git commit -m "Release version ${VERSION} - 完善请求Body展示"
else
    echo "工作区干净，无需提交"
fi

# 2. 推送到 GitHub
echo ""
echo "步骤 2: 推送代码到 GitHub..."
git push origin main || git push origin master

# 3. 创建并推送 tag
echo ""
echo "步骤 3: 创建 Git Tag..."
if git rev-parse "${VERSION}" >/dev/null 2>&1; then
    echo "Tag ${VERSION} 已存在，删除旧 tag..."
    git tag -d "${VERSION}"
    git push origin ":refs/tags/${VERSION}"
fi

git tag -a "${VERSION}" -m "Release ${VERSION} - 完善请求Body展示"
git push origin "${VERSION}"

# 4. 验证 Podspec
echo ""
echo "步骤 4: 验证 Podspec..."
pod lib lint ZWB_LogTap.podspec --allow-warnings

# 5. 发布到 CocoaPods
echo ""
echo "步骤 5: 发布到 CocoaPods..."
echo "即将执行: pod trunk push ZWB_LogTap.podspec --allow-warnings"
echo "请准备输入密码..."
sleep 2

pod trunk push ZWB_LogTap.podspec --allow-warnings

echo ""
echo "=========================================="
echo "✅ 发布完成！"
echo "=========================================="
echo ""
echo "版本: ${VERSION}"
echo "GitHub: ${REPO_URL}"
echo "CocoaPods: https://cocoapods.org/pods/ZWB_LogTap"
echo ""
echo "请访问以下链接确认："
echo "1. GitHub Releases: https://github.com/muskspace0806-prog/Log-interception/releases"
echo "2. CocoaPods: https://cocoapods.org/pods/ZWB_LogTap"
echo ""
