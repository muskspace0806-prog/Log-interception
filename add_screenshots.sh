#!/bin/bash

# 添加截图到项目的脚本

echo "📸 ZWB_LogTap 截图添加指南"
echo "================================"
echo ""
echo "请将以下 5 张截图保存到 Screenshots 目录："
echo ""
echo "1. main_screen.png    - 主界面（显示两个测试按钮）"
echo "2. http_list.png      - HTTP 请求列表"
echo "3. http_detail.png    - HTTP 请求详情"
echo "4. im_list.png        - WebSocket 消息列表"
echo "5. im_detail.png      - WebSocket 消息详情"
echo ""
echo "================================"
echo ""

# 检查截图是否存在
SCREENSHOTS_DIR="Screenshots"
REQUIRED_SCREENSHOTS=("main_screen.png" "http_list.png" "http_detail.png" "im_list.png" "im_detail.png")

echo "检查截图文件..."
echo ""

MISSING_COUNT=0
for screenshot in "${REQUIRED_SCREENSHOTS[@]}"; do
    if [ -f "$SCREENSHOTS_DIR/$screenshot" ]; then
        echo "✅ $screenshot - 已存在"
    else
        echo "❌ $screenshot - 缺失"
        ((MISSING_COUNT++))
    fi
done

echo ""
echo "================================"

if [ $MISSING_COUNT -eq 0 ]; then
    echo "🎉 所有截图都已准备好！"
    echo ""
    echo "现在可以更新 README 并提交："
    echo "  1. 运行: ./update_readme_with_screenshots.sh"
    echo "  2. 提交: git add Screenshots/*.png README.md"
    echo "  3. 推送: git commit -m 'Add screenshots' && git push"
else
    echo "⚠️  还缺少 $MISSING_COUNT 张截图"
    echo ""
    echo "如何截图："
    echo "  模拟器: Cmd + S"
    echo "  真机: 电源键 + 音量上键"
    echo ""
    echo "截图后，将文件重命名并移动到 Screenshots 目录"
fi

echo ""
