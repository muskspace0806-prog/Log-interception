//
//  RuntimeHooker.swift
//  日志拦截工具
//
//  Runtime Hook 实现 - 用于拦截更底层的网络调用
//

import Foundation

class RuntimeHooker {
    
    // Hook URLSession 的 dataTask 方法
    static func hookURLSession() {
        // Hook dataTask(with:completionHandler:)
        let originalSelector = #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let swizzledSelector = #selector(URLSession.swizzled_dataTask(with:completionHandler:))
        
        guard let originalMethod = class_getInstanceMethod(URLSession.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(URLSession.self, swizzledSelector) else {
            print("⚠️ 无法 Hook URLSession.dataTask")
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        print("✅ URLSession.dataTask Hook 成功")
    }
    
    // Hook NSURLConnection（兼容旧代码）
    static func hookNSURLConnection() {
        guard let connectionClass = NSClassFromString("NSURLConnection") else {
            print("⚠️ NSURLConnection 不可用")
            return
        }
        
        // Hook sendSynchronousRequest
        let originalSelector = NSSelectorFromString("sendSynchronousRequest:returningResponse:error:")
        let swizzledSelector = NSSelectorFromString("swizzled_sendSynchronousRequest:returningResponse:error:")
        
        if let originalMethod = class_getClassMethod(connectionClass, originalSelector),
           let swizzledMethod = class_getClassMethod(connectionClass, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
            print("✅ NSURLConnection Hook 成功")
        }
    }
}

// MARK: - URLSession Swizzling
extension URLSession {
    
    @objc func swizzled_dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        print("🔍 [Runtime Hook] 拦截到请求: \(request.url?.absoluteString ?? "")")
        
        // 包装 completion handler 来拦截响应
        let wrappedHandler: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 [Runtime Hook] 响应状态码: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("❌ [Runtime Hook] 请求错误: \(error.localizedDescription)")
            }
            completionHandler(data, response, error)
        }
        
        // 调用原始方法（注意：这里会递归调用 swizzled 方法，因为方法已经交换）
        return self.swizzled_dataTask(with: request, completionHandler: wrappedHandler)
    }
}
