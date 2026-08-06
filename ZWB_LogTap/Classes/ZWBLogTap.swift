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
    private var mockReceiveFloatingButton: MockReceiveFloatingButton?
    private var roomStressFloatingButton: MockReceiveFloatingButton?
    private var performanceFloatingWindow: PerformanceFloatingWindow?
    private var performanceEntryFloatingButton: PerformanceEntryFloatingButton?
    private var mockReceiveSelectionObserver: NSObjectProtocol?
    private weak var roomStressPanelController: UIViewController?
    /// 记录房间压测面板展示状态，兼容 pageSheet 手势关闭后 weak 控制器提前释放。
    private var isRoomStressPanelVisible = false
    private var roomStressToolEnabled = false
    private var roomStressContextRoomId: String?
    private var performanceToolEnabled = false
    /// 缓存启动配置里的主悬浮按钮位置，关闭压测面板后用于恢复主入口。
    private var floatingButtonPosition: FloatingButtonPosition = .bottomRight

    /// 当前显示的日志页面
    private weak var currentLogViewController: NetworkLogViewController?

    /// WebSocket 接收消息模拟回调
    public typealias WebSocketMockReceiveHandler = (WebSocketMessage) -> Void
    private var webSocketMockReceiveHandler: WebSocketMockReceiveHandler?

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
        // 解密配置每次都更新，不受 isEnabled 影响
        if !configuration.decryptionConfigs.isEmpty {
            EnvironmentManager.shared.setDecryptionConfigs(configuration.decryptionConfigs)
        }

        guard !isEnabled else {
            print("⚠️ ZWB_LogTap 已经启动，当前环境: \(EnvironmentManager.shared.currentEnvironment.name)")
            return
        }

        isEnabled = true
        floatingButtonPosition = configuration.floatingButtonPosition

        // 只在没有持久化记录时才使用 defaultEnvironment，否则恢复上次的环境
        if !EnvironmentManager.shared.hasPersisted {
            EnvironmentManager.shared.setEnvironment(configuration.defaultEnvironment)
        } else {
            print("🌍 [ZWBLogTap] 恢复持久化环境: \(EnvironmentManager.shared.currentEnvironment.name)")
        }

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
                self.updateMockReceiveFloatingButtonVisibility()
            }
        }

        mockReceiveSelectionObserver = NotificationCenter.default.addObserver(
            forName: .webSocketMockReceiveSelectionChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateMockReceiveFloatingButtonVisibility()
        }
    }

    /// 停止网络调试工具
    public func stop() {
        guard isEnabled else { return }

        isEnabled = false
        hideFloatingButton()
        hideMockReceiveFloatingButton()
        setRoomStressToolEnabled(false)
        setPerformanceMonitorEnabled(false)
        if let observer = mockReceiveSelectionObserver {
            NotificationCenter.default.removeObserver(observer)
            mockReceiveSelectionObserver = nil
        }

        print("✅ ZWB_LogTap 已停止")
    }

    /// 显示日志页面
    public func showLogViewController() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap open log view", duration: 2.0)
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
        topVC.present(logVC, animated: true) {
            if self.roomStressToolEnabled {
                self.showRoomStressFloatingButton()
            }
            if self.performanceToolEnabled {
                self.showPerformanceEntryFloatingButton()
            }
        }
    }

    /// 清空所有日志
    public func clearAllLogs() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap clear all logs", duration: 1.0)
        NetworkInterceptorManager.shared.clearAllRequests()
        WebSocketInterceptor.clearAllMessages()
        WebSocketMockReceiveStore.shared.clear()
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

    /// 性能记录是否启用
    public var isPerformanceMonitorEnabled: Bool {
        return PerformanceMonitor.shared.isEnabled
    }

    /// 房间压测工具是否启用
    public var isRoomStressToolEnabled: Bool {
        return roomStressToolEnabled
    }

    /// 外部业务手动传入的房间压测房间号，优先级高于 IM 解析
    public var currentRoomStressRoomId: String? {
        return roomStressContextRoomId
    }

    /// 更新房间压测上下文房间号，支持 String / Int / NSNumber；传 nil、空值或 0 表示清空上下文。
    public func updateRoomStressContext(roomId: Any?) {
        DispatchQueue.main.async {
            let normalizedRoomId = Self.normalizedRoomStressRoomId(roomId)
            guard normalizedRoomId != self.roomStressContextRoomId else { return }
            self.roomStressContextRoomId = normalizedRoomId
            NotificationCenter.default.post(name: .roomStressContextDidChange, object: normalizedRoomId)
        }
    }

    /// 开启/关闭房间压测入口。开启后显示独立“压测”悬浮按钮。
    public func setRoomStressToolEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.roomStressToolEnabled = enabled
            if enabled {
                self.showRoomStressFloatingButton()
                self.showRoomStressPanelIfNeeded()
            } else {
                self.dismissRoomStressPanelIfNeeded()
                self.hideRoomStressFloatingButton()
            }
        }
    }

    /// 开启/关闭性能记录。开启后显示绿色小入口，并默认展开性能面板。
    public func setPerformanceMonitorEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.performanceToolEnabled = enabled
            if enabled {
                PerformanceMonitor.shared.start()
                self.showPerformanceEntryFloatingButton()
                self.showPerformanceFloatingWindow()
            } else {
                self.hidePerformanceFloatingWindow()
                self.hidePerformanceEntryFloatingButton()
                PerformanceMonitor.shared.stop()
            }
        }
    }

    /// 显示性能悬浮窗
    public func showPerformanceFloatingWindow() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap show performance overlay", duration: 1.0)
        DispatchQueue.main.async {
            if !PerformanceMonitor.shared.isEnabled {
                PerformanceMonitor.shared.start()
                self.showPerformanceEntryFloatingButton()
            }

            if self.performanceFloatingWindow == nil {
                let window = PerformanceFloatingWindow()
                window.onClose = { [weak self] in
                    self?.hidePerformanceFloatingWindow()
                }
                window.onDetail = { [weak self] in
                    self?.showPerformanceLogViewController()
                }
                self.performanceFloatingWindow = window
            }

            self.performanceFloatingWindow?.show()
            PerformanceMonitor.shared.start { [weak self] snapshot in
                self?.performanceFloatingWindow?.update(snapshot: snapshot)
            }
        }
    }

    /// 隐藏性能悬浮窗，不停止记录
    public func hidePerformanceFloatingWindow() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap hide performance overlay", duration: 1.0)
        DispatchQueue.main.async {
            self.performanceFloatingWindow?.hide()
            self.performanceFloatingWindow = nil
            if PerformanceMonitor.shared.isEnabled {
                PerformanceMonitor.shared.start()
            }
        }
    }

    /// 切换性能面板显示状态
    public func togglePerformanceFloatingWindow() {
        if performanceFloatingWindow == nil {
            showPerformanceFloatingWindow()
        } else {
            hidePerformanceFloatingWindow()
        }
    }

    /// 查看性能记录日志
    public func showPerformanceLogViewController() {
        PerformanceMonitor.shared.suppressInternalActivity(reason: "ZWBLogTap open performance detail", duration: 2.0)
        DispatchQueue.main.async {
            guard let topVC = self.topApplicationViewController() else {
                return
            }

            if topVC is PerformanceLogViewController {
                return
            }

            topVC.present(PerformanceLogViewController(), animated: true)
        }
    }

    private func topApplicationViewController() -> UIViewController? {
        let windows: [UIWindow]
        if #available(iOS 13.0, *) {
            windows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
        } else {
            windows = UIApplication.shared.windows
        }

        let normalWindows = windows.filter { !$0.isHidden && $0.alpha > 0 && $0.windowLevel == .normal }
        let root = normalWindows.first(where: { $0.isKeyWindow })?.rootViewController
            ?? normalWindows.first?.rootViewController
        return visibleViewController(from: root)
    }

    private func visibleViewController(from controller: UIViewController?) -> UIViewController? {
        guard let controller = controller else { return nil }

        if let presented = controller.presentedViewController,
           !presented.isBeingDismissed {
            return visibleViewController(from: presented)
        }

        if let navigation = controller as? UINavigationController {
            return visibleViewController(from: navigation.visibleViewController ?? navigation.topViewController)
        }

        if let tab = controller as? UITabBarController {
            return visibleViewController(from: tab.selectedViewController)
        }

        if let page = controller as? UIPageViewController,
           let current = page.viewControllers?.first {
            return visibleViewController(from: current)
        }

        for child in controller.children.reversed() {
            if child.viewIfLoaded?.window != nil {
                return visibleViewController(from: child)
            }
        }

        return controller
    }

    /// 设置 WebSocket 模拟接收回调
    /// - Parameter handler: 业务侧真实 IM 接收处理入口
    public func setWebSocketMockReceiveHandler(_ handler: WebSocketMockReceiveHandler?) {
        webSocketMockReceiveHandler = handler
    }

    /// 注册房间压测使用的真实 WebSocket 实例
    /// - Parameter webSocket: 业务当前活跃的 SRWebSocket 实例
    public func registerRoomStressWebSocket(_ webSocket: AnyObject) {
        WebSocketInterceptor.registerActiveSocket(webSocket)
    }

    /// 注册房间压测使用的真实 WebSocket 实例和业务 delegate
    /// - Parameters:
    ///   - webSocket: 业务当前活跃的 SRWebSocket 实例
    ///   - delegate: 实现 webSocket(_:didReceiveMessage:) 的业务对象
    public func registerRoomStressWebSocket(_ webSocket: AnyObject, delegate: AnyObject) {
        WebSocketInterceptor.registerActiveSocket(webSocket, delegate: delegate)
    }

    /// 移除房间压测使用的真实 WebSocket 实例
    /// - Parameter webSocket: 已关闭或失败的 SRWebSocket 实例
    public func unregisterRoomStressWebSocket(_ webSocket: AnyObject) {
        WebSocketInterceptor.unregisterActiveSocket(webSocket)
    }

    /// 触发 WebSocket 模拟接收
    /// - Parameter message: 要重放的接收消息
    /// - Returns: 是否已配置并触发回调
    @discardableResult
    internal func triggerWebSocketMockReceive(_ message: WebSocketMessage) -> Bool {
        if WebSocketInterceptor.replayReceiveByDelegate(message) {
            return true
        }

        guard let handler = webSocketMockReceiveHandler else {
            return false
        }
        handler(message)
        return true
    }

    internal func isSelectedWebSocketMockReceive(_ message: WebSocketMessage) -> Bool {
        WebSocketMockReceiveStore.shared.isSelected(message)
    }

    @discardableResult
    internal func toggleWebSocketMockReceiveSelection(_ message: WebSocketMessage) -> Bool {
        if WebSocketMockReceiveStore.shared.isSelected(message) {
            WebSocketMockReceiveStore.shared.clear()
            return false
        }

        WebSocketMockReceiveStore.shared.select(message)
        return true
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

    /// 记录 WebSocket 接收消息，并登记真实 WebSocket 实例供房间压测 delegate 回放使用
    /// - Parameters:
    ///   - webSocket: 业务当前收到消息的 WebSocket 实例
    ///   - message: 接收的消息（String 或 Data）
    public static func logWebSocketReceive(webSocket: AnyObject, message: Any) {
        WebSocketInterceptor.registerActiveSocket(webSocket)
        let url = (webSocket.value(forKey: "url") as? URL)?.absoluteString ?? ""
        WebSocketInterceptor.logReceive(url: url, data: message)
    }

    /// 记录 WebSocket 接收消息，并显式登记业务 delegate 供房间压测回放使用
    /// - Parameters:
    ///   - webSocket: 业务当前收到消息的 WebSocket 实例
    ///   - delegate: 实现 webSocket(_:didReceiveMessage:) 的业务对象
    ///   - message: 接收的消息（String 或 Data）
    public static func logWebSocketReceive(webSocket: AnyObject, delegate: AnyObject, message: Any) {
        WebSocketInterceptor.registerActiveSocket(webSocket, delegate: delegate)
        let url = (webSocket.value(forKey: "url") as? URL)?.absoluteString ?? ""
        WebSocketInterceptor.logReceive(url: url, data: message)
    }

    /// 记录 WebSocket 接收消息，并分离展示消息和压测回放原始消息
    /// - Parameters:
    ///   - webSocket: 业务当前收到消息的 WebSocket 实例
    ///   - displayMessage: LogTap 列表展示、样本解析用消息，通常传解密后的 JSON
    ///   - replayMessage: 房间压测回放用原始 socket 消息，会传回业务 didReceiveMessage
    public static func logWebSocketReceive(webSocket: AnyObject, displayMessage: Any, replayMessage: Any) {
        WebSocketInterceptor.registerActiveSocket(webSocket)
        let url = (webSocket.value(forKey: "url") as? URL)?.absoluteString ?? ""
        WebSocketInterceptor.logReceive(url: url, data: displayMessage, replayData: replayMessage)
    }

    /// 记录 WebSocket 接收消息，显式登记业务 delegate，并分离展示消息和压测回放原始消息
    /// - Parameters:
    ///   - webSocket: 业务当前收到消息的 WebSocket 实例
    ///   - delegate: 实现 webSocket(_:didReceiveMessage:) 的业务对象
    ///   - displayMessage: LogTap 列表展示、样本解析用消息，通常传解密后的 JSON
    ///   - replayMessage: 房间压测回放用原始 socket 消息，会传回业务 didReceiveMessage
    public static func logWebSocketReceive(webSocket: AnyObject, delegate: AnyObject, displayMessage: Any, replayMessage: Any) {
        WebSocketInterceptor.registerActiveSocket(webSocket, delegate: delegate)
        let url = (webSocket.value(forKey: "url") as? URL)?.absoluteString ?? ""
        WebSocketInterceptor.logReceive(url: url, data: displayMessage, replayData: replayMessage)
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

    private func showPerformanceEntryFloatingButton() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        if performanceEntryFloatingButton == nil {
            let button = PerformanceEntryFloatingButton()
            button.onTap = { [weak self] in
                self?.togglePerformanceFloatingWindow()
            }
            performanceEntryFloatingButton = button
        }

        performanceEntryFloatingButton?.show(in: window)
    }

    private func hidePerformanceEntryFloatingButton() {
        performanceEntryFloatingButton?.hide()
        performanceEntryFloatingButton = nil
    }

    private func updateMockReceiveFloatingButtonVisibility() {
        DispatchQueue.main.async {
            guard self.isEnabled,
                  WebSocketMockReceiveStore.shared.selectedMessage != nil,
                  let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
                self.hideMockReceiveFloatingButton()
                return
            }

            if self.mockReceiveFloatingButton == nil {
                let button = MockReceiveFloatingButton()
                button.onTap = { [weak self] in
                    self?.triggerSelectedWebSocketMockReceiveFromFloatingButton()
                }
                self.mockReceiveFloatingButton = button
            }

            self.mockReceiveFloatingButton?.show(in: window)
        }
    }

    private func hideMockReceiveFloatingButton() {
        mockReceiveFloatingButton?.hide()
        mockReceiveFloatingButton = nil
    }

    private func showRoomStressFloatingButton() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        if roomStressFloatingButton == nil {
            let button = MockReceiveFloatingButton()
            button.configure(imageName: "speedometer", backgroundColor: .systemPurple)
            button.initialExtraBottomMargin = 190
            button.onTap = { [weak self] in
                self?.toggleRoomStressPanel()
            }
            roomStressFloatingButton = button
        }

        roomStressFloatingButton?.show(in: window)
    }

    private func hideRoomStressFloatingButton() {
        roomStressFloatingButton?.hide()
        roomStressFloatingButton = nil
    }

    private func toggleRoomStressPanel() {
        if roomStressPanelController != nil {
            dismissRoomStressPanelIfNeeded()
            return
        }

        showRoomStressPanelIfNeeded()
    }

    private func showRoomStressPanelIfNeeded() {
        guard !isRoomStressPanelVisible else { return }

        guard let presenter = topViewControllerForRoomStressPanel() else {
            showToastAlert(message: "无法打开房间压测面板")
            return
        }

        hideFloatingButton()
        hideRoomStressFloatingButton()
        let panel = RoomStressLogTapPanelViewController()
        panel.onClose = { [weak self] in
            self?.dismissRoomStressPanelIfNeeded()
        }
        panel.onExitTool = { [weak self] in
            self?.setRoomStressToolEnabled(false)
        }
        let navigationController = UINavigationController(rootViewController: panel)
        navigationController.modalPresentationStyle = .pageSheet
        navigationController.isModalInPresentation = false
        navigationController.presentationController?.delegate = panel
        panel.onDidDismissByGesture = { [weak self] in
            self?.roomStressPanelController = nil
            self?.isRoomStressPanelVisible = false
            self?.restoreRoomStressFloatingButtonIfNeeded()
            self?.restoreFloatingButtonIfNeeded()
        }
        roomStressPanelController = navigationController
        isRoomStressPanelVisible = true
        presenter.present(navigationController, animated: true)
    }

    private func dismissRoomStressPanelIfNeeded() {
        guard let panel = roomStressPanelController else {
            isRoomStressPanelVisible = false
            restoreFloatingButtonIfNeeded()
            return
        }
        roomStressPanelController = nil
        isRoomStressPanelVisible = false
        panel.dismiss(animated: true) {
            self.restoreRoomStressFloatingButtonIfNeeded()
            self.restoreFloatingButtonIfNeeded()
        }
    }

    private func restoreRoomStressFloatingButtonIfNeeded() {
        guard isEnabled, roomStressToolEnabled else { return }
        showRoomStressFloatingButton()
    }

    private func restoreFloatingButtonIfNeeded() {
        guard isEnabled else { return }
        showFloatingButton(at: floatingButtonPosition)
    }

    /// 隐藏当前 ZWB_LogTap 主面板，保留独立的压测悬浮入口。
    public func dismissLogViewControllerIfNeeded(animated: Bool = true) {
        guard let currentVC = currentLogViewController else { return }
        currentLogViewController = nil
        if let presenting = currentVC.presentingViewController {
            presenting.dismiss(animated: animated)
        } else {
            currentVC.dismiss(animated: animated)
        }
    }

    private func topViewControllerForRoomStressPanel() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              var topVC = window.rootViewController else {
            return nil
        }

        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }

    private func triggerSelectedWebSocketMockReceiveFromFloatingButton() {
        guard let message = WebSocketMockReceiveStore.shared.selectedMessage else {
            showToastAlert(message: "未选择 IM 模拟接收消息")
            return
        }

        guard triggerWebSocketMockReceive(message) else {
            showToastAlert(message: "未配置 IM 模拟接收处理入口")
            return
        }
    }

    private func showToastAlert(message: String) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              var topVC = window.rootViewController else {
            print("⚠️ \(message)")
            return
        }

        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        topVC.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            alert.dismiss(animated: true)
        }
    }

    /// 清除当前显示的 ViewController 引用
    internal func clearCurrentViewController() {
        currentLogViewController = nil
    }

    private static func normalizedRoomStressRoomId(_ value: Any?) -> String? {
        guard let value else { return nil }
        let text: String
        switch value {
        case let string as String:
            text = string
        case let number as NSNumber:
            text = number.stringValue
        case let int as Int:
            text = "\(int)"
        case let int64 as Int64:
            text = "\(int64)"
        case let uint as UInt:
            text = "\(uint)"
        default:
            text = String(describing: value)
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, Int(trimmed) != 0 else {
            return nil
        }
        return trimmed
    }
}

// MARK: - Convenience Methods

extension Notification.Name {
    static let roomStressContextDidChange = Notification.Name("ZWBLogTapRoomStressContextDidChange")
}

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
