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
    public let data: Any?
    public let timestamp: Date
    
    // 格式化时间
    public var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
    
    // 数据字符串
    public var dataString: String {
        guard let data = data else { return "-" }
        
        // 如果是 Data 类型
        if let dataObj = data as? Data {
            // 尝试解析为 JSON
            if let json = try? JSONSerialization.jsonObject(with: dataObj),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: jsonData, encoding: .utf8) {
                return string
            }
            // 否则返回原始字符串
            return String(data: dataObj, encoding: .utf8) ?? "二进制数据"
        }
        
        // 如果是 String 类型
        if let string = data as? String {
            // 尝试解析为 JSON
            if let jsonData = string.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                return prettyString
            }
            return string
        }
        
        return String(describing: data)
    }
    
    // 数据预览（用于列表显示）
    public var dataPreview: String {
        let fullString = dataString
        if fullString.count > 100 {
            return String(fullString.prefix(100)) + "..."
        }
        return fullString
    }
    
    // 数据大小
    public var dataSize: String {
        guard let data = data else { return "-" }
        
        var size = 0
        if let dataObj = data as? Data {
            size = dataObj.count
        } else if let string = data as? String {
            size = string.utf8.count
        }
        
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
        return url.host ?? url
    }
}
