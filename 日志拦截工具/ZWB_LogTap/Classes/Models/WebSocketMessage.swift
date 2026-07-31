//
//  WebSocketMessage.swift
//  日志拦截工具
//
//  WebSocket 消息数据模型
//

import Foundation

public enum WebSocketMessageType: String, Codable {
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

public struct WebSocketMessage: Identifiable, Codable {
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

    public init(id: String, url: String, type: WebSocketMessageType, dataString: String, timestamp: Date) {
        self.id = id
        self.url = url
        self.type = type
        self.dataString = dataString
        self.timestamp = timestamp
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

    // 从消息 JSON 中提取 first/second 字段，支持字段藏在 req_data/res_data/custom 等嵌套结构内
    public var firstSecond: (first: String?, second: String?) {
        for payload in parsedPayloadsForFieldLookup {
            if let result = Self.findFirstSecond(in: payload) {
                return result
            }
        }

        for text in rawTextsForFieldLookup {
            if let result = Self.findFirstSecond(in: text) {
                return result
            }
        }

        return (nil, nil)
    }

    // first/second 在列表里的展示文案，缺失字段按 nil 展示
    public var firstSecondDisplayText: String {
        let result = firstSecond
        return "(first/second：\(result.first ?? "nil") / \(result.second ?? "nil"))"
    }

    // 礼物 IM 关键字段，压测样本列表用于快速识别样本内容
    public var giftInfoFields: [(name: String, value: String?)] {
        let fieldNames = ["giftName", "giftId", "giftNum", "giftType", "isWholeMic", "comboCount"]
        return fieldNames.map { fieldName in
            (fieldName, fieldValueForLookup(named: fieldName))
        }
    }

    // 房间号字段，压测工具用于识别跨房间切换
    public var roomStressRoomId: String? {
        if route == "enterWithOpenChatRoom",
           let roomId = enterRoomStressRoomId {
            return roomId
        }

        return ["room_id", "roomId", "roomID", "roomid", "rid"]
            .compactMap { fieldValueForLookup(named: $0) }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty && Int($0) != 0 }
    }

    // first/second/giftId/giftNum/giftType 完整时用于压测样本去重
    public var roomStressDedupKey: String? {
        let firstSecond = firstSecond
        guard let first = firstSecond.first,
              let second = firstSecond.second,
              let giftId = fieldValueForLookup(named: "giftId"),
              let giftNum = fieldValueForLookup(named: "giftNum"),
              let giftType = fieldValueForLookup(named: "giftType") else {
            return nil
        }
        return [first, second, giftId, giftNum, giftType].joined(separator: "_")
    }

    // 生成随机压测副本：只替换消息里已经存在的字段，不新增字段，避免破坏不同项目 IM 结构
    public func randomizedGiftStressMessage() -> WebSocketMessage {
        guard let payload = Self.jsonObject(from: dataString) else {
            return self
        }

        let values = RandomGiftStressValues()
        let result = Self.randomizedObject(payload, values: values)
        guard result.changed,
              let data = try? JSONSerialization.data(withJSONObject: result.object),
              let string = String(data: data, encoding: .utf8) else {
            return self
        }

        return WebSocketMessage(
            id: "\(id)-random-\(UUID().uuidString)",
            url: url,
            type: type,
            dataString: string,
            timestamp: Date()
        )
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

    // 提供原始与解密后的 JSON 对象，兼容加密消息和普通消息
    private var parsedPayloadsForFieldLookup: [Any] {
        var payloads: [Any] = []

        if let payload = Self.jsonObject(from: dataString) {
            payloads.append(payload)
        }

        let decryptedString = decryptedDataString
        if decryptedString != dataString, let payload = Self.jsonObject(from: decryptedString) {
            payloads.append(payload)
        }

        return payloads
    }

    // 提供原始与解密后的文本，兜底兼容 custom JSON 字符串被转义或 Swift 字典描述的情况
    private var rawTextsForFieldLookup: [String] {
        let decryptedString = decryptedDataString
        if decryptedString == dataString {
            return [dataString]
        }
        return [dataString, decryptedString]
    }

    // 递归查找 first/second，遇到 JSON 字符串时继续向内解析
    private static func findFirstSecond(in object: Any) -> (first: String?, second: String?)? {
        if let dictionary = object as? [String: Any] {
            let first = normalizedFieldValue(dictionary["first"])
            let second = normalizedFieldValue(dictionary["second"])
            if first != nil || second != nil {
                return (first, second)
            }

            let preferredKeys = ["custom", "data_custom", "req_data", "res_data", "data", "message", "body"]
            for key in preferredKeys {
                if let value = dictionary[key], let result = findFirstSecond(in: value) {
                    return result
                }
            }

            for value in dictionary.values {
                if let result = findFirstSecond(in: value) {
                    return result
                }
            }
        } else if let array = object as? [Any] {
            for value in array {
                if let result = findFirstSecond(in: value) {
                    return result
                }
            }
        } else if let string = object as? String, let payload = jsonObject(from: string) {
            return findFirstSecond(in: payload)
        }

        return nil
    }

    private func fieldValueForLookup(named fieldName: String) -> String? {
        for payload in parsedPayloadsForFieldLookup {
            if let value = Self.findFieldValue(named: fieldName, in: payload) {
                return value
            }
        }

        for text in rawTextsForFieldLookup {
            if let value = Self.fieldValue(named: fieldName, in: text) {
                return value
            }
        }

        return nil
    }

    // enterWithOpenChatRoom 的真实房间号固定取进房 IM 内的 roomId，兼容 res_data.data.room_info.roomId 结构。
    private var enterRoomStressRoomId: String? {
        for payload in parsedPayloadsForFieldLookup {
            if let value = Self.findEnterRoomId(in: payload) {
                return value
            }
        }

        for text in rawTextsForFieldLookup {
            if let payload = Self.jsonObject(from: text),
               let value = Self.findEnterRoomId(in: payload) {
                return value
            }
        }

        return nil
    }

    private static func findEnterRoomId(in object: Any) -> String? {
        guard let dictionary = object as? [String: Any] else {
            if let string = object as? String, let payload = jsonObject(from: string) {
                return findEnterRoomId(in: payload)
            }
            return nil
        }

        if let roomId = normalizedRoomId(from: dictionary) {
            return roomId
        }

        let preferredKeys = ["req_data", "res_data", "data", "room_info"]
        for key in preferredKeys {
            if let value = dictionary[key],
               let roomId = findEnterRoomId(in: value) {
                return roomId
            }
        }

        return nil
    }

    private static func normalizedRoomId(from dictionary: [String: Any]) -> String? {
        let directKeys = ["roomId", "room_id", "roomID", "roomid", "rid"]
        for key in directKeys {
            if let value = normalizedFieldValue(dictionary[key])?.trimmingCharacters(in: .whitespacesAndNewlines),
               !value.isEmpty,
               Int(value) != 0 {
                return value
            }
        }
        return nil
    }

    // 递归查找指定字段，兼容字段藏在 req_data/res_data/custom 等嵌套 JSON 内
    private static func findFieldValue(named fieldName: String, in object: Any) -> String? {
        if let dictionary = object as? [String: Any] {
            if let value = normalizedFieldValue(dictionary[fieldName]) {
                return value
            }

            let preferredKeys = ["custom", "data_custom", "req_data", "res_data", "data", "message", "body"]
            for key in preferredKeys {
                if let value = dictionary[key],
                   let result = findFieldValue(named: fieldName, in: value) {
                    return result
                }
            }

            for value in dictionary.values {
                if let result = findFieldValue(named: fieldName, in: value) {
                    return result
                }
            }
        } else if let array = object as? [Any] {
            for value in array {
                if let result = findFieldValue(named: fieldName, in: value) {
                    return result
                }
            }
        } else if let string = object as? String, let payload = jsonObject(from: string) {
            return findFieldValue(named: fieldName, in: payload)
        }

        return nil
    }

    private struct RandomGiftStressValues {
        let uid = Int.random(in: 1000...999999)
        let nick = "stress_\(randomToken())"
        let targetNick = "target_\(randomToken())"
        let giftName = "Gift_\(randomToken())"
        let giftNum = Int.random(in: 1...999)

        private static func randomToken() -> String {
            String(UUID().uuidString.prefix(6)).lowercased()
        }
    }

    private static func randomizedObject(_ object: Any, values: RandomGiftStressValues) -> (object: Any, changed: Bool) {
        if let dictionary = object as? [String: Any] {
            var result = dictionary
            var changed = false

            for (key, value) in dictionary {
                if let replacement = randomReplacement(forKey: key, currentValue: value, values: values) {
                    result[key] = replacement
                    changed = true
                    continue
                }

                let nested = randomizedObject(value, values: values)
                if nested.changed {
                    result[key] = nested.object
                    changed = true
                }
            }
            return (result, changed)
        }

        if let array = object as? [Any] {
            var result = array
            var changed = false
            for index in array.indices {
                let nested = randomizedObject(array[index], values: values)
                if nested.changed {
                    result[index] = nested.object
                    changed = true
                }
            }
            return (result, changed)
        }

        if let string = object as? String,
           let payload = jsonObject(from: string) {
            let nested = randomizedObject(payload, values: values)
            guard nested.changed,
                  let data = try? JSONSerialization.data(withJSONObject: nested.object),
                  let nestedString = String(data: data, encoding: .utf8) else {
                return (object, false)
            }
            return (nestedString, true)
        }

        return (object, false)
    }

    private static func randomReplacement(forKey key: String, currentValue: Any, values: RandomGiftStressValues) -> Any? {
        switch key {
        case "uid":
            return numberReplacement(values.uid, preserving: currentValue)
        case "giftNum":
            return numberReplacement(values.giftNum, preserving: currentValue)
        case "nick":
            return values.nick
        case "targetNick":
            return values.targetNick
        case "giftName":
            return values.giftName
        default:
            return nil
        }
    }

    private static func numberReplacement(_ number: Int, preserving currentValue: Any) -> Any {
        if currentValue is String {
            return "\(number)"
        }
        return number
    }

    // 兜底从原始文本中提取 first/second，兼容 "first":34、\"first\":34、first = 34 等形态
    private static func findFirstSecond(in text: String) -> (first: String?, second: String?)? {
        let first = fieldValue(named: "first", in: text)
        let second = fieldValue(named: "second", in: text)
        guard first != nil || second != nil else {
            return nil
        }
        return (first, second)
    }

    private static func fieldValue(named fieldName: String, in text: String) -> String? {
        let escapedJSONPattern = "\\\\\"\(fieldName)\\\\\"\\s*:\\s*\\\\?\"?([^\\\\\",}\\s]+)"
        let jsonPattern = "\"\(fieldName)\"\\s*:\\s*\"?([^\",}\\s]+)"
        let swiftDictionaryPattern = "\\b\(fieldName)\\s*=\\s*([^;,}\\s]+)"

        for pattern in [escapedJSONPattern, jsonPattern, swiftDictionaryPattern] {
            if let value = firstRegexMatch(pattern: pattern, in: text) {
                return value
            }
        }
        return nil
    }

    private static func firstRegexMatch(pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: nsRange),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return String(text[range]).trimmingCharacters(in: CharacterSet(charactersIn: "\\\""))
    }

    // 将 JSON 中的 Int/String/NSNumber 等字段统一成列表可显示的字符串
    private static func normalizedFieldValue(_ value: Any?) -> String? {
        switch value {
        case let number as NSNumber:
            return number.stringValue
        case let string as String:
            return string.isEmpty ? nil : string
        case let value?:
            return String(describing: value)
        case nil:
            return nil
        }
    }

    // 将字符串解析为 JSON 对象，非 JSON 字符串直接忽略
    private static func jsonObject(from string: String) -> Any? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("{") || trimmed.hasPrefix("["),
              let data = trimmed.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data)
    }
}
