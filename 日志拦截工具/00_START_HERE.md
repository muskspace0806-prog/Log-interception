# 🎯 从这里开始

欢迎使用 iOS 网络日志拦截工具！

## 📦 你得到了什么？

一个功能完整的 iOS 网络请求拦截和日志查看工具，类似你看到的 Android 版本。

### ✨ 核心功能
- ✅ 拦截所有 URLSession 网络请求
- ✅ 可拖拽的悬浮按钮（点击隐藏，长按显示日志）
- ✅ 完整的日志列表和详情页面
- ✅ 搜索、过滤、导出功能
- ✅ JSON 自动格式化显示
- ✅ 实时显示请求耗时和状态码

---

## 🚀 快速开始（5 分钟）

### 方式 1: 快速集成（推荐新手）
👉 阅读 [QUICK_START.md](QUICK_START.md)

这是最简单的方式，只需 3 个步骤：
1. 添加 7 个文件到项目
2. 更新 AppDelegate 和 SceneDelegate
3. 运行测试

### 方式 2: 详细安装（推荐仔细了解）
👉 阅读 [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)

包含详细的安装步骤、常见问题排查和验证清单。

---

## 📚 文档导航

### 必读文档
1. **[QUICK_START.md](QUICK_START.md)** - 5 分钟快速开始
2. **[README.md](README.md)** - 完整功能说明和使用方法

### 参考文档
3. **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** - 详细安装步骤
4. **[FEATURES_DEMO.md](FEATURES_DEMO.md)** - 功能演示和使用场景
5. **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - 项目架构和技术细节
6. **[FILES_SUMMARY.txt](FILES_SUMMARY.txt)** - 文件清单

---

## 📁 文件说明

### 🔧 核心功能文件（必须添加到项目）
```
NetworkInterceptor.swift              (5.2K)  - 网络拦截核心
InterceptedRequest.swift              (3.1K)  - 数据模型
NetworkInterceptorManager.swift       (3.4K)  - 拦截管理器
FloatingButton.swift                  (6.4K)  - 悬浮按钮
NetworkLogViewController.swift        (9.5K)  - 日志列表页面
NetworkLogCell.swift                  (5.5K)  - 列表单元格
NetworkLogDetailViewController.swift  (8.5K)  - 详情页面
```

### 📝 配置文件（需要更新现有文件）
```
AppDelegate_Updated.swift             (937B)  - 启动拦截
SceneDelegate_Updated.swift           (2.1K)  - 显示悬浮按钮
ViewController_Updated.swift          (3.6K)  - 测试页面（可选）
```

### 📖 文档文件（参考学习）
```
00_START_HERE.md                      (本文件) - 开始指南
QUICK_START.md                        (4.4K)  - 快速开始
README.md                             (6.1K)  - 完整说明
INSTALLATION_GUIDE.md                 (6.0K)  - 安装指南
FEATURES_DEMO.md                      (10K)   - 功能演示
PROJECT_STRUCTURE.md                  (12K)   - 项目架构
FILES_SUMMARY.txt                     (5.3K)  - 文件清单
```

---

## 🎯 推荐学习路径

### 路径 1: 快速上手（适合赶时间）
```
1. 阅读 QUICK_START.md（5 分钟）
   ↓
2. 按步骤集成到项目（5 分钟）
   ↓
3. 运行测试（1 分钟）
   ↓
4. 开始使用！
```

### 路径 2: 深入理解（适合学习）
```
1. 阅读 README.md 了解功能（10 分钟）
   ↓
2. 阅读 INSTALLATION_GUIDE.md 详细安装（15 分钟）
   ↓
3. 阅读 FEATURES_DEMO.md 了解使用场景（10 分钟）
   ↓
4. 阅读 PROJECT_STRUCTURE.md 理解架构（15 分钟）
   ↓
5. 自定义和扩展功能
```

---

## ⚡️ 3 步快速集成

### 步骤 1: 添加文件
将这 7 个文件拖入 Xcode 项目：
- NetworkInterceptor.swift
- InterceptedRequest.swift
- NetworkInterceptorManager.swift
- FloatingButton.swift
- NetworkLogViewController.swift
- NetworkLogCell.swift
- NetworkLogDetailViewController.swift

### 步骤 2: 更新 AppDelegate
在 `didFinishLaunchingWithOptions` 中添加：
```swift
NetworkInterceptorManager.shared.startIntercepting()
```

### 步骤 3: 更新 SceneDelegate
参考 `SceneDelegate_Updated.swift` 添加悬浮按钮代码。

详细步骤请看 [QUICK_START.md](QUICK_START.md)

---

## 🎬 使用演示

### 基本操作
```
1. 启动应用 → 看到右下角悬浮按钮 📊
2. 拖拽按钮 → 移动到任意位置
3. 点击按钮 → 隐藏按钮
4. 长按按钮 → 显示网络日志列表
5. 点击列表项 → 查看详细信息
```

### 日志列表功能
- 🔍 搜索框：搜索 URL
- 🎛️ 过滤器：按方法（GET/POST）或状态（成功/失败）过滤
- 🗑️ 清空按钮：清空所有日志
- 📤 导出按钮：导出为 JSON

### 详情页面
7 个标签页展示完整信息：
1. 基本信息 - 时间、状态码、耗时
2. URL 信息 - 完整 URL 和参数
3. 请求 Headers
4. 请求 Body
5. 响应 Headers
6. 响应 Body（JSON 自动格式化）
7. 异常信息

---

## 🎨 界面预览

### 悬浮按钮
```
右下角蓝色按钮 📊
- 可拖拽移动
- 自动吸附边缘
- 点击隐藏
- 长按显示日志
```

### 日志列表
```
┌─────────────────────────────┐
│ 关闭  HTTP日志  清空 导出    │
├─────────────────────────────┤
│ 🔍 搜索...                  │
├─────────────────────────────┤
│ [全部][GET][POST][成功][失败]│
├─────────────────────────────┤
│ GET  200  /api/users  115ms │
│ POST 200  /api/login   75ms │
│ GET  404  /api/error   97ms │
└─────────────────────────────┘
```

---

## ❓ 常见问题

### Q: 需要什么 iOS 版本？
A: iOS 13.0 及以上

### Q: 支持 Swift 版本？
A: Swift 5.0 及以上

### Q: 会影响性能吗？
A: 拦截会增加 10-50ms 延迟，建议仅在开发环境使用

### Q: 可以拦截第三方库的请求吗？
A: 可以！只要是基于 URLSession 的库（如 Alamofire）都能拦截

### Q: 如何在生产环境禁用？
A: 使用编译条件：
```swift
#if DEBUG
NetworkInterceptorManager.shared.startIntercepting()
#endif
```

更多问题请查看 [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) 的常见问题部分。

---

## 🔧 技术实现

### 核心技术
- **URLProtocol** - 拦截网络请求
- **UIKit** - 原生 UI 实现
- **手势识别** - 拖拽和点击
- **通知中心** - 实时更新

### 架构设计
```
UI 层 → 业务层 → 核心层 → 系统层
  ↓       ↓        ↓        ↓
视图   管理器   拦截器   URLProtocol
```

详细架构请看 [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

---

## 🎓 学习资源

### 了解功能
- [README.md](README.md) - 完整功能说明
- [FEATURES_DEMO.md](FEATURES_DEMO.md) - 使用场景演示

### 安装集成
- [QUICK_START.md](QUICK_START.md) - 快速开始
- [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) - 详细安装

### 深入理解
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - 架构设计
- [FILES_SUMMARY.txt](FILES_SUMMARY.txt) - 文件说明

---

## 🌟 特色功能

### 1. 可拖拽悬浮按钮
- 随意移动位置
- 自动吸附边缘
- 点击隐藏，长按显示
- 震动反馈

### 2. 实时网络拦截
- 拦截所有 URLSession 请求
- 记录完整请求和响应
- 显示耗时和状态码
- 支持 JSON 格式化

### 3. 强大的搜索过滤
- 实时搜索 URL
- 按方法过滤（GET/POST）
- 按状态过滤（成功/失败）
- 组合过滤

### 4. 详细的日志信息
- 7 个标签页
- 完整的 Headers 和 Body
- JSON 自动格式化
- 错误信息展示

### 5. 导出功能
- 导出为 JSON 格式
- 支持分享
- 便于分析和存档

---

## 📊 项目统计

- **总文件数：** 16 个
- **核心代码：** 7 个文件，~1070 行
- **配置文件：** 3 个文件
- **文档文件：** 6 个文件
- **总大小：** ~90KB

---

## 🎉 开始使用

### 现在就开始！

1. 📖 阅读 [QUICK_START.md](QUICK_START.md)
2. ⚡ 5 分钟快速集成
3. 🚀 开始调试网络请求

---

## 💡 提示

- ✅ 建议先在测试项目中尝试
- ✅ 仔细阅读 QUICK_START.md
- ✅ 遇到问题查看 INSTALLATION_GUIDE.md
- ✅ 生产环境记得禁用拦截

---

## 📞 需要帮助？

1. 查看 [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) 的常见问题
2. 检查 Xcode 控制台的错误信息
3. 确保所有文件正确添加到项目
4. 清理项目（Cmd + Shift + K）后重新编译

---

## 📄 许可证

MIT License - 可自由使用和修改

---

**🎊 祝你使用愉快！开始探索强大的网络调试功能吧！**

---

## 下一步

👉 立即开始：[QUICK_START.md](QUICK_START.md)
