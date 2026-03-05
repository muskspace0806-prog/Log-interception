# ZWB_LogTap v1.0.4 发布步骤

## 已完成
- ✅ 更新版本号到 1.0.4
- ✅ 更新 CHANGELOG.md
- ✅ 更新 README.md
- ✅ 提交代码到 Git
- ✅ 创建 tag 1.0.4

## 需要手动完成

### 1. 推送到 GitHub

```bash
# 推送代码
git push origin main

# 推送标签
git push origin 1.0.4
```

### 2. 验证 podspec

```bash
pod lib lint ZWB_LogTap.podspec --allow-warnings
```

### 3. 发布到 CocoaPods

```bash
pod trunk push ZWB_LogTap.podspec --allow-warnings
```

## 或者使用自动脚本

```bash
./release_1.0.4.sh
```

## 发布内容

### 主要更新
- ✅ Alamofire 自动拦截支持
- ✅ WebSocket 手动日志记录 API（5个方法）
- ⚠️ 禁用 WebSocket 自动拦截（技术限制）

### Bug 修复
- 🐛 修复详情页面布局问题（支持小屏幕）
- 🐛 修复 URLSessionConfiguration Hook 类型问题
- 🐛 修复内容区域底部约束

### 文档
- 📖 WebSocket 手动日志记录完整指南
- 📖 WebSocket 快速参考
- 📖 Alamofire 和 SocketRocket 支持说明
- 📖 WebSocket 技术限制说明

## 验证发布

发布成功后，验证以下内容：

1. GitHub Release 页面显示 v1.0.4
2. CocoaPods 搜索显示 1.0.4 版本
3. README 在 GitHub 上正确显示

## 链接

- GitHub: https://github.com/muskspace0806-prog/Log-interception
- CocoaPods: https://cocoapods.org/pods/ZWB_LogTap
