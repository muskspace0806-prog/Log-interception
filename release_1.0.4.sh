#!/bin/bash

echo "========================================="
echo "ZWB_LogTap v1.0.4 发布脚本"
echo "========================================="
echo ""

# 1. 推送代码到 GitHub
echo "步骤 1: 推送代码到 GitHub..."
git push origin main
if [ $? -ne 0 ]; then
    echo "❌ 推送失败，请检查 SSH 密钥"
    exit 1
fi
echo "✅ 代码推送成功"
echo ""

# 2. 推送标签到 GitHub
echo "步骤 2: 推送标签到 GitHub..."
git push origin 1.0.4
if [ $? -ne 0 ]; then
    echo "❌ 标签推送失败"
    exit 1
fi
echo "✅ 标签推送成功"
echo ""

# 3. 验证 podspec
echo "步骤 3: 验证 podspec..."
pod lib lint ZWB_LogTap.podspec --allow-warnings
if [ $? -ne 0 ]; then
    echo "❌ podspec 验证失败"
    exit 1
fi
echo "✅ podspec 验证成功"
echo ""

# 4. 发布到 CocoaPods
echo "步骤 4: 发布到 CocoaPods..."
echo "⚠️  需要输入 CocoaPods Trunk 密码"
pod trunk push ZWB_LogTap.podspec --allow-warnings
if [ $? -ne 0 ]; then
    echo "❌ CocoaPods 发布失败"
    exit 1
fi
echo "✅ CocoaPods 发布成功"
echo ""

echo "========================================="
echo "🎉 v1.0.4 发布完成！"
echo "========================================="
echo ""
echo "GitHub: https://github.com/muskspace0806-prog/Log-interception"
echo "CocoaPods: https://cocoapods.org/pods/ZWB_LogTap"
echo ""
echo "更新日志："
echo "- ✅ Alamofire 自动拦截支持"
echo "- ✅ WebSocket 手动日志记录 API"
echo "- 🐛 修复详情页面布局问题"
echo "- 📖 新增完整文档"
