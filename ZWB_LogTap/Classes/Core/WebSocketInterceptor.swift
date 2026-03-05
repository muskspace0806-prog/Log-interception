//
//  WebSocketInterceptor.swift
//  日志拦截工具
//
//  WebSocket 拦截器 - 用于拦截 SocketRocket 等 WebSocket 库
//

import Foundation
import Darwin

class WebSocketInterceptor {
    
    static let shared = WebSocketInterceptor()
    
    // WebSocket 消息记录 - 使用 NSLock 保护
    private static var _interceptedMessages: [WebSocketMessage] = []
    private static let messagesLock = NSRecursiveLock()
    static var maxRecords = 1000
    
    // 线程安全的读取（返回反转后的数组，最新的在前面）
    static var interceptedMessages: [WebSocketMessage] {
        messagesLock.lock()
        defer { messagesLock.unlock() }
        
        // 如果数量过多，只返回最新的部分
        if _interceptedMessages.count > maxRecords {
            let startIndex = _interceptedMessages.count - maxRecords
            return Array(_interceptedMessages[startIndex...]).reversed()
        }
        return _interceptedMessages.reversed()
    }
    
    // 线程安全的添加 - 极简版本
    private static func addMessage(_ message: WebSocketMessage) {
        messagesLock.lock()
        defer { messagesLock.unlock() }
        
        // 只添加，不删除，避免崩溃
        _interceptedMessages.append(message)
        
        // 如果数量太多（超过2倍限制），才清理一次
        if _interceptedMessages.count > maxRecords * 2 {
            // 保留最新的 maxRecords 条
            let startIndex = _interceptedMessages.count - maxRecords
            _interceptedMessages = Array(_interceptedMessages.suffix(maxRecords))
        }
    }
    
    // 清空所有消息
    static func clearAllMessages() {
        messagesLock.lock()
        defer { messagesLock.unlock() }
        
        _interceptedMessages = []
    }
    
    private init() {}
    
    // 开始拦截
    func startIntercepting() {
        print("🔍 [WebSocket] 开始初始化拦截器...")
        hookSocketRocket()
        print("✅ WebSocket 拦截已启动")
    }
    
    // Hook SocketRocket
    private func hookSocketRocket() {
        guard let socketClass = NSClassFromString("SRWebSocket") else {
            print("⚠️ 未找到 SRWebSocket 类，可能未集成 SocketRocket")
            return
        }
        
        print("⚠️ WebSocket 拦截是实验性功能，可能导致崩溃")
        print("⚠️ 如遇到问题，请使用 interceptWebSocket: false 禁用")
        print("ℹ️ 检测到 SocketRocket，正在 Hook...")
        
        // SocketRocket 0.7.1 可能使用不同的方法名
        // 尝试多个可能的方法签名
        
        // 尝试 Hook open 方法
        hookOpenMethod(socketClass)
        
        // 尝试 Hook send 方法（多个签名）
        hookSendMethods(socketClass)
        
        // 尝试 Hook close 方法
        hookCloseMethod(socketClass)
        
        // Hook delegate 方法来拦截接收的消息
        hookDelegateMethods(socketClass)
        
        print("✅ SocketRocket Hook 完成（实验性）")
    }
    
    private func hookOpenMethod(_ socketClass: AnyClass) {
        // 尝试 open - 完全空实现，不做任何操作
        if class_getInstanceMethod(socketClass, NSSelectorFromString("open")) != nil {
            hookMethod(
                targetClass: socketClass,
                originalSelector: NSSelectorFromString("open"),
                implementation: { (socket: AnyObject) in
                    // 什么都不做，直接返回
                }
            )
            print("  ✅ Hook open 成功（空实现）")
        } else {
            print("  ⚠️ 未找到 open 方法")
        }
    }
    
    private func hookSendMethods(_ socketClass: AnyClass) {
        var hookedCount = 0
        
        // 尝试 send: 方法
        if class_getInstanceMethod(socketClass, NSSelectorFromString("send:")) != nil {
            hookMethod(
                targetClass: socketClass,
                originalSelector: NSSelectorFromString("send:"),
                implementation: { (socket: AnyObject, data: Any) in
                    print("🔍 [WebSocket] send: 被调用")
                    let urlString = (socket.value(forKey: "url") as? URL)?.absoluteString ?? "unknown"
                    
                    // 立即转换为字符串
                    let dataString: String
                    if let dataObj = data as? Data {
                        dataString = String(data: dataObj, encoding: .utf8) ?? "二进制数据"
                    } else if let string = data as? String {
                        dataString = string
                    } else {
                        dataString = String(describing: data)
                    }
                    
                    print("🔍 [WebSocket] 发送数据: \(dataString.prefix(100))...")
                    WebSocketInterceptor.logSend(url: urlString, data: dataString)
                }
            )
            print("  ✅ Hook send: 成功")
            hookedCount += 1
        }
        
        // 尝试 sendString: 方法
        if class_getInstanceMethod(socketClass, NSSelectorFromString("sendString:")) != nil {
            hookMethod(
                targetClass: socketClass,
                originalSelector: NSSelectorFromString("sendString:"),
                implementation: { (socket: AnyObject, string: Any) in
                    print("🔍 [WebSocket] sendString: 被调用")
                    let urlString = (socket.value(forKey: "url") as? URL)?.absoluteString ?? "unknown"
                    WebSocketInterceptor.logSend(url: urlString, data: string)
                }
            )
            print("  ✅ Hook sendString: 成功")
            hookedCount += 1
        }
        
        // 尝试 sendData: 方法
        if class_getInstanceMethod(socketClass, NSSelectorFromString("sendData:")) != nil {
            hookMethod(
                targetClass: socketClass,
                originalSelector: NSSelectorFromString("sendData:"),
                implementation: { (socket: AnyObject, data: Any) in
                    print("🔍 [WebSocket] sendData: 被调用")
                    let urlString = (socket.value(forKey: "url") as? URL)?.absoluteString ?? "unknown"
                    WebSocketInterceptor.logSend(url: urlString, data: data)
                }
            )
            print("  ✅ Hook sendData: 成功")
            hookedCount += 1
        }
        
        if hookedCount == 0 {
            print("  ⚠️ 未找到任何 send 方法")
        }
    }
    
    private func hookCloseMethod(_ socketClass: AnyClass) {
        // 尝试 close
        if let method = class_getInstanceMethod(socketClass, NSSelectorFromString("close")) {
            hookMethod(
                targetClass: socketClass,
                originalSelector: NSSelectorFromString("close"),
                implementation: { (socket: AnyObject) in
                    let urlString = (socket.value(forKey: "url") as? URL)?.absoluteString ?? "unknown"
                    WebSocketInterceptor.logDisconnect(url: urlString, reason: nil)
                }
            )
            print("  ✅ Hook close 成功")
        }
        
        // 尝试 closeWithCode:reason:
        if let method = class_getInstanceMethod(socketClass, NSSelectorFromString("closeWithCode:reason:")) {
            // 这个方法签名更复杂，暂时跳过
            print("  ℹ️ 检测到 closeWithCode:reason: 方法")
        }
    }
    
    private func hookDelegateMethods(_ socketClass: AnyClass) {
        // Hook _handleMessage: 来拦截接收的消息
        if let method = class_getInstanceMethod(socketClass, NSSelectorFromString("_handleMessage:")) {
            print("  ℹ️ 检测到 _handleMessage: 方法（内部方法）")
        }
    }
    
    private func hookMethod(targetClass: AnyClass, originalSelector: Selector, implementation: @escaping (AnyObject) -> Void) {
        guard let originalMethod = class_getInstanceMethod(targetClass, originalSelector) else {
            return
        }
        
        let block: @convention(block) (AnyObject) -> Void = { socket in
            implementation(socket)
            
            // 调用原始实现
            typealias OriginalFunction = @convention(c) (AnyObject, Selector) -> Void
            let originalIMP = method_getImplementation(originalMethod)
            unsafeBitCast(originalIMP, to: OriginalFunction.self)(socket, originalSelector)
        }
        
        let newIMP = imp_implementationWithBlock(block as Any)
        method_setImplementation(originalMethod, newIMP)
    }
    
    private func hookMethod(targetClass: AnyClass, originalSelector: Selector, implementation: @escaping (AnyObject, Any) -> Void) {
        guard let originalMethod = class_getInstanceMethod(targetClass, originalSelector) else {
            return
        }
        
        let block: @convention(block) (AnyObject, Any) -> Void = { socket, data in
            implementation(socket, data)
            
            // 调用原始实现
            typealias OriginalFunction = @convention(c) (AnyObject, Selector, Any) -> Void
            let originalIMP = method_getImplementation(originalMethod)
            unsafeBitCast(originalIMP, to: OriginalFunction.self)(socket, originalSelector, data)
        }
        
        let newIMP = imp_implementationWithBlock(block as Any)
        method_setImplementation(originalMethod, newIMP)
    }
    
    // 安全的 ID 生成器 - 使用最简单的全局变量，不用任何锁
    private static var messageCounter: Int = 0
    
    private static func generateSafeID() -> String {
        messageCounter += 1
        return "ws-\(messageCounter)"
    }
    
    // 记录连接 - 极简版本，移除所有可能崩溃的操作
    static func logConnection(url: String) {
        let id = generateSafeID()
        let message = WebSocketMessage(
            id: id,
            url: url,
            type: .connect,
            data: nil,
            timestamp: Date()
        )
        addMessage(message)
    }
    
    // 记录发送消息
    static func logSend(url: String, data: Any) {
        let id = generateSafeID()
        // 直接传递 data，不做任何转换
        let message = WebSocketMessage(
            id: id,
            url: url,
            type: .send,
            data: data,
            timestamp: Date()
        )
        addMessage(message)
    }
    
    // 记录接收消息
    static func logReceive(url: String, data: Any) {
        let id = generateSafeID()
        let message = WebSocketMessage(
            id: id,
            url: url,
            type: .receive,
            data: data,
            timestamp: Date()
        )
        addMessage(message)
    }
    
    // 记录断开连接
    static func logDisconnect(url: String, reason: String?) {
        let id = generateSafeID()
        let message = WebSocketMessage(
            id: id,
            url: url,
            type: .disconnect,
            data: reason as Any?,
            timestamp: Date()
        )
        addMessage(message)
    }
    
    // 记录错误
    static func logError(url: String, error: String) {
        let id = generateSafeID()
        let message = WebSocketMessage(
            id: id,
            url: url,
            type: .error,
            data: error,
            timestamp: Date()
        )
        addMessage(message)
    }
}

// MARK: - Notification
extension Notification.Name {
    static let webSocketMessageIntercepted = Notification.Name("webSocketMessageIntercepted")
}
