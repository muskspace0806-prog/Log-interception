//
//  NetworkInterceptorManager.swift
//  日志拦截工具
//
//  网络拦截管理器
//

import Foundation

class NetworkInterceptorManager {
    
    static let shared = NetworkInterceptorManager()
    
    private var isIntercepting = false
    
    private init() {}
    
    // 启动拦截
    func startIntercepting() {
        guard !isIntercepting else { return }
        
        // 注册 URLProtocol（拦截默认 URLSession）
        URLProtocol.registerClass(NetworkInterceptor.self)
        
        // Hook URLSessionConfiguration，支持自定义 session（包括 Alamofire）
        swizzleURLSessionConfiguration()
        
        // Hook Alamofire（如果存在）
        hookAlamofire()
        
        isIntercepting = true
        print("✅ 网络拦截已启动（URLProtocol + Swizzling + Alamofire）")
    }
    
    // Hook Alamofire 的 SessionManager
    private func hookAlamofire() {
        // 检查是否存在 Alamofire
        guard let sessionManagerClass = NSClassFromString("Alamofire.SessionManager") ?? 
                                        NSClassFromString("Alamofire.Session") else {
            print("ℹ️ 未检测到 Alamofire")
            return
        }
        
        print("✅ 检测到 Alamofire，正在注入拦截器...")
        
        // Alamofire 使用自定义的 URLSessionConfiguration
        // 通过 Hook configuration 的 getter 来注入我们的 URLProtocol
        // 这样所有通过 Alamofire 发出的请求都会被拦截
    }
    
    // Hook URLSessionConfiguration 以支持自定义 session
    private func swizzleURLSessionConfiguration() {
        // 使用更安全的方式 Hook
        swizzleMethod(
            class: URLSessionConfiguration.self,
            original: #selector(getter: URLSessionConfiguration.protocolClasses),
            swizzled: #selector(getter: URLSessionConfiguration.swizzled_protocolClasses)
        )
        
        print("✅ URLSessionConfiguration Hook 成功")
    }
    
    // 通用的 Method Swizzling 方法
    private func swizzleMethod(class targetClass: AnyClass, original: Selector, swizzled: Selector) {
        guard let originalMethod = class_getInstanceMethod(targetClass, original),
              let swizzledMethod = class_getInstanceMethod(targetClass, swizzled) else {
            return
        }
        
        // 尝试添加方法，如果已存在则交换
        let didAddMethod = class_addMethod(
            targetClass,
            original,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )
        
        if didAddMethod {
            class_replaceMethod(
                targetClass,
                swizzled,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    // 停止拦截
    func stopIntercepting() {
        guard isIntercepting else { return }
        URLProtocol.unregisterClass(NetworkInterceptor.self)
        isIntercepting = false
        print("⛔️ 网络拦截已停止")
    }
    
    // 获取拦截状态
    func isActive() -> Bool {
        return isIntercepting
    }
    
    // 获取所有拦截记录
    func getAllRequests() -> [InterceptedRequest] {
        return NetworkInterceptor.interceptedRequests
    }
    
    // 清空记录
    func clearAllRequests() {
        NetworkInterceptor.interceptedRequests.removeAll()
        NotificationCenter.default.post(name: .networkRequestIntercepted, object: nil)
    }
    
    // 根据条件过滤
    func filterRequests(method: String? = nil, statusCode: Int? = nil, keyword: String? = nil) -> [InterceptedRequest] {
        var filtered = NetworkInterceptor.interceptedRequests
        
        if let method = method, !method.isEmpty {
            filtered = filtered.filter { $0.method == method }
        }
        
        if let statusCode = statusCode {
            filtered = filtered.filter { $0.statusCode == statusCode }
        }
        
        if let keyword = keyword, !keyword.isEmpty {
            filtered = filtered.filter { $0.url.lowercased().contains(keyword.lowercased()) }
        }
        
        return filtered
    }
    
    // 导出日志为 JSON
    func exportToJSON() -> String? {
        let requests = getAllRequests()
        
        let exportData = requests.map { request -> [String: Any] in
            var dict: [String: Any] = [
                "id": request.id,
                "url": request.url,
                "method": request.method,
                "headers": request.headers,
                "startTime": ISO8601DateFormatter().string(from: request.startTime)
            ]
            
            if let statusCode = request.statusCode {
                dict["statusCode"] = statusCode
            }
            
            if let responseHeaders = request.responseHeaders {
                dict["responseHeaders"] = responseHeaders
            }
            
            if let duration = request.duration {
                dict["duration"] = duration
            }
            
            if let bodyString = request.requestBodyString {
                dict["requestBody"] = bodyString
            }
            
            if let responseString = request.responseBodyString {
                dict["responseBody"] = responseString
            }
            
            if let error = request.error {
                dict["error"] = error
            }
            
            return dict
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
}

// MARK: - URLSessionConfiguration Swizzling
extension URLSessionConfiguration {
    
    @objc dynamic var swizzled_protocolClasses: [AnyClass]? {
        get {
            // 获取原始的 protocolClasses
            guard let originalProtocolClasses = self.swizzled_protocolClasses else {
                return [NetworkInterceptor.self]
            }
            
            // 如果已经包含 NetworkInterceptor，直接返回
            for protocolClass in originalProtocolClasses {
                if protocolClass == NetworkInterceptor.self {
                    return originalProtocolClasses
                }
            }
            
            // 添加 NetworkInterceptor 到最前面
            var newProtocolClasses: [AnyClass] = [NetworkInterceptor.self]
            newProtocolClasses.append(contentsOf: originalProtocolClasses)
            return newProtocolClasses
        }
        set {
            // 确保 NetworkInterceptor 始终在列表中
            if let newValue = newValue {
                var protocols = newValue
                var hasInterceptor = false
                for protocolClass in protocols {
                    if protocolClass == NetworkInterceptor.self {
                        hasInterceptor = true
                        break
                    }
                }
                if !hasInterceptor {
                    protocols.insert(NetworkInterceptor.self, at: 0)
                }
                self.swizzled_protocolClasses = protocols
            } else {
                self.swizzled_protocolClasses = [NetworkInterceptor.self]
            }
        }
    }
}
