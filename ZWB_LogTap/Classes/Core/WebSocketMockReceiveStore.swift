//
//  WebSocketMockReceiveStore.swift
//  ZWB_LogTap
//
//  持久化唯一的 IM 模拟接收消息
//

import Foundation

final class WebSocketMockReceiveStore {
    
    static let shared = WebSocketMockReceiveStore()
    
    private let lock = NSRecursiveLock()
    private let fileName = "zwb_mock_receive_message.json"
    private var cachedMessage: WebSocketMessage?
    
    private init() {
        cachedMessage = loadMessage()
    }
    
    var selectedMessage: WebSocketMessage? {
        lock.lock()
        defer { lock.unlock() }
        return cachedMessage
    }
    
    var selectedMessageID: String? {
        selectedMessage?.id
    }
    
    func isSelected(_ message: WebSocketMessage) -> Bool {
        selectedMessageID == message.id
    }
    
    func select(_ message: WebSocketMessage) {
        lock.lock()
        defer { lock.unlock() }
        cachedMessage = message
        saveMessage(message)
        NotificationCenter.default.post(name: .webSocketMockReceiveSelectionChanged, object: nil)
    }
    
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        cachedMessage = nil
        try? FileManager.default.removeItem(at: fileURL)
        NotificationCenter.default.post(name: .webSocketMockReceiveSelectionChanged, object: nil)
    }
    
    private var fileURL: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directoryURL = baseURL.appendingPathComponent("ZWBLogTap", isDirectory: true)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL.appendingPathComponent(fileName)
    }
    
    private func saveMessage(_ message: WebSocketMessage) {
        guard let data = try? JSONEncoder().encode(message) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
    
    private func loadMessage() -> WebSocketMessage? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(WebSocketMessage.self, from: data)
    }
}

extension Notification.Name {
    static let webSocketMockReceiveSelectionChanged = Notification.Name("webSocketMockReceiveSelectionChanged")
}
