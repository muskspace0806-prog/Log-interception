# Xcode 项目配置步骤

## 当前问题

✅ 文件已同步到 `日志拦截工具/ZWB_LogTap/Classes/` 文件夹
❌ 但 Xcode 项目中没有包含这些新文件
❌ 所以运行时看不到新功能

## 解决步骤（5分钟）

### 步骤 1：打开 Xcode 项目

```bash
open 日志拦截工具.xcodeproj
```

或者双击 `日志拦截工具.xcodeproj` 文件

### 步骤 2：添加 Core 文件

1. 在左侧项目导航器中，找到：
   ```
   日志拦截工具
   └── 日志拦截工具
       └── ZWB_LogTap
           └── Classes
               └── Core
   ```

2. 右键点击 `Core` 文件夹

3. 选择 **"Add Files to '日志拦截工具'..."**

4. 在弹出的文件选择器中，导航到：
   ```
   日志拦截工具/ZWB_LogTap/Classes/Core/
   ```

5. 按住 `Cmd` 键，选择以下 4 个文件：
   - ✅ `EnvironmentManager.swift`
   - ✅ `NetworkSimulator.swift`
   - ✅ `CrashMonitor.swift`
   - ✅ `MemoryMonitor.swift`

6. 确保勾选：
   - ✅ "Copy items if needed" （如果需要）
   - ✅ "Create groups"
   - ✅ Target: `日志拦截工具`

7. 点击 **"Add"**

### 步骤 3：添加 UI 文件

1. 右键点击 `UI` 文件夹

2. 选择 **"Add Files to '日志拦截工具'..."**

3. 在弹出的文件选择器中，导航到：
   ```
   日志拦截工具/ZWB_LogTap/Classes/UI/
   ```

4. 按住 `Cmd` 键，选择以下 6 个文件：
   - ✅ `FloatingInfoWindow.swift`
   - ✅ `DebugToolsViewController.swift`
   - ✅ `NetworkSimulatorViewController.swift`
   - ✅ `CrashLogViewController.swift`
   - ✅ `CrashLogDetailViewController.swift`
   - ✅ `MemoryMonitorViewController.swift`

5. 确保勾选：
   - ✅ "Copy items if needed"
   - ✅ "Create groups"
   - ✅ Target: `日志拦截工具`

6. 点击 **"Add"**

### 步骤 4：Clean Build

1. 按 `Cmd + Shift + K` 清理构建

2. 或者菜单：**Product → Clean Build Folder**

### 步骤 5：重新运行

1. 按 `Cmd + R` 运行项目

2. 或者点击左上角的 ▶️ 按钮

## 验证结果

运行成功后，你应该看到：

### 1. 悬浮按钮颜色
- 🔵 蓝色按钮 = 测试环境（默认）

### 2. 点击悬浮按钮
- 顶部应该有 **"工具"** 按钮（在"清空"和"导出"旁边）

### 3. 点击"工具"按钮
应该看到以下菜单：

```
┌─────────────────────────────┐
│      调试工具               │
├─────────────────────────────┤
│ 环境配置                    │
│ 🌍 环境切换                 │
│    当前: 测试环境           │
├─────────────────────────────┤
│ 性能检测                    │
│ 🌐 模拟弱网                 │
│    断网、限速、延迟等       │
│ 💥 Crash 日志               │
│    查看应用崩溃记录         │
│ 💾 内存监控                 │
│    实时监控内存使用         │
├─────────────────────────────┤
│ 日志管理                    │
│ 🔍 HTTP 日志                │
│    查看网络请求日志         │
│ 💬 IM 日志                  │
│    查看 WebSocket 消息      │
└─────────────────────────────┘
```

### 4. 测试环境切换
1. 点击 **"环境切换"**
2. 确认切换到正式环境
3. 悬浮按钮应该变成 🔴 红色
4. 应该弹出提示："环境已切换"

## 如果还是不行

### 方案 A：检查文件是否在项目中

1. 在 Xcode 左侧，选择 `EnvironmentManager.swift`
2. 按 `Cmd + Option + 1` 打开 File Inspector
3. 查看 **"Target Membership"** 部分
4. 确保 `日志拦截工具` 被勾选 ✅

### 方案 B：删除 DerivedData

```bash
# 关闭 Xcode
# 运行以下命令
rm -rf ~/Library/Developer/Xcode/DerivedData

# 重新打开 Xcode
open 日志拦截工具.xcodeproj
```

### 方案 C：重新创建项目引用

如果文件在 Xcode 中显示为红色（找不到）：

1. 选中红色文件
2. 右键 → **Delete**
3. 选择 **"Remove Reference"**（不要选 Move to Trash）
4. 重新按照步骤 2-3 添加文件

## 快速检查命令

在终端运行以下命令，确认文件都存在：

```bash
# 检查所有新文件
echo "=== Core 文件 ==="
ls -1 日志拦截工具/ZWB_LogTap/Classes/Core/ | grep -E "(Environment|NetworkSimulator|CrashMonitor|MemoryMonitor)"

echo ""
echo "=== UI 文件 ==="
ls -1 日志拦截工具/ZWB_LogTap/Classes/UI/ | grep -E "(FloatingInfo|DebugTools|NetworkSimulator|CrashLog|MemoryMonitor)"
```

应该输出：
```
=== Core 文件 ===
CrashMonitor.swift
EnvironmentManager.swift
MemoryMonitor.swift
NetworkSimulator.swift

=== UI 文件 ===
CrashLogDetailViewController.swift
CrashLogViewController.swift
DebugToolsViewController.swift
FloatingInfoWindow.swift
MemoryMonitorViewController.swift
NetworkSimulatorViewController.swift
```

## 总结

问题的根本原因：
- ✅ 文件已经复制到文件系统
- ❌ 但 Xcode 项目配置文件（.pbxproj）中没有这些文件的引用
- ❌ 所以编译时不会包含这些文件

解决方法：
- 在 Xcode 中手动添加文件到项目
- 确保文件的 Target Membership 正确
- Clean Build 后重新运行

完成这些步骤后，环境切换功能就可以正常使用了！
