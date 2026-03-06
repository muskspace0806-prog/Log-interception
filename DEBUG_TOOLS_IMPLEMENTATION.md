# 调试工具功能实现总结

## 📦 新增文件列表

### Core 层（核心功能）
1. `ZWB_LogTap/Classes/Core/NetworkSimulator.swift` - 模拟弱网
2. `ZWB_LogTap/Classes/Core/CrashMonitor.swift` - Crash 监控
3. `ZWB_LogTap/Classes/Core/MemoryMonitor.swift` - 内存监控

### UI 层（界面）
4. `ZWB_LogTap/Classes/UI/DebugToolsViewController.swift` - 工具入口页面
5. `ZWB_LogTap/Classes/UI/NetworkSimulatorViewController.swift` - 模拟弱网页面
6. `ZWB_LogTap/Classes/UI/CrashLogViewController.swift` - Crash 日志页面
7. `ZWB_LogTap/Classes/UI/MemoryMonitorViewController.swift` - 内存监控页面

### 修改文件
8. `ZWB_LogTap/Classes/UI/NetworkLogViewController.swift` - 添加工具按钮入口

---

## ✨ 功能说明

### 1. 模拟弱网测试 🌐
**功能：**
- 断网模式：模拟网络完全断开
- 超时模式：模拟请求超时
- 限速模式：限制请求/响应速度
- 延迟模式：模拟网络延迟

**使用方式：**
```swift
// 启用断网模式
NetworkSimulator.shared.enable(mode: .disconnect)

// 启用延迟模式（10秒）
NetworkSimulator.shared.delaySeconds = 10.0
NetworkSimulator.shared.enable(mode: .delay)

// 禁用模拟
NetworkSimulator.shared.disable()
```

---

### 2. Crash 日志收集 💥
**功能：**
- 自动捕获 NSException 崩溃
- 自动捕获 Signal 崩溃（SIGABRT, SIGSEGV 等）
- 保存崩溃日志到本地
- 查看崩溃历史记录
- 一键清空日志

**使用方式：**
```swift
// 启用 Crash 监控
CrashMonitor.shared.enable()

// 获取所有崩溃日志
let logs = CrashMonitor.shared.getAllCrashLogs()

// 清空日志
CrashMonitor.shared.clearAllLogs()
```

---

### 3. 内存监控 💾
**功能：**
- 实时监控应用内存使用
- 显示当前内存占用（MB）
- 显示内存使用百分比
- 记录内存历史数据（最多100条）

**使用方式：**
```swift
// 启用内存监控
MemoryMonitor.shared.enable()

// 获取当前内存使用
if let snapshot = MemoryMonitor.shared.getCurrentMemoryUsage() {
    print("使用内存: \(snapshot.usedMemoryMB) MB")
    print("占用率: \(snapshot.usagePercentage)%")
}

// 获取历史记录
let history = MemoryMonitor.shared.getMemoryHistory()
```

---

## 🎨 UI 结构

```
网络日志页面
├─ 顶部工具栏
│  ├─ 关闭按钮
│  ├─ 标题
│  ├─ 🔧 工具按钮 ← 新增入口
│  ├─ 清空按钮
│  └─ 导出按钮
└─ ...

点击 🔧 工具按钮 →

调试工具页面
├─ 性能检测
│  ├─ 🌐 模拟弱网
│  ├─ 💥 Crash 日志
│  └─ 💾 内存监控
└─ 日志管理
   ├─ 🔍 HTTP 日志
   └─ 💬 IM 日志
```

---

## 🚀 使用流程

### 用户操作流程：
1. 点击悬浮按钮 → 打开网络日志页面
2. 点击右上角 🔧 工具按钮 → 打开调试工具页面
3. 选择需要的功能：
   - 模拟弱网：配置网络模拟参数
   - Crash 日志：查看崩溃记录
   - 内存监控：实时查看内存使用

---

## 📝 代码集成

### 在 ZWBLogTap 中启用功能（可选）

```swift
// 在 AppDelegate 中
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 启动网络日志
    ZWBLogTap.startIfDebug()
    
    // 可选：自动启用 Crash 监控
    #if DEBUG
    CrashMonitor.shared.enable()
    #endif
    
    return true
}
```

---

## ⚠️ 注意事项

1. **仅 Debug 模式使用**
   - 所有调试工具仅在开发环境使用
   - 生产环境请禁用

2. **性能影响**
   - 内存监控会每秒采样一次，有轻微性能开销
   - 模拟弱网会影响实际网络请求

3. **Crash 监控限制**
   - 只能捕获 Objective-C 异常和 Signal 崩溃
   - Swift 的 fatalError 等无法捕获

4. **内存监控精度**
   - 显示的是应用实际使用的物理内存
   - 不包括虚拟内存和系统缓存

---

## 🎯 下一步计划

可以考虑的增强功能：
- [ ] 模拟弱网：支持自定义速度和延迟参数
- [ ] Crash 日志：支持导出和分享
- [ ] 内存监控：添加内存泄漏检测
- [ ] 内存监控：添加图表可视化
- [ ] 添加 CPU 使用率监控
- [ ] 添加 FPS 帧率监控

---

Made with ❤️ by ZWB
