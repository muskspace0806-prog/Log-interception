#!/bin/bash

# 同步 ZWB_LogTap 文件到当前项目
# 用于保持两个文件夹的代码一致

echo "🔄 开始同步文件..."

# 同步 Core 文件
echo "📦 同步 Core 文件..."
cp -v ZWB_LogTap/Classes/Core/*.swift 日志拦截工具/ZWB_LogTap/Classes/Core/

# 同步 UI 文件
echo "📦 同步 UI 文件..."
cp -v ZWB_LogTap/Classes/UI/*.swift 日志拦截工具/ZWB_LogTap/Classes/UI/

# 同步 Models 文件
echo "📦 同步 Models 文件..."
cp -v ZWB_LogTap/Classes/Models/*.swift 日志拦截工具/ZWB_LogTap/Classes/Models/

# 同步主文件
echo "📦 同步主文件..."
cp -v ZWB_LogTap/Classes/ZWBLogTap.swift 日志拦截工具/ZWB_LogTap/Classes/

echo "✅ 同步完成！"
echo ""
echo "已同步的文件："
echo "  - Core: NetworkInterceptor, NetworkInterceptorManager, RuntimeHooker, WebSocketInterceptor"
echo "  - Core: NetworkSimulator, CrashMonitor, MemoryMonitor, EnvironmentManager"
echo "  - UI: FloatingButton, FloatingInfoWindow, NetworkLogViewController, NetworkLogCell"
echo "  - UI: NetworkLogDetailViewController, WebSocketMessageCell, WebSocketMessageDetailViewController"
echo "  - UI: DebugToolsViewController, NetworkSimulatorViewController, CrashLogViewController"
echo "  - UI: CrashLogDetailViewController, MemoryMonitorViewController"
echo "  - Models: InterceptedRequest, WebSocketMessage"
echo "  - Main: ZWBLogTap.swift"
