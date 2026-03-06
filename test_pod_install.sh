#!/bin/bash

# 测试 1.0.5 是否可以安装

echo "测试 ZWB_LogTap 1.0.5 是否可用..."
echo ""

# 创建临时测试目录
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# 创建测试 Podfile
cat > Podfile << 'EOF'
platform :ios, '13.0'

target 'TestApp' do
  use_frameworks!
  pod 'ZWB_LogTap', '1.0.5'
end
EOF

echo "Podfile 内容："
cat Podfile
echo ""
echo "正在执行 pod install --verbose --no-repo-update..."
echo ""

pod install --verbose --no-repo-update 2>&1 | grep -A 5 "ZWB_LogTap"

echo ""
echo "测试完成！"
echo "临时目录: $TEST_DIR"
