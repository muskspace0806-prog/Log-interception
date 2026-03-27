//
//  WebSocketMessage.swift
//  日志拦截工具
//
//  WebSocket 消息数据模型
//

import Foundation

public enum WebSocketMessageType: String {
    case connect = "连接"
    case disconnect = "断开"
    case send = "发送"
    case receive = "接收"
    case error = "错误"
    
    public var emoji: String {
        switch self {
        case .connect: return "🔗"
        case .disconnect: return "🔌"
        case .send: return "📤"
        case .receive: return "📥"
        case .error: return "❌"
        }
    }
    
    public var color: String {
        switch self {
        case .connect: return "green"
        case .disconnect: return "gray"
        case .send: return "blue"
        case .receive: return "orange"
        case .error: return "red"
        }
    }
}

public struct WebSocketMessage: Identifiable {
    public let id: String
    public let url: String
    public let type: WebSocketMessageType
    public let dataString: String  // 改为直接存储字符串
    public let timestamp: Date
    
    // 初始化时转换 data
    public init(id: String, url: String, type: WebSocketMessageType, data: Any?, timestamp: Date) {
        self.id = id
        self.url = url
        self.type = type
        self.timestamp = timestamp
        
        // 安全地转换为字符串
        self.dataString = Self.convertDataToString(data)
    }
    
    // 静态方法：安全地转换数据为字符串 - 极简版本
    private static func convertDataToString(_ data: Any?) -> String {
        // 不使用 guard，不使用 autoreleasepool，不使用 try-catch
        if data == nil {
            return "-"
        }
        
        // 直接转换为字符串，不做任何复杂操作
        return String(describing: data!)
    }
    
    // 格式化时间
    public var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
    
    // 格式化的数据字符串（尝试 JSON 美化和解密）
    public var formattedDataString: String {
        // 先尝试解密
        if let jsonData = dataString.data(using: .utf8) {
            let decryptedData = EnvironmentManager.shared.decryptResponseData(jsonData)
            
            // 尝试格式化 JSON
            if let json = try? JSONSerialization.jsonObject(with: decryptedData),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                return prettyString
            }
            
            // 如果不是 JSON，尝试返回解密后的字符串
            if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                return decryptedString
            }
        }
        
        return dataString
    }
    
    // 解密后的数据字符串
    public var decryptedDataString: String {
        if let jsonData = dataString.data(using: .utf8) {
            let decryptedData = EnvironmentManager.shared.decryptResponseData(jsonData)
            if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                return decryptedString
            }
        }
        return dataString
    }
    
    // 数据预览（用于列表显示）
    public var dataPreview: String {
        if dataString.count > 100 {
            return String(dataString.prefix(100)) + "..."
        }
        return dataString
    }
    
    // 从消息 JSON 中提取 route 字段（支持加密消息）
    public var route: String? {
        // 先尝试原始数据
        if let data = dataString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let route = json["route"] as? String, !route.isEmpty {
            return route
        }
        // 再尝试解密后的数据
        if let data = dataString.data(using: .utf8) {
            let decrypted = EnvironmentManager.shared.decryptResponseData(data)
            if let json = try? JSONSerialization.jsonObject(with: decrypted) as? [String: Any],
               let route = json["route"] as? String, !route.isEmpty {
                return route
            }
        }
        return nil
    }
    
    // 数据大小
    public var dataSize: String {
        let size = dataString.utf8.count
        
        if size < 1024 {
            return "\(size) B"
        } else if size < 1024 * 1024 {
            return String(format: "%.1f KB", Double(size) / 1024)
        } else {
            return String(format: "%.1f MB", Double(size) / (1024 * 1024))
        }
    }
    
    // URL 路径
    public var path: String {
        guard let url = URL(string: url) else { return url }
        return url.path.isEmpty ? "/" : url.path
    }
    
    // 主机名
    public var host: String {
        guard let url = URL(string: url) else { return url }
        return url.host ?? url.absoluteString
    }
}
