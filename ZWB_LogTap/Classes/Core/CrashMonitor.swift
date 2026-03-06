//
//  CrashMonitor.swift
//  ZWB_LogTap
//
//  Crash 监控 - 捕获和记录应用崩溃
//

import Foundation

public class CrashMonitor {
    
    public static let shared = CrashMonitor()
    
    public private(set) var isEnabled: Bool = false
    private var crashLogs: [CrashLog] = []
    private let crashLogFile = "zwb_crash_logs.json"
    
    // Crash 日志模型
    public struct CrashLog: Codable {
        public let id: String
        public let timestamp: Date
        public let reason: String
        public let stackTrace: String
        public let appVersion: String
        public let osVersion: String
        
        public init(reason: String, stackTrace: String) {
            self.id = UUID().uuidString
            self.timestamp = Date()
            self.reason = reason
            self.stackTrace = stackTrace
            self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            self.osVersion = UIDevice.current.systemVersion
        }
    }
    
    private init() {
        loadCrashLogs()
    }
    
    // MARK: - Public Methods
    
    /// 启用 Crash 监控
    public func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        setupExceptionHandler()
        setupSignalHandler()
        print("💥 [CrashMonitor] 已启用")
    }
    
    /// 禁用 Crash 监控
    public func disable() {
        guard isEnabled else { return }
        isEnabled = false
        NSSetUncaughtExceptionHandler(nil)
        print("💥 [CrashMonitor] 已禁用")
    }
    
    /// 获取所有 Crash 日志
    public func getAllCrashLogs() -> [CrashLog] {
        return crashLogs.sorted { $0.timestamp > $1.timestamp }
    }
    
    /// 清空所有 Crash 日志
    public func clearAllLogs() {
        crashLogs.removeAll()
        saveCrashLogs()
        print("💥 [CrashMonitor] 已清空所有日志")
    }
    
    // MARK: - Private Methods
    
    private func setupExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            let reason = exception.reason ?? "Unknown"
            let stackTrace = exception.callStackSymbols.joined(separator: "\n")
            
            // 立即记录崩溃
            CrashMonitor.shared.recordCrash(reason: "Exception: \(reason)", stackTrace: stackTrace)
            
            // 给一点时间让文件系统完成写入
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    private func setupSignalHandler() {
        // 保存原始的 signal handlers
        let signals = [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE]
        
        for sig in signals {
            signal(sig) { signal in
                // 获取调用栈
                let stackTrace = Thread.callStackSymbols.joined(separator: "\n")
                let signalName = CrashMonitor.shared.getSignalName(signal)
                
                // 立即记录崩溃
                CrashMonitor.shared.recordCrash(reason: signalName, stackTrace: stackTrace)
                
                // 恢复默认处理器并重新触发信号
                Darwin.signal(signal, SIG_DFL)
                raise(signal)
            }
        }
    }
    
    private func getSignalName(_ signal: Int32) -> String {
        switch signal {
        case SIGABRT: return "SIGABRT (Abort)"
        case SIGILL: return "SIGILL (Illegal Instruction)"
        case SIGSEGV: return "SIGSEGV (Segmentation Fault)"
        case SIGFPE: return "SIGFPE (Floating Point Exception)"
        case SIGBUS: return "SIGBUS (Bus Error)"
        case SIGPIPE: return "SIGPIPE (Broken Pipe)"
        default: return "Signal \(signal)"
        }
    }
    
    private func recordCrash(reason: String, stackTrace: String) {
        let crashLog = CrashLog(reason: reason, stackTrace: stackTrace)
        crashLogs.append(crashLog)
        
        // 立即同步保存，不使用异步
        saveCrashLogsSync()
        
        print("💥 [CrashMonitor] 记录崩溃: \(reason)")
        
        // 强制刷新到磁盘
        sync()
    }
    
    private func saveCrashLogsSync() {
        guard let data = try? JSONEncoder().encode(crashLogs),
              let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentsPath.appendingPathComponent(crashLogFile)
        
        // 使用同步写入，确保数据立即保存
        try? data.write(to: fileURL, options: .atomic)
    }
    
    private func saveCrashLogs() {
        guard let data = try? JSONEncoder().encode(crashLogs),
              let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentsPath.appendingPathComponent(crashLogFile)
        try? data.write(to: fileURL)
    }
    
    private func loadCrashLogs() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentsPath.appendingPathComponent(crashLogFile)
        guard let data = try? Data(contentsOf: fileURL),
              let logs = try? JSONDecoder().decode([CrashLog].self, from: data) else {
            return
        }
        crashLogs = logs
    }
}
