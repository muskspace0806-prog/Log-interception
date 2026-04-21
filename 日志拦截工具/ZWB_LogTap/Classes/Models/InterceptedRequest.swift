//
//  InterceptedRequest.swift
//  日志拦截工具
//
//  拦截请求数据模型
//

import Foundation

public struct InterceptedRequest: Identifiable {
    public let id: String
    public let url: String
    public let method: String
    public let headers: [String: String]
    public let body: Data?
    public let startTime: Date
    
    public var statusCode: Int?
    public var responseHeaders: [String: String]?
    public var responseData: Data?
    public var endTime: Date?
    public var error: String?
    
    // 计算耗时
    public var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    // 格式化耗时
    public var durationString: String {
        guard let duration = duration else { return "-" }
        return String(format: "%.0fms", duration * 1000)
    }
    
    // 解析响应 JSON
    public var responseJSON: Any? {
        guard let data = responseData else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }
    
    // 响应 JSON 字符串
    public var responseJSONString: String? {
        guard let json = responseJSON else {
            return nil
        }
        
        // 使用 prettyPrinted 和 sortedKeys 选项
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    // 请求 Body 字符串
    public var requestBodyString: String? {
        guard let body = body else { return nil }
        
        // 先尝试解密（如果配置了解密）
        let decryptedData = EnvironmentManager.shared.decryptResponseData(body)
        
        // 尝试解析为 JSON
        if let json = try? JSONSerialization.jsonObject(with: decryptedData),
           let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        // 尝试返回原始字符串
        if let string = String(data: decryptedData, encoding: .utf8) {
            return string
        }
        
        // 如果解密后的数据无法转换为 UTF-8，尝试使用原始数据
        if decryptedData != body, let string = String(data: body, encoding: .utf8) {
            return string
        }
        
        return "⚠️ 无法解析为文本（可能是二进制数据）"
    }
    
    // 响应 Body 字符串
    public var responseBodyString: String? {
        guard let data = responseData else { return nil }
        
        // 先尝试解密
        let decryptedData = EnvironmentManager.shared.decryptResponseData(data)
        
        // 尝试解析为 JSON 并格式化
        if let json = try? JSONSerialization.jsonObject(with: decryptedData),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
           let string = String(data: jsonData, encoding: .utf8) {
            return string
        }
        
        // 尝试转为字符串后再解析 JSON（有些响应是 JSON 字符串套 JSON）
        if let rawString = String(data: decryptedData, encoding: .utf8) {
            // 如果字符串本身是 JSON，再格式化一次
            if let innerData = rawString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: innerData),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
               let formatted = String(data: jsonData, encoding: .utf8) {
                return formatted
            }
            return rawString
        }
        
        // 解密失败，尝试原始数据
        if decryptedData != data, let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return "⚠️ 无法解析为文本（可能是二进制数据）\n数据大小: \(decryptedData.count) 字节"
    }
    
    // 状态码颜色
    public var statusCodeColor: String {
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
    public var path: String {
        guard let url = URL(string: url) else { return url }
        return url.path
    }
    
    // URL 参数
    public var queryParameters: [String: String] {
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
    
    // URL 参数（解密后）
    public var decryptedQueryParameters: [String: String] {
        let params = queryParameters
        
        // 如果只有一个参数且是 "ed"，说明整个参数都是加密的
        if params.count == 1, let edValue = params["ed"] {
            // 尝试解密整个参数
            if let jsonString = "{\"ed\":\"\(edValue)\"}".data(using: .utf8) {
                let decryptedData = EnvironmentManager.shared.decryptResponseData(jsonString)
                
                // 尝试解析解密后的 JSON
                if let json = try? JSONSerialization.jsonObject(with: decryptedData) as? [String: Any] {
                    var decryptedParams: [String: String] = [:]
                    for (key, value) in json {
                        decryptedParams[key] = "\(value)"
                    }
                    return decryptedParams
                }
            }
        }
        
        // 否则尝试解密每个参数值
        var decryptedParams: [String: String] = [:]
        for (key, value) in params {
            if let valueData = value.data(using: .utf8) {
                let decryptedData = EnvironmentManager.shared.decryptResponseData(valueData)
                if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                    decryptedParams[key] = decryptedString
                } else {
                    decryptedParams[key] = value
                }
            } else {
                decryptedParams[key] = value
            }
        }
        
        return decryptedParams
    }
}
