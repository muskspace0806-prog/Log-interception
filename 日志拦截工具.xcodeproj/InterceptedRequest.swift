//
//  InterceptedRequest.swift
//  日志拦截工具
//
//  拦截请求数据模型
//

import Foundation

struct InterceptedRequest: Identifiable {
    let id: String
    let url: String
    let method: String
    let headers: [String: String]
    let body: Data?
    let startTime: Date
    
    var statusCode: Int?
    var responseHeaders: [String: String]?
    var responseData: Data?
    var endTime: Date?
    var error: String?
    
    // 计算耗时
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    // 格式化耗时
    var durationString: String {
        guard let duration = duration else { return "-" }
        return String(format: "%.0fms", duration * 1000)
    }
    
    // 解析响应 JSON
    var responseJSON: Any? {
        guard let data = responseData else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }
    
    // 响应 JSON 字符串
    var responseJSONString: String? {
        guard let json = responseJSON,
              let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    // 请求 Body 字符串
    var requestBodyString: String? {
        guard let body = body else { return nil }
        
        // 尝试解析为 JSON
        if let json = try? JSONSerialization.jsonObject(with: body),
           let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        // 否则返回原始字符串
        return String(data: body, encoding: .utf8)
    }
    
    // 响应 Body 字符串
    var responseBodyString: String? {
        guard let data = responseData else { return nil }
        
        // 尝试解析为 JSON
        if let jsonString = responseJSONString {
            return jsonString
        }
        
        // 否则返回原始字符串
        return String(data: data, encoding: .utf8)
    }
    
    // 状态码颜色
    var statusCodeColor: String {
        guard let code = statusCode else { return "gray" }
        switch code {
        case 200..<300: return "green"
        case 300..<400: return "orange"
        case 400..<500: return "red"
        case 500..<600: return "purple"
        default: return "gray"
        }
    }
    
    // 请求路径（不含参数）
    var path: String {
        guard let url = URL(string: url) else { return url }
        return url.path
    }
    
    // URL 参数
    var queryParameters: [String: String] {
        guard let url = URL(string: url),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }
        
        var params: [String: String] = [:]
        for item in queryItems {
            params[item.name] = item.value ?? ""
        }
        return params
    }
}
