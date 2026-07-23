//
//  ZWBLogTapOCBridge.swift
//  ZWB_LogTap
//
//  Objective-C 桥接层
//  让 OC 项目可以完整使用 ZWBLogTap 的所有功能
//

import UIKit

// MARK: - OC 环境枚举
/// 环境类型（OC 可用）
@objc public enum ZWBEnvironmentType: Int {
    /// 测试环境
    case test = 0
    /// 正式环境
    case production = 1
    /// 自定义环境（配合 customEnvironmentName 使用）
    case custom = 2
}

// MARK: - OC 悬浮按钮位置枚举
/// 悬浮按钮位置（OC 可用）
@objc public enum ZWBFloatingButtonPosition: Int {
    case topLeft = 0
    case topRight = 1
    case bottomLeft = 2
    case bottomRight = 3
}

// MARK: - OC 解密配置类
/// 响应数据 AES 解密配置（OC 可用）
@objc public class ZWBDecryptionConfig: NSObject {

    /// AES Key
    @objc public let aesKey: String

    /// AES IV
    @objc public let aesIV: String

    /// 加密字段名（默认 "ed"）
    @objc public let encryptedFieldName: String

    /// 是否启用（默认 true）
    @objc public let enabled: Bool

    @objc public init(aesKey: String,
                      aesIV: String,
                      encryptedFieldName: String = "ed",
                      enabled: Bool = true) {
        self.aesKey = aesKey
        self.aesIV = aesIV
        self.encryptedFieldName = encryptedFieldName
        self.enabled = enabled
    }

    /// 快捷构造（只传 key 和 iv，其余使用默认值）
    @objc public convenience init(aesKey: String, aesIV: String) {
        self.init(aesKey: aesKey, aesIV: aesIV, encryptedFieldName: "ed", enabled: true)
    }

    /// 转换为 Swift ResponseDecryptionConfig
    internal var swiftConfig: ZWBLogTap.ResponseDecryptionConfig {
        return ZWBLogTap.ResponseDecryptionConfig(
            aesKey: aesKey,
            aesIV: aesIV,
            encryptedFieldName: encryptedFieldName,
            enabled: enabled
        )
    }
}

// MARK: - OC 启动配置类
/// ZWBLogTap 启动配置（OC 可用）
@objc public class ZWBConfiguration: NSObject {

    /// 是否显示悬浮按钮（默认 true）
    @objc public var showFloatingButton: Bool = true

    /// 是否拦截 HTTP 请求（默认 true）
    @objc public var interceptHTTP: Bool = true

    /// 最大记录数（默认 1000）
    @objc public var maxRecords: Int = 1000

    /// 悬浮按钮位置（默认右下角）
    @objc public var floatingButtonPosition: ZWBFloatingButtonPosition = .bottomRight

    /// 默认环境（默认测试环境）
    @objc public var defaultEnvironment: ZWBEnvironmentType = .test

    /// 自定义环境名称（defaultEnvironment = .custom 时生效）
    @objc public var customEnvironmentName: String = ""

    /// 测试环境解密配置（可选）
    @objc public var testDecryptionConfig: ZWBDecryptionConfig?

    /// 正式环境解密配置（可选）
    @objc public var productionDecryptionConfig: ZWBDecryptionConfig?

    @objc public override init() {}

    /// 转换为 Swift Configuration
    internal var swiftConfiguration: ZWBLogTap.Configuration {
        var config = ZWBLogTap.Configuration()
        config.showFloatingButton = showFloatingButton
        config.interceptHTTP = interceptHTTP
        config.maxRecords = maxRecords
        config.floatingButtonPosition = floatingButtonPosition.swiftPosition
        config.defaultEnvironment = defaultEnvironment.swiftEnvironment(customName: customEnvironmentName)

        var decryptConfigs: [EnvironmentManager.Environment: ZWBLogTap.ResponseDecryptionConfig] = [:]
        if let testCfg = testDecryptionConfig {
            decryptConfigs[.test] = testCfg.swiftConfig
        }
        if let prodCfg = productionDecryptionConfig {
            decryptConfigs[.production] = prodCfg.swiftConfig
        }
        if !decryptConfigs.isEmpty {
            config.decryptionConfigs = decryptConfigs
        }

        return config
    }
}

// MARK: - OC 主入口桥接类
/// ZWBLogTap OC 桥接主入口
/// OC 项目通过此类使用所有功能
@objc public class ZWBLogTapOC: NSObject {

    // MARK: - 启动 / 停止

    /// 快速启动（仅 Debug 生效）
    @objc public static func startIfDebug() {
        ZWBLogTap.startIfDebug()
    }

    /// 使用默认配置启动
    @objc public static func start() {
        ZWBLogTap.shared.start()
    }

    /// 使用自定义配置启动
    /// - Parameter configuration: ZWBConfiguration 配置对象
    @objc public static func start(with configuration: ZWBConfiguration) {
        ZWBLogTap.shared.start(with: configuration.swiftConfiguration)
    }

    /// 停止
    @objc public static func stop() {
        ZWBLogTap.shared.stop()
    }

    /// 是否已启动
    @objc public static var isEnabled: Bool {
        return ZWBLogTap.shared.isEnabled
    }

    // MARK: - 日志页面

    /// 显示日志页面
    @objc public static func showLogViewController() {
        ZWBLogTap.shared.showLogViewController()
    }

    /// 显示性能悬浮窗
    @objc public static func showPerformanceFloatingWindow() {
        ZWBLogTap.shared.showPerformanceFloatingWindow()
    }

    /// 隐藏性能悬浮窗
    @objc public static func hidePerformanceFloatingWindow() {
        ZWBLogTap.shared.hidePerformanceFloatingWindow()
    }

    /// 切换性能悬浮窗
    @objc public static func togglePerformanceFloatingWindow() {
        ZWBLogTap.shared.togglePerformanceFloatingWindow()
    }

    /// 清空所有日志
    @objc public static func clearAllLogs() {
        ZWBLogTap.shared.clearAllLogs()
    }

    // MARK: - 环境管理

    /// 获取当前环境名称
    @objc public static var currentEnvironmentName: String {
        return EnvironmentManager.shared.currentEnvironment.name
    }

    /// 获取当前环境类型
    @objc public static var currentEnvironmentType: ZWBEnvironmentType {
        return EnvironmentManager.shared.currentEnvironment.ocEnvironmentType
    }

    /// 切换环境（在测试/正式之间切换）
    @objc public static func switchEnvironment() {
        ZWBLogTap.shared.switchEnvironment()
    }

    /// 切换到指定环境
    /// - Parameters:
    ///   - type: 环境类型
    ///   - customName: 自定义环境名称（type = .custom 时生效）
    @objc public static func switchTo(environment type: ZWBEnvironmentType, customName: String = "") {
        let env = type.swiftEnvironment(customName: customName)
        ZWBLogTap.shared.switchTo(environment: env)
    }

    /// 设置环境切换回调
    /// - Parameter callback: 切换时回调，参数为新环境名称
    @objc public static func setEnvironmentSwitchCallback(_ callback: @escaping (String) -> Void) {
        ZWBLogTap.shared.setEnvironmentSwitchCallback { env in
            callback(env.name)
        }
    }

    // MARK: - WebSocket 手动日志

    /// 记录 WebSocket 连接
    @objc public static func logWebSocketConnect(url: String) {
        ZWBLogTap.logWebSocketConnect(url: url)
    }

    /// 记录 WebSocket 发送消息（String）
    @objc public static func logWebSocketSend(url: String, message: String) {
        ZWBLogTap.logWebSocketSend(url: url, message: message)
    }

    /// 记录 WebSocket 发送消息（Data）
    @objc public static func logWebSocketSendData(url: String, data: Data) {
        ZWBLogTap.logWebSocketSend(url: url, message: data)
    }

    /// 记录 WebSocket 接收消息（String）
    @objc public static func logWebSocketReceive(url: String, message: String) {
        ZWBLogTap.logWebSocketReceive(url: url, message: message)
    }

    /// 记录 WebSocket 接收消息（Data）
    @objc public static func logWebSocketReceiveData(url: String, data: Data) {
        ZWBLogTap.logWebSocketReceive(url: url, message: data)
    }

    /// 记录 WebSocket 断开连接
    @objc public static func logWebSocketDisconnect(url: String) {
        ZWBLogTap.logWebSocketDisconnect(url: url)
    }

    /// 记录 WebSocket 断开连接（含原因）
    @objc public static func logWebSocketDisconnect(url: String, reason: String) {
        ZWBLogTap.logWebSocketDisconnect(url: url, reason: reason)
    }

    /// 记录 WebSocket 错误
    @objc public static func logWebSocketError(url: String, error: String) {
        ZWBLogTap.logWebSocketError(url: url, error: error)
    }

    // MARK: - 导出

    /// 导出日志为 JSON 字符串
    @objc public static func exportLogsAsJSON() -> String? {
        return ZWBLogTap.shared.exportLogsAsJSON()
    }
}

// MARK: - 内部类型转换扩展

private extension ZWBEnvironmentType {
    func swiftEnvironment(customName: String = "") -> EnvironmentManager.Environment {
        switch self {
        case .test:       return .test
        case .production: return .production
        case .custom:     return .custom(customName.isEmpty ? "自定义" : customName)
        }
    }
}

private extension ZWBFloatingButtonPosition {
    var swiftPosition: ZWBLogTap.FloatingButtonPosition {
        switch self {
        case .topLeft:     return .topLeft
        case .topRight:    return .topRight
        case .bottomLeft:  return .bottomLeft
        case .bottomRight: return .bottomRight
        }
    }
}

private extension EnvironmentManager.Environment {
    var ocEnvironmentType: ZWBEnvironmentType {
        switch self {
        case .test:       return .test
        case .production: return .production
        case .custom:     return .custom
        }
    }
}
