//
//  WebSocketInterceptor.swift
//  日志拦截工具
//
//  WebSocket 拦截器 - 用于拦截 SocketRocket 等 WebSocket 库
//

import Foundation

class WebSocketInterceptor {
    
    static let shared = WebSocketInterceptor()
    
    // WebSocket 消息记录
    static var interceptedMessages: [WebSocketMessage] = []
    static var maxRecords = 1000
    
    private init() {}
    
    // 开始拦截
    func startIntercepting() {
        hookSocketRocket()
        print("✅ WebSocket 拦截已启动")
    }
    
    // Hook SocketRocket
    private func hookSocketRocket() {
        guard let socketClass = NSClassFromString("SRWebSocket") else {
            print("⚠️ 未找到 SRWebSocket 类，可能未集成 SocketRocket")
            return
        }
        
        // Hook open 方法
        hookMethod(
            targetClass: socketClass,
            originalSelector: NSSelectorFromString("open"),
            implementation: { (socket: AnyObject) in
                if let url = socket.value(forKey: "url") as? URL {
                    WebSocketInterceptor.logConnection(url: url.absoluteString)
                }
            }
        )
        
        // Hook send 方法
        hookMethod(
            targetClass: socketClass,
            originalSelector: NSSelectorFromString("send:"),
            implementation: { (socket: AnyObject, data: Any) in
                if let url = socket.value(forKey: "url") as? URL {
                    WebSocketInterceptor.logSend(url: url.absoluteString, data: data)
                }
            }
        )
        
        // Hook close 方法
        hookMethod(
            targetClass: socketClass,
            originalSelector: NSSelectorFromString("close"),
            implementation: { (socket: AnyObject) in
                if let url = socket.value(forKey: "url") as? URL {
                    WebSocketInterceptor.logDisconnect(url: url.absoluteString, reason: nil)
                }
            }
        )
        
        print("✅ SocketRocket Hook 成功")
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
    
    // 记录连接
    static func logConnection(url: String) {
        let message = WebSocketMessage(
            id: UUID().uuidString,
            url: url,
            type: .connect,
            data: nil,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            interceptedMessages.insert(message, at: 0)
            if interceptedMessages.count > maxRecords {
                interceptedMessages.removeLast()
            }
            NotificationCenter.default.post(name: .webSocketMessageIntercepted, object: nil)
        }
    }
    
    // 记录发送消息
    static func logSend(url: String, data: Any) {
        let message = WebSocketMessage(
            id: UUID().uuidString,
            url: url,
            type: .send,
            data: data,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            interceptedMessages.insert(message, at: 0)
            if interceptedMessages.count > maxRecords {
                interceptedMessages.removeLast()
            }
            NotificationCenter.default.post(name: .webSocketMessageIntercepted, object: nil)
        }
    }
    
    // 记录接收消息
    static func logReceive(url: String, data: Any) {
        let message = WebSocketMessage(
            id: UUID().uuidString,
            url: url,
            type: .receive,
            data: data,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            interceptedMessages.insert(message, at: 0)
            if interceptedMessages.count > maxRecords {
                interceptedMessages.removeLast()
            }
            NotificationCenter.default.post(name: .webSocketMessageIntercepted, object: nil)
        }
    }
    
    // 记录断开连接
    static func logDisconnect(url: String, reason: String?) {
        let message = WebSocketMessage(
            id: UUID().uuidString,
            url: url,
            type: .disconnect,
            data: reason,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            interceptedMessages.insert(message, at: 0)
            if interceptedMessages.count > maxRecords {
                interceptedMessages.removeLast()
            }
            NotificationCenter.default.post(name: .webSocketMessageIntercepted, object: nil)
        }
    }
    
    // 记录错误
    static func logError(url: String, error: String) {
        let message = WebSocketMessage(
            id: UUID().uuidString,
            url: url,
            type: .error,
            data: error,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            interceptedMessages.insert(message, at: 0)
            if interceptedMessages.count > maxRecords {
                interceptedMessages.removeLast()
            }
            NotificationCenter.default.post(name: .webSocketMessageIntercepted, object: nil)
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    static let webSocketMessageIntercepted = Notification.Name("webSocketMessageIntercepted")
}
