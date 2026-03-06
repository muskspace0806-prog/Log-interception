# 添加新文件到 Xcode 项目

## 问题

运行项目时显示的还是旧界面，这是因为新添加的文件没有被包含在 Xcode 项目中。

## 解决方法

### 方式一：在 Xcode 中手动添加（推荐）

1. **打开 Xcode 项目**
   - 打开 `日志拦截工具.xcodeproj`

2. **找到 ZWB_LogTap 文件夹**
   - 在左侧项目导航器中找到 `日志拦截工具/ZWB_LogTap/Classes`

3. **添加新文件**
   - 右键点击 `Classes/Core` 文件夹
   - 选择 "Add Files to '日志拦截工具'..."
   - 找到并选择以下文件：
     - ✅ `EnvironmentManager.swift`
     - ✅ `NetworkSimulator.swift`
     - ✅ `CrashMonitor.swift`
     - ✅ `MemoryMonitor.swift`
   
   - 右键点击 `Classes/UI` 文件夹
   - 选择 "Add Files to '日志拦截工具'..."
   - 找到并选择以下文件：
     - ✅ `FloatingInfoWindow.swift`
     - ✅ `DebugToolsViewController.swift`
     - ✅ `NetworkSimulatorViewController.swift`
     - ✅ `CrashLogViewController.swift`
     - ✅ `CrashLogDetailViewController.swift`
     - ✅ `MemoryMonitorViewController.swift`

4. **确保勾选正确的 Target**
   - 在添加文件对话框中，确保勾选了 `日志拦截工具` target
   - 点击 "Add"

5. **Clean Build Folder**
   - 按 `Cmd + Shift + K` 清理构建
   - 或者菜单：Product → Clean Build Folder

6. **重新编译运行**
   - 按 `Cmd + R` 运行项目

### 方式二：删除引用后重新添加

如果文件已经在项目中但显示红色（找不到）：

1. **删除红色引用**
   - 在 Xcode 左侧找到红色的文件
   - 右键 → Delete → Remove Reference（不要选 Move to Trash）

2. **重新添加文件**
   - 按照方式一的步骤重新添加

### 方式三：检查文件是否在 Target 中

1. **选择文件**
   - 在 Xcode 左侧选择任意一个新文件（如 `EnvironmentManager.swift`）

2. **查看右侧面板**
   - 打开右侧的 File Inspector（按 `Cmd + Option + 1`）
   - 找到 "Target Membership" 部分
   - 确保 `日志拦截工具` 被勾选

3. **对所有新文件重复此操作**

## 需要添加的新文件清单

### Core 文件夹
- [x] EnvironmentManager.swift ⭐ 新增
- [x] NetworkSimulator.swift ⭐ 新增
- [x] CrashMonitor.swift ⭐ 新增
- [x] MemoryMonitor.swift ⭐ 新增

### UI 文件夹
- [x] FloatingInfoWindow.swift ⭐ 新增
- [x] DebugToolsViewController.swift ⭐ 新增
- [x] NetworkSimulatorViewController.swift ⭐ 新增
- [x] CrashLogViewController.swift ⭐ 新增
- [x] CrashLogDetailViewController.swift ⭐ 新增
- [x] MemoryMonitorViewController.swift ⭐ 新增

### 已存在但需要更新的文件
- [x] ZWBLogTap.swift ⭐ 已更新
- [x] FloatingButton.swift ⭐ 已更新
- [x] NetworkLogViewController.swift ⭐ 已更新

## 验证是否成功

运行项目后，应该看到：

1. ✅ 悬浮按钮是蓝色的（测试环境）
2. ✅ 点击悬浮按钮后，顶部有"工具"按钮
3. ✅ 点击"工具"按钮，能看到：
   - 环境配置
     - 🌍 环境切换
   - 性能检测
     - 🌐 模拟弱网
     - 💥 Crash 日志
     - 💾 内存监控
   - 日志管理
     - 🔍 HTTP 日志
     - 💬 IM 日志

## 常见问题

### Q: 添加文件后还是看不到新功能？

A: 尝试以下步骤：
1. Clean Build Folder（Cmd + Shift + K）
2. 删除 DerivedData：
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. 重启 Xcode
4. 重新运行项目

### Q: 编译报错找不到某个类？

A: 检查该类所在的文件是否已添加到项目中，并且 Target Membership 是否正确。

### Q: 为什么会出现这个问题？

A: 因为我们是通过命令行复制文件的，Xcode 不会自动检测到新文件。需要手动添加到项目中。

## 快速检查脚本

运行以下命令检查文件是否存在：

```bash
# 检查 Core 文件
ls -la 日志拦截工具/ZWB_LogTap/Classes/Core/EnvironmentManager.swift
ls -la 日志拦截工具/ZWB_LogTap/Classes/Core/NetworkSimulator.swift
ls -la 日志拦截工具/ZWB_LogTap/Classes/Core/CrashMonitor.swift
ls -la 日志拦截工具/ZWB_LogTap/Classes/Core/MemoryMonitor.swift

# 检查 UI 文件
ls -la 日志拦截工具/ZWB_LogTap/Classes/UI/FloatingInfoWindow.swift
ls -la 日志拦截工具/ZWB_LogTap/Classes/UI/DebugToolsViewController.swift
ls -la 日志拦截工具/ZWB_LogTap/Classes/UI/NetworkSimulatorViewController.swift
ls -la 日志拦截工具/ZWB_LogTap/Classes/UI/CrashLogViewController.swift
ls -la 日志拦截工具/ZWB_LogTap/Classes/UI/CrashLogDetailViewController.swift
ls -la 日志拦截工具/ZWB_LogTap/Classes/UI/MemoryMonitorViewController.swift
```

如果所有文件都存在，那就是 Xcode 项目配置的问题，需要在 Xcode 中手动添加。
