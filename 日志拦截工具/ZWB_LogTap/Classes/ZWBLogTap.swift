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
    
    /// 当前显示的日志页面
    private weak var currentLogViewController: NetworkLogViewController?
    
    /// 配置选项
    public struct Configuration {
        /// 是否显示悬浮按钮
        public var showFloatingButton: Bool = true
        
        /// 是否拦截 HTTP 请求
        public var interceptHTTP: Bool = true
        
        /// ⚠️ WebSocket 拦截功能已禁用（技术限制，无法实现）
        /// 由于 Method Swizzling 在 Swift 环境下的严重不稳定性，此功能已永久禁用
        /// 建议使用 Charles/Proxyman 等专业工具调试 WebSocket
        @available(*, deprecated, message: "WebSocket 拦截功能不可用，请使用专业工具")
        public var interceptWebSocket: Bool = false
        
        /// 最大记录数
        public var maxRecords: Int = 1000
        
        /// 悬浮按钮初始位置
        public var floatingButtonPosition: FloatingButtonPosition = .bottomRight
        
        /// 默认环境（测试/正式）
        public var defaultEnvironment: EnvironmentManager.Environment = .test
        
        /// 响应数据解密配置（按环境配置）
        public var decryptionConfigs: [EnvironmentManager.Environment: ResponseDecryptionConfig] = [:]
        
        public init() {}
    }
    
    /// 响应数据解密配置
    public struct ResponseDecryptionConfig {
        /// AES 解密 Key
        public let aesKey: String
        
        /// AES 解密 IV
        public let aesIV: String
        
        /// 加密数据的 JSON 字段名（默认为 "ed"）
        public let encryptedFieldName: String
        
        /// 是否启用解密（默认启用）
        public let enabled: Bool
        
        public init(aesKey: String, aesIV: String, encryptedFieldName: String = "ed", enabled: Bool = true) {
            self.aesKey = aesKey
            self.aesIV = aesIV
            self.encryptedFieldName = encryptedFieldName
            self.enabled = enabled
        }
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
        
        // 设置默认环境
        EnvironmentManager.shared.setEnvironment(configuration.defaultEnvironment)
        
        // 设置解密配置（支持多环境）
        if !configuration.decryptionConfigs.isEmpty {
            EnvironmentManager.shared.setDecryptionConfigs(configuration.decryptionConfigs)
        }
        
        // 启动 HTTP 拦截
        if configuration.interceptHTTP {
            NetworkInterceptorManager.shared.startIntercepting()
            NetworkInterceptor.maxRecords = configuration.maxRecords
            print("✅ HTTP 拦截已启动")
        }
        
        // 启动 WebSocket 拦截（已禁用）
        if configuration.interceptWebSocket {
            print("⚠️ WebSocket 拦截功能已禁用（技术限制）")
            print("⚠️ 建议使用 Charles/Proxyman 等专业工具调试 WebSocket")
            // WebSocketInterceptor.shared.startIntercepting()
            // WebSocketInterceptor.maxRecords = configuration.maxRecords
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
        // 如果已经有显示的页面，关闭所有页面
        if let currentVC = currentLogViewController {
            // 找到 NetworkLogViewController 的 presentingViewController
            // 从它那里 dismiss，会关闭所有 presented 的页面
            if let presenting = currentVC.presentingViewController {
                presenting.dismiss(animated: true) {
                    self.currentLogViewController = nil
                }
            } else {
                currentVC.dismiss(animated: true) {
                    self.currentLogViewController = nil
                }
            }
            return
        }
        
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
        
        currentLogViewController = logVC
        topVC.present(logVC, animated: true)
    }
    
    /// 清空所有日志
    public func clearAllLogs() {
        NetworkInterceptorManager.shared.clearAllRequests()
        WebSocketInterceptor.clearAllMessages()
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
    
    // MARK: - 手动 WebSocket 日志记录 API
    
    /// 记录 WebSocket 连接
    /// - Parameter url: WebSocket URL
    public static func logWebSocketConnect(url: String) {
        WebSocketInterceptor.logConnection(url: url)
    }
    
    /// 记录 WebSocket 发送消息
    /// - Parameters:
    ///   - url: WebSocket URL
    ///   - message: 发送的消息（String 或 Data）
    public static func logWebSocketSend(url: String, message: Any) {
        WebSocketInterceptor.logSend(url: url, data: message)
    }
    
    /// 记录 WebSocket 接收消息
    /// - Parameters:
    ///   - url: WebSocket URL
    ///   - message: 接收的消息（String 或 Data）
    public static func logWebSocketReceive(url: String, message: Any) {
        WebSocketInterceptor.logReceive(url: url, data: message)
    }
    
    /// 记录 WebSocket 断开连接
    /// - Parameters:
    ///   - url: WebSocket URL
    ///   - reason: 断开原因（可选）
    public static func logWebSocketDisconnect(url: String, reason: String? = nil) {
        WebSocketInterceptor.logDisconnect(url: url, reason: reason)
    }
    
    /// 记录 WebSocket 错误
    /// - Parameters:
    ///   - url: WebSocket URL
    ///   - error: 错误信息
    public static func logWebSocketError(url: String, error: String) {
        WebSocketInterceptor.logError(url: url, error: error)
    }
    
    /// 导出日志为 JSON
    public func exportLogsAsJSON() -> String? {
        return NetworkInterceptorManager.shared.exportToJSON()
    }
    
    // MARK: - Environment Management
    
    /// 设置环境切换回调
    /// - Parameter callback: 环境切换时的回调闭包，参数为新环境
    public func setEnvironmentSwitchCallback(_ callback: @escaping (EnvironmentManager.Environment) -> Void) {
        EnvironmentManager.shared.onEnvironmentSwitch = callback
    }
    
    /// 获取当前环境
    public var currentEnvironment: EnvironmentManager.Environment {
        return EnvironmentManager.shared.currentEnvironment
    }
    
    /// 切换环境
    public func switchEnvironment() {
        EnvironmentManager.shared.switchEnvironment()
        // 更新悬浮按钮颜色
        floatingButton?.updateEnvironmentColor()
    }
    
    /// 切换到指定环境
    /// - Parameter environment: 目标环境
    public func switchTo(environment: EnvironmentManager.Environment) {
        EnvironmentManager.shared.switchTo(environment)
        // 更新悬浮按钮颜色
        floatingButton?.updateEnvironmentColor()
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
    
    /// 清除当前显示的 ViewController 引用
    internal func clearCurrentViewController() {
        currentLogViewController = nil
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
        interceptWebSocket: Bool = false,  // 默认关闭 WebSocket
        maxRecords: Int = 1000,
        defaultEnvironment: EnvironmentManager.Environment = .test,
        decryptionConfigs: [EnvironmentManager.Environment: ResponseDecryptionConfig] = [:]
    ) {
        var config = Configuration()
        config.showFloatingButton = showFloatingButton
        config.interceptHTTP = interceptHTTP
        config.interceptWebSocket = interceptWebSocket
        config.maxRecords = maxRecords
        config.defaultEnvironment = defaultEnvironment
        config.decryptionConfigs = decryptionConfigs
        
        ZWBLogTap.shared.start(with: config)
    }
}
