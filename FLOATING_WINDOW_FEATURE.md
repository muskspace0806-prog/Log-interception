# 悬浮窗功能说明

## ✨ 新增功能

所有调试工具开启后，会在屏幕上显示一个**半透明可拖拽的悬浮小窗**，实时显示功能状态。

---

## 🎨 悬浮窗特性

### 1. 外观
- **半透明黑色背景**（透明度 70%）
- **圆角设计**（12px 圆角）
- **白色边框**（半透明）
- **白色文字**（易读）

### 2. 交互
- ✅ **可拖拽** - 长按拖动到任意位置
- ✅ **自动吸附** - 拖动结束后自动吸附到屏幕边缘
- ✅ **限制范围** - 不会拖出屏幕外
- ✅ **关闭按钮** - 右上角红色 X 按钮

### 3. 关闭行为
点击 X 按钮后：
- 关闭悬浮窗
- 关闭对应功能
- 同步更新开关状态

---

## 📱 三个功能的悬浮窗

### 1. 内存监控 💾

**显示内容：**
```
💾 内存监控
使用: 333.2 MB
总计: 3687.7 MB
占用: 9.0%
```

**更新频率：** 每秒更新一次

**开启方式：**
- 进入"内存监控"页面
- 打开"内存检测开关"
- 悬浮窗自动显示

---

### 2. 模拟弱网 🌐

**显示内容（限速模式）：**
```
🌐 模拟弱网
模式: 限速
请求: 2000 KB/s
响应: 2000 KB/s
```

**显示内容（延迟模式）：**
```
🌐 模拟弱网
模式: 延迟
延迟: 10秒
```

**配置方式：**
- 限速和延迟参数可以在页面中**手动输入**
- 输入框支持数字键盘
- 修改后实时更新悬浮窗显示

**开启方式：**
- 进入"模拟弱网"页面
- 选择模式（断网/超时/限速/延迟）
- 配置参数（限速/延迟可输入）
- 打开"弱网模式"开关
- 悬浮窗自动显示

---

### 3. Crash 监控 💥

**显示内容：**
```
💥 Crash 监控
已收集: 0 条
```

**特殊行为：**
- **默认开启** - 进入页面时自动开启
- **自动显示悬浮窗** - 开启后立即显示
- **实时更新** - 捕获到新崩溃时更新计数

**开启方式：**
- 进入"Crash 日志"页面
- 默认已开启，悬浮窗自动显示
- 可手动关闭/开启

---

## 🔧 技术实现

### FloatingInfoWindow 组件

**文件位置：** `ZWB_LogTap/Classes/UI/FloatingInfoWindow.swift`

**核心功能：**
```swift
class FloatingInfoWindow: UIView {
    // 显示悬浮窗
    func show(in view: UIView)
    
    // 更新内容
    func updateContent(_ text: String)
    
    // 关闭回调
    var onClose: (() -> Void)?
}
```

**使用示例：**
```swift
// 创建悬浮窗
floatingWindow = FloatingInfoWindow()

// 设置关闭回调
floatingWindow?.onClose = { [weak self] in
    self?.enableSwitch.isOn = false
    self?.floatingWindow = nil
}

// 显示在 window 上
floatingWindow?.show(in: window)

// 更新内容
floatingWindow?.updateContent("💾 内存: 333.2 MB")
```

---

## 📝 修改的文件

### 新增文件
1. `ZWB_LogTap/Classes/UI/FloatingInfoWindow.swift` - 悬浮窗组件

### 修改文件
2. `ZWB_LogTap/Classes/UI/MemoryMonitorViewController.swift` - 添加悬浮窗
3. `ZWB_LogTap/Classes/UI/NetworkSimulatorViewController.swift` - 添加悬浮窗和输入框
4. `ZWB_LogTap/Classes/UI/CrashLogViewController.swift` - 添加悬浮窗和默认开启
5. `ZWB_LogTap/Classes/Core/NetworkSimulator.swift` - 配置属性改为可变

---

## 🎯 用户体验

### 优点
1. ✅ **实时可见** - 无需打开页面即可查看状态
2. ✅ **不遮挡内容** - 可拖动到任意位置
3. ✅ **快速关闭** - 点击 X 即可关闭
4. ✅ **状态同步** - 关闭悬浮窗同时关闭功能

### 使用场景
- **内存监控** - 测试时实时查看内存变化
- **模拟弱网** - 确认当前网络模拟状态
- **Crash 监控** - 随时查看崩溃收集情况

---

## ⚠️ 注意事项

1. **悬浮窗层级**
   - 显示在最顶层 window 上
   - 不会被其他视图遮挡

2. **内存管理**
   - 关闭悬浮窗时自动释放
   - 使用 weak self 避免循环引用

3. **定时器管理**
   - 内存监控每秒更新一次
   - 关闭悬浮窗时自动停止定时器

4. **输入验证**
   - 限速和延迟参数使用数字键盘
   - 输入非法值时使用默认值

---

## 🚀 下一步优化

可以考虑的增强功能：
- [ ] 悬浮窗大小可调整
- [ ] 支持双击展开/收起详细信息
- [ ] 支持多个悬浮窗同时显示
- [ ] 添加悬浮窗透明度调节
- [ ] 添加悬浮窗主题切换

---

Made with ❤️ by ZWB
