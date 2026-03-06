//
//  MemoryMonitor.swift
//  ZWB_LogTap
//
//  内存监控 - 实时监控应用内存使用情况
//

import Foundation
import UIKit

public class MemoryMonitor {
    
    public static let shared = MemoryMonitor()
    
    public private(set) var isEnabled: Bool = false
    private var timer: Timer?
    private var memoryHistory: [MemorySnapshot] = []
    private let maxHistoryCount = 100
    
    // 悬浮窗相关
    private var floatingWindow: FloatingInfoWindow?
    private var floatingUpdateTimer: Timer?
    
    // 内存快照
    public struct MemorySnapshot {
        public let timestamp: Date
        public let usedMemoryMB: Double
        public let totalMemoryMB: Double
        
        public var usagePercentage: Double {
            return (usedMemoryMB / totalMemoryMB) * 100
        }
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 启用内存监控
    public func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        startMonitoring()
        print("💾 [MemoryMonitor] 已启用")
    }
    
    /// 禁用内存监控
    public func disable() {
        guard isEnabled else { return }
        isEnabled = false
        stopMonitoring()
        hideFloatingWindow()
        print("💾 [MemoryMonitor] 已禁用")
    }
    
    /// 显示悬浮窗
    public func showFloatingWindow() {
        guard floatingWindow == nil else {
            print("⚠️ 悬浮窗已存在")
            return
        }
        
        floatingWindow = FloatingInfoWindow()
        floatingWindow?.onClose = { [weak self] in
            print("💾 关闭内存监控悬浮窗")
            self?.disable()
        }
        floatingWindow?.show(in: UIView())  // 传入空 view，实际不使用
        
        print("💾 显示内存监控悬浮窗")
        
        // 立即更新一次
        updateFloatingWindow()
        
        // 启动定时更新
        floatingUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateFloatingWindow()
        }
        
        // 将定时器添加到 RunLoop
        RunLoop.main.add(floatingUpdateTimer!, forMode: .common)
        print("💾 定时器已启动")
    }
    
    /// 隐藏悬浮窗
    public func hideFloatingWindow() {
        print("💾 隐藏内存监控悬浮窗")
        floatingUpdateTimer?.invalidate()
        floatingUpdateTimer = nil
        floatingWindow?.hide()
        floatingWindow = nil
    }
    
    private func updateFloatingWindow() {
        guard let snapshot = getCurrentMemoryUsage() else {
            return
        }
        
        // 创建富文本
        let attributedString = NSMutableAttributedString()
        
        // 标题
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.white
        ]
        attributedString.append(NSAttributedString(string: "💾 内存监控\n", attributes: titleAttributes))
        
        // 使用内存（红底白字）
        let usedMemoryText = String(format: "%.1f MB", snapshot.usedMemoryMB)
        let usedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .bold),
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.red
        ]
        attributedString.append(NSAttributedString(string: "使用: ", attributes: titleAttributes))
        attributedString.append(NSAttributedString(string: usedMemoryText, attributes: usedAttributes))
        
        // 其他信息
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.white
        ]
        let otherText = String(format: "\n占用: %.1f%%", snapshot.usagePercentage)
        attributedString.append(NSAttributedString(string: otherText, attributes: normalAttributes))
        
        floatingWindow?.updateContentWithAttributedString(attributedString)
    }
    
    /// 获取当前内存使用情况
    public func getCurrentMemoryUsage() -> MemorySnapshot? {
        return getMemoryUsage()
    }
    
    /// 获取内存历史记录
    public func getMemoryHistory() -> [MemorySnapshot] {
        return memoryHistory
    }
    
    /// 清空历史记录
    public func clearHistory() {
        memoryHistory.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordMemorySnapshot()
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func recordMemorySnapshot() {
        guard let snapshot = getMemoryUsage() else { return }
        
        memoryHistory.append(snapshot)
        
        // 限制历史记录数量
        if memoryHistory.count > maxHistoryCount {
            memoryHistory.removeFirst()
        }
    }
    
    private func getMemoryUsage() -> MemorySnapshot? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else { return nil }
        
        let usedMemoryMB = Double(info.resident_size) / 1024.0 / 1024.0
        let totalMemoryMB = Double(ProcessInfo.processInfo.physicalMemory) / 1024.0 / 1024.0
        
        return MemorySnapshot(timestamp: Date(), usedMemoryMB: usedMemoryMB, totalMemoryMB: totalMemoryMB)
    }
}
