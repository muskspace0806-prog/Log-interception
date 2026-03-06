# 文件同步指南

## 项目结构说明

本项目包含两个 ZWB_LogTap 文件夹：

1. **`ZWB_LogTap/`** - 用于发布到 CocoaPods 的版本
2. **`日志拦截工具/ZWB_LogTap/`** - 当前项目使用的版本

## 为什么需要同步？

当你在 `ZWB_LogTap/` 中更新代码后，需要同步到 `日志拦截工具/ZWB_LogTap/` 才能在当前项目中测试。

## 同步方法

### 方式一：使用同步脚本（推荐）

```bash
./sync_files.sh
```

这个脚本会自动复制所有文件。

### 方式二：手动复制

```bash
# 同步 Core 文件
cp ZWB_LogTap/Classes/Core/*.swift 日志拦截工具/ZWB_LogTap/Classes/Core/

# 同步 UI 文件
cp ZWB_LogTap/Classes/UI/*.swift 日志拦截工具/ZWB_LogTap/Classes/UI/

# 同步 Models 文件
cp ZWB_LogTap/Classes/Models/*.swift 日志拦截工具/ZWB_LogTap/Classes/Models/

# 同步主文件
cp ZWB_LogTap/Classes/ZWBLogTap.swift 日志拦截工具/ZWB_LogTap/Classes/
```

## 开发流程

1. **修改代码** - 在 `ZWB_LogTap/` 中修改
2. **同步文件** - 运行 `./sync_files.sh`
3. **测试** - 在当前项目中运行测试
4. **提交** - 确认无误后提交到 Git
5. **发布** - 使用 `release_*.sh` 脚本发布到 CocoaPods

## 需要同步的文件

### Core 文件
- NetworkInterceptor.swift
- NetworkInterceptorManager.swift
- RuntimeHooker.swift
- WebSocketInterceptor.swift
- NetworkSimulator.swift
- CrashMonitor.swift
- MemoryMonitor.swift
- EnvironmentManager.swift ⭐ 新增

### UI 文件
- FloatingButton.swift ⭐ 已更新（支持环境颜色）
- FloatingInfoWindow.swift ⭐ 新增
- NetworkLogViewController.swift
- NetworkLogCell.swift
- NetworkLogDetailViewController.swift
- WebSocketMessageCell.swift
- WebSocketMessageDetailViewController.swift
- DebugToolsViewController.swift ⭐ 已更新（新增环境切换）
- NetworkSimulatorViewController.swift ⭐ 新增
- CrashLogViewController.swift ⭐ 新增
- CrashLogDetailViewController.swift ⭐ 新增
- MemoryMonitorViewController.swift ⭐ 新增

### Models 文件
- InterceptedRequest.swift
- WebSocketMessage.swift

### 主文件
- ZWBLogTap.swift ⭐ 已更新（新增环境管理方法）

## 最新更新（环境切换功能）

已同步的新功能：

1. **EnvironmentManager.swift** - 环境管理器
2. **ZWBLogTap.swift** - 新增环境管理方法
   - `setEnvironmentSwitchCallback(_:)`
   - `currentEnvironment`
   - `switchEnvironment()`
   - `switchTo(environment:)`
3. **FloatingButton.swift** - 支持环境颜色
   - `updateEnvironmentColor()`
4. **DebugToolsViewController.swift** - 新增环境切换入口

## 验证同步

运行项目后，检查以下功能：

1. ✅ 悬浮按钮颜色（蓝色=测试，红色=正式）
2. ✅ 点击悬浮按钮 → 工具 → 环境切换
3. ✅ 切换环境后按钮颜色自动更新
4. ✅ 环境切换回调正常触发

## 注意事项

1. **始终先修改 `ZWB_LogTap/`**，然后同步到 `日志拦截工具/ZWB_LogTap/`
2. **不要直接修改 `日志拦截工具/ZWB_LogTap/`**，否则下次同步会被覆盖
3. **同步后记得测试**，确保功能正常
4. **提交前检查两个文件夹的代码是否一致**

## 常见问题

### Q: 为什么有两个文件夹？

A: `ZWB_LogTap/` 是 CocoaPods 的标准结构，用于发布。`日志拦截工具/ZWB_LogTap/` 是当前项目的测试环境。

### Q: 如果忘记同步会怎样？

A: 当前项目会使用旧代码，新功能无法测试。发布到 CocoaPods 后，其他项目会使用新代码。

### Q: 可以只同步部分文件吗？

A: 可以，但不推荐。建议每次都完整同步，避免版本不一致。

## 自动化建议

可以在 Git pre-commit hook 中添加同步检查：

```bash
#!/bin/bash
# .git/hooks/pre-commit

# 检查是否需要同步
if git diff --cached --name-only | grep -q "^ZWB_LogTap/"; then
    echo "⚠️  检测到 ZWB_LogTap/ 文件变更"
    echo "📝 请运行 ./sync_files.sh 同步到当前项目"
    echo ""
    read -p "是否已同步？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
```
