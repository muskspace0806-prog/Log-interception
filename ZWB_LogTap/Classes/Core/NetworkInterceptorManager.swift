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
        URLProtocol.registerClass(NetworkInterceptor.self)
        isIntercepting = true
        print("✅ 网络拦截已启动")
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
