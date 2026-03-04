//
//  ZWBLogTap.swift
//  ZWB_LogTap
//
//  网络调试工具主入口
//

import UIKit

public class ZWBLogTap {
    
    /// 单例
    public static let shared = ZWBLogTap()
    
    /// 是否启用
    public private(set) var isEnabled = false
    
    /// 悬浮按钮
    private var floatingButton: FloatingButton?
    
    /// 配置选项
    public struct Configuration {
        /// 是否显示悬浮按钮
        public var showFloatingButton: Bool = true
        
        /// 是否拦截 HTTP 请求
        public var interceptHTTP: Bool = true
        
        /// 是否拦截 WebSocket
        public var interceptWebSocket: Bool = true
        
        /// 最大记录数
        public var maxRecords: Int = 1000
        
        /// 悬浮按钮初始位置
        public var floatingButtonPosition: FloatingButtonPosition = .bottomRight
        
        public init() {}
    }
    
    /// 悬浮按钮位置
    public enum FloatingButtonPosition {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 启动网络调试工具
    /// - Parameter configuration: 配置选项
    public func start(with configuration: Configuration = Configuration()) {
        guard !isEnabled else {
            print("⚠️ ZWB_LogTap 已经启动")
            return
        }
        
        isEnabled = true
        
        // 启动 HTTP 拦截
        if configuration.interceptHTTP {
            NetworkInterceptorManager.shared.startIntercepting()
            NetworkInterceptor.maxRecords = configuration.maxRecords
            print("✅ HTTP 拦截已启动")
        }
        
        // 启动 WebSocket 拦截
        if configuration.interceptWebSocket {
            WebSocketInterceptor.shared.startIntercepting()
            WebSocketInterceptor.maxRecords = configuration.maxRecords
            print("✅ WebSocket 拦截已启动")
        }
        
        // 显示悬浮按钮
        if configuration.showFloatingButton {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showFloatingButton(at: configuration.floatingButtonPosition)
            }
        }
    }
    
    /// 停止网络调试工具
    public func stop() {
        guard isEnabled else { return }
        
        isEnabled = false
        hideFloatingButton()
        
        print("✅ ZWB_LogTap 已停止")
    }
    
    /// 显示日志页面
    public func showLogViewController() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            print("⚠️ 无法获取根视图控制器")
            return
        }
        
        let logVC = NetworkLogViewController()
        logVC.modalPresentationStyle = .fullScreen
        
        // 找到最顶层的 ViewController
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        topVC.present(logVC, animated: true)
    }
    
    /// 清空所有日志
    public func clearAllLogs() {
        NetworkInterceptorManager.shared.clearAllRequests()
        WebSocketInterceptor.interceptedMessages.removeAll()
        print("✅ 已清空所有日志")
    }
    
    /// 获取所有 HTTP 请求
    public func getAllHTTPRequests() -> [InterceptedRequest] {
        return NetworkInterceptorManager.shared.getAllRequests()
    }
    
    /// 获取所有 WebSocket 消息
    public func getAllWebSocketMessages() -> [WebSocketMessage] {
        return WebSocketInterceptor.interceptedMessages
    }
    
    /// 导出日志为 JSON
    public func exportLogsAsJSON() -> String? {
        return NetworkInterceptorManager.shared.exportToJSON()
    }
    
    // MARK: - Private Methods
    
    private func showFloatingButton(at position: FloatingButtonPosition) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        if floatingButton == nil {
            floatingButton = FloatingButton()
            floatingButton?.onTap = { [weak self] in
                self?.showLogViewController()
            }
        }
        
        floatingButton?.show(in: window)
    }
    
    private func hideFloatingButton() {
        floatingButton?.hide()
        floatingButton = nil
    }
}

// MARK: - Convenience Methods

public extension ZWBLogTap {
    
    /// 快速启动（仅在 Debug 模式下）
    static func startIfDebug() {
        #if DEBUG
        ZWBLogTap.shared.start()
        #endif
    }
    
    /// 自定义启动
    static func start(
        showFloatingButton: Bool = true,
        interceptHTTP: Bool = true,
        interceptWebSocket: Bool = true,
        maxRecords: Int = 1000
    ) {
        var config = Configuration()
        config.showFloatingButton = showFloatingButton
        config.interceptHTTP = interceptHTTP
        config.interceptWebSocket = interceptWebSocket
        config.maxRecords = maxRecords
        
        ZWBLogTap.shared.start(with: config)
    }
}
