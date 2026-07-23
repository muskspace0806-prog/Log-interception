//
//  PerformanceMonitor.swift
//  ZWB_LogTap
//
//  Real-time performance overlay data collector.
//

import Foundation
import UIKit
import QuartzCore

public final class PerformanceMonitor {

    public static let shared = PerformanceMonitor()

    public private(set) var isEnabled = false

    private var displayLink: CADisplayLink?
    private var sampleTimer: DispatchSourceTimer?
    private var heartbeatTimer: DispatchSourceTimer?
    private var stutterTimer: DispatchSourceTimer?
    private let workQueue = DispatchQueue(label: "com.zwblogtap.performance.monitor", qos: .utility)
    private let fileQueue = DispatchQueue(label: "com.zwblogtap.performance.file", qos: .utility)

    private var frameCount = 0
    private var lastFPSUpdateTime: CFTimeInterval = 0
    private var currentFPS = 0
    private var fpsTotal = 0
    private var fpsSampleCount = 0
    private var minFPS = Int.max
    private var lastFrameTimestamp: CFTimeInterval = 0
    private var jankCount = 0
    private var lastJankDurationMS: Double = 0
    private var lastJankDroppedFrames = 0
    private var lastJankEventTimestamp: CFTimeInterval = 0
    private let jankThreshold: CFTimeInterval = 0.1
    private let maxJankDuration: CFTimeInterval = 3.0
    private let jankEventCooldown: CFTimeInterval = 0.5

    private var peakCPU: Double = 0
    private var baselineMemoryMB: Double?
    private var peakMemoryMB: Double = 0
    private var previousBatteryMonitoringEnabled = false
    private var startDate = Date()

    private var stutterCount = 0
    private var lastStutterDurationMS: Double = 0
    private var isWaitingMainThread = false
    private var didReportCurrentStall = false
    private var mainThreadPingDate = Date()
    private var mainThreadMachPort: thread_t = 0
    private let stutterThreshold: TimeInterval = 0.3

    private var latestSnapshot = PerformanceSnapshot.empty
    private var suppressUntil = Date.distantPast
    private var suppressReason = ""
    private var onSnapshotUpdate: ((PerformanceSnapshot) -> Void)?

    private var logFileURL: URL?
    private var fileHandle: FileHandle?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    private let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()

    private init() {}

    public func start(onSnapshotUpdate: ((PerformanceSnapshot) -> Void)? = nil) {
        if isEnabled {
            self.onSnapshotUpdate = onSnapshotUpdate
            onSnapshotUpdate?(latestSnapshot)
            return
        }

        isEnabled = true
        self.onSnapshotUpdate = onSnapshotUpdate
        enableBatteryMonitoringForPerformance()
        resetState()
        prepareLogFile()
        startDisplayLink()
        startSampling()
        addAppStateObservers()
        appendLogLine(makeEventLine(type: "START(开始)", detail: "performance monitor started"))
    }

    public func stop() {
        guard isEnabled else { return }

        appendLogLine(makeEventLine(type: "STOP(停止)", detail: "performance monitor stopped"))
        isEnabled = false
        displayLink?.invalidate()
        displayLink = nil
        sampleTimer?.cancel()
        sampleTimer = nil
        heartbeatTimer?.cancel()
        heartbeatTimer = nil
        stutterTimer?.cancel()
        stutterTimer = nil
        removeAppStateObservers()
        closeLogFile()
        restoreBatteryMonitoringState()
        onSnapshotUpdate = nil
    }

    public func currentSnapshot() -> PerformanceSnapshot {
        return latestSnapshot
    }

    public func currentLogText() -> String {
        return latestFirstLogText()
    }

    public func currentLogFileURL() -> URL? {
        let text = latestFirstLogText()
        guard !text.isEmpty else {
            return logFileURL
        }

        let displayURL = logDirectoryURL().appendingPathComponent("performance_latest_first.txt")
        try? FileManager.default.createDirectory(at: logDirectoryURL(), withIntermediateDirectories: true)
        try? text.write(to: displayURL, atomically: true, encoding: .utf8)
        return displayURL
    }

    public func currentLogFileURLAsync(completion: @escaping (URL?) -> Void) {
        fileQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.fileHandle?.synchronizeFile()
            let text = self.latestFirstLogText()
            let url: URL?
            if text.isEmpty {
                url = self.logFileURL
            } else {
                let displayURL = self.logDirectoryURL().appendingPathComponent("performance_latest_first.txt")
                try? FileManager.default.createDirectory(at: self.logDirectoryURL(), withIntermediateDirectories: true)
                try? text.write(to: displayURL, atomically: true, encoding: .utf8)
                url = displayURL
            }

            DispatchQueue.main.async {
                completion(url)
            }
        }
    }

    public func endInternalActivitySuppression() {
        suppressUntil = Date()
        suppressReason = ""
        resetFrameTimingBaseline()
    }

    private func latestFirstLogText() -> String {
        guard let logFileURL = logFileURL,
              let data = try? Data(contentsOf: logFileURL),
              let text = String(data: data, encoding: .utf8) else {
            return ""
        }
        return text
            .split(separator: "\n")
            .reversed()
            .joined(separator: "\n")
    }

    public func suppressInternalActivity(reason: String, duration: TimeInterval) {
        let endDate = Date().addingTimeInterval(duration)
        if endDate > suppressUntil {
            suppressUntil = endDate
            suppressReason = reason
        }
        resetFrameTimingBaseline()
    }

    public func clearLog() {
        suppressInternalActivity(reason: "ZWBLogTap clear performance log", duration: 1.0)
        fileQueue.async { [weak self] in
            guard let self = self else { return }
            self.fileHandle?.truncateFile(atOffset: 0)
            self.fileHandle?.seekToEndOfFile()
            self.appendLogLine(self.makeEventLine(type: "CLEAR(清空)", detail: "performance log cleared"))
        }
    }

    public func mark(_ text: String) {
        appendLogLine(makeEventLine(type: "MARK(打点)", detail: text))
    }

    private var isInternalActivitySuppressed: Bool {
        return Date() < suppressUntil
    }

    private func currentSuppressReason() -> String {
        return suppressReason.isEmpty ? "ZWBLogTap internal UI" : suppressReason
    }

    private func resetState() {
        frameCount = 0
        lastFPSUpdateTime = 0
        currentFPS = 0
        fpsTotal = 0
        fpsSampleCount = 0
        minFPS = Int.max
        lastFrameTimestamp = 0
        jankCount = 0
        lastJankDurationMS = 0
        lastJankDroppedFrames = 0
        lastJankEventTimestamp = 0
        peakCPU = 0
        baselineMemoryMB = nil
        peakMemoryMB = 0
        stutterCount = 0
        lastStutterDurationMS = 0
        isWaitingMainThread = false
        didReportCurrentStall = false
        mainThreadPingDate = Date()
        mainThreadMachPort = 0
        startDate = Date()
        latestSnapshot = .empty
        suppressUntil = .distantPast
        suppressReason = ""
    }

    private func startDisplayLink() {
        DispatchQueue.main.async {
            self.mainThreadMachPort = mach_thread_self()
            let link = CADisplayLink(target: self, selector: #selector(self.handleDisplayLink(_:)))
            link.add(to: .main, forMode: .common)
            self.displayLink = link
        }
    }

    @objc private func handleDisplayLink(_ link: CADisplayLink) {
        if lastFrameTimestamp > 0 {
            recordFrameJankIfNeeded(link: link)
        }
        lastFrameTimestamp = link.timestamp

        if lastFPSUpdateTime == 0 {
            lastFPSUpdateTime = link.timestamp
            return
        }

        frameCount += 1
        let delta = link.timestamp - lastFPSUpdateTime
        guard delta >= 1 else { return }

        let fps = Int(round(Double(frameCount) / delta))
        currentFPS = fps
        fpsTotal += fps
        fpsSampleCount += 1
        minFPS = min(minFPS, fps)
        frameCount = 0
        lastFPSUpdateTime = link.timestamp
    }

    private func recordFrameJankIfNeeded(link: CADisplayLink) {
        let frameDuration = link.timestamp - lastFrameTimestamp
        guard frameDuration <= maxJankDuration else {
            resetFrameTimingBaseline()
            appendLogLine(makeEventLine(
                type: "JANK_SKIP(忽略)",
                detail: String(format: "duration=%.0fms | reason=app_resume_or_display_pause", frameDuration * 1000)
            ))
            return
        }
        guard frameDuration >= jankThreshold else { return }
        guard link.timestamp - lastJankEventTimestamp >= jankEventCooldown else { return }

        if isInternalActivitySuppressed {
            lastJankEventTimestamp = link.timestamp
            appendLogLine(makeEventLine(
                type: "JANK_SKIP(忽略)",
                detail: String(format: "duration=%.0fms | reason=%@", frameDuration * 1000, currentSuppressReason())
            ))
            return
        }

        let expectedFrameDuration = link.duration > 0 ? link.duration : (1.0 / 60.0)
        let droppedFrames = max(1, Int(round(frameDuration / expectedFrameDuration)) - 1)
        jankCount += 1
        lastJankDurationMS = frameDuration * 1000
        lastJankDroppedFrames = droppedFrames
        lastJankEventTimestamp = link.timestamp

        let stack = Self.formattedCallStack(Thread.callStackSymbols)
        appendLogLine(makeEventLine(
            type: "JANK(UI卡顿)",
            detail: String(
                format: "duration=%.0fms | dropped=%d | threshold=%.0fms | mainThreadStack=%@",
                lastJankDurationMS,
                lastJankDroppedFrames,
                jankThreshold * 1000,
                stack
            )
        ))
    }


    private func addAppStateObservers() {
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.resetFrameTimingForAppStateChange),
                name: UIApplication.willResignActiveNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.resetFrameTimingForAppStateChange),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.resetFrameTimingForAppStateChange),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        }
    }

    private func removeAppStateObservers() {
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }

    @objc private func resetFrameTimingForAppStateChange() {
        resetFrameTimingBaseline()
    }

    private func resetFrameTimingBaseline() {
        lastFrameTimestamp = 0
        lastFPSUpdateTime = 0
        frameCount = 0
    }

    private func startSampling() {
        let timer = DispatchSource.makeTimerSource(queue: workQueue)
        timer.schedule(deadline: .now(), repeating: 1.0)
        timer.setEventHandler { [weak self] in
            self?.sample()
        }
        timer.resume()
        sampleTimer = timer

        let heartbeat = DispatchSource.makeTimerSource(queue: workQueue)
        heartbeat.schedule(deadline: .now() + 5.0, repeating: 5.0)
        heartbeat.setEventHandler { [weak self] in
            guard let self = self, self.isEnabled else { return }
            self.appendLogLine(self.latestSnapshot.logLine(timestamp: self.dateFormatter.string(from: Date())))
        }
        heartbeat.resume()
        heartbeatTimer = heartbeat

        let stutter = DispatchSource.makeTimerSource(queue: workQueue)
        stutter.schedule(deadline: .now(), repeating: 0.1)
        stutter.setEventHandler { [weak self] in
            self?.checkMainThreadStutter()
        }
        stutter.resume()
        stutterTimer = stutter
    }

    private func sample() {
        let cpu = currentCPUUsage()
        let memory = currentMemoryMB()
        let net = currentNetworkStats()
        let battery = currentBatteryInfo()
        let thermalStateText = currentThermalStateText()

        if cpu > peakCPU { peakCPU = cpu }
        if baselineMemoryMB == nil { baselineMemoryMB = memory }
        if memory > peakMemoryMB { peakMemoryMB = memory }

        let snapshot = PerformanceSnapshot(
            timestamp: Date(),
            fpsCurrent: currentFPS,
            fpsAverage: fpsSampleCount > 0 ? fpsTotal / fpsSampleCount : currentFPS,
            fpsMin: minFPS == Int.max ? currentFPS : minFPS,
            cpuCurrent: cpu,
            cpuPeak: peakCPU,
            memoryCurrentMB: memory,
            memoryPeakMB: peakMemoryMB,
            memoryDeltaMB: memory - (baselineMemoryMB ?? memory),
            network: net,
            jankCount: jankCount,
            lastJankDurationMS: lastJankDurationMS,
            lastJankDroppedFrames: lastJankDroppedFrames,
            stallCount: stutterCount,
            lastStallDurationMS: lastStutterDurationMS,
            batteryLevelText: battery.levelText,
            batteryStateText: battery.stateText,
            thermalStateText: thermalStateText,
            uptime: Date().timeIntervalSince(startDate)
        )

        latestSnapshot = snapshot
        DispatchQueue.main.async { [weak self] in
            self?.onSnapshotUpdate?(snapshot)
        }
    }

    private func checkMainThreadStutter() {
        guard isEnabled else { return }

        if isWaitingMainThread {
            let duration = Date().timeIntervalSince(mainThreadPingDate)
            guard duration >= stutterThreshold, !didReportCurrentStall else { return }

            didReportCurrentStall = true
            if isInternalActivitySuppressed {
                appendLogLine(makeEventLine(
                    type: "STALL_SKIP(忽略)",
                    detail: String(
                        format: "duration=%.0fms | threshold=%.0fms | reason=%@",
                        duration * 1000,
                        stutterThreshold * 1000,
                        currentSuppressReason()
                    )
                ))
                return
            }

            stutterCount += 1
            lastStutterDurationMS = duration * 1000
            let stack = captureMainThreadStackDuringStall()
            appendLogLine(makeEventLine(
                type: "STALL(主线程阻塞)",
                detail: String(
                    format: "duration=%.0fms | threshold=%.0fms | blockedMainThreadStack=%@",
                    lastStutterDurationMS,
                    stutterThreshold * 1000,
                    stack
                )
            ))
            return
        }

        isWaitingMainThread = true
        didReportCurrentStall = false
        mainThreadPingDate = Date()
        DispatchQueue.main.async { [weak self] in
            self?.isWaitingMainThread = false
            self?.didReportCurrentStall = false
        }
    }



    private func captureMainThreadStackDuringStall(maxFrames: Int = 24) -> String {
        guard mainThreadMachPort != 0 else {
            return "unavailable:no_main_thread_port"
        }

        return Self.captureThreadStack(thread: mainThreadMachPort, maxFrames: maxFrames)
    }

    private static func captureThreadStack(thread: thread_t, maxFrames: Int) -> String {
        #if arch(arm64)
        guard thread != mach_thread_self() else {
            return formattedCallStack(Thread.callStackSymbols, maxFrames: maxFrames)
        }

        guard thread_suspend(thread) == KERN_SUCCESS else {
            return "unavailable:thread_suspend_failed"
        }
        defer {
            thread_resume(thread)
        }

        var state = arm_thread_state64_t()
        var count = mach_msg_type_number_t(MemoryLayout<arm_thread_state64_t>.size / MemoryLayout<natural_t>.size)
        let stateResult = withUnsafeMutablePointer(to: &state) {
            $0.withMemoryRebound(to: natural_t.self, capacity: Int(count)) {
                thread_get_state(thread, thread_state_flavor_t(ARM_THREAD_STATE64), $0, &count)
            }
        }

        guard stateResult == KERN_SUCCESS else {
            return "unavailable:thread_get_state_failed"
        }

        var frames: [String] = []
        appendSymbol(address: UInt(state.__pc), to: &frames)
        appendSymbol(address: UInt(state.__lr), to: &frames)

        var framePointer = UInt(state.__fp)
        var previousFramePointer: UInt = 0
        while frames.count < maxFrames, framePointer > previousFramePointer {
            guard let frame = UnsafePointer<UInt>(bitPattern: framePointer) else { break }
            previousFramePointer = framePointer
            let nextFramePointer = frame.pointee
            let returnAddress = frame.advanced(by: 1).pointee
            if returnAddress == 0 { break }
            appendSymbol(address: returnAddress, to: &frames)
            framePointer = nextFramePointer
        }

        return frames.isEmpty ? "unavailable:empty_stack" : frames.joined(separator: " <- ")
        #else
        return "unavailable:unsupported_arch"
        #endif
    }

    private static func appendSymbol(address: UInt, to frames: inout [String]) {
        guard address != 0 else { return }

        var info = Dl_info()
        if let pointer = UnsafeRawPointer(bitPattern: address),
           dladdr(pointer, &info) != 0 {
            let image = info.dli_fname.map { URL(fileURLWithPath: String(cString: $0)).lastPathComponent } ?? "unknown"
            let symbol = info.dli_sname.map { String(cString: $0) } ?? "unknown"
            frames.append(String(format: "%@ 0x%llx %@", image, UInt64(address), symbol))
        } else {
            frames.append(String(format: "0x%llx", UInt64(address)))
        }
    }

    private static func formattedCallStack(_ symbols: [String], maxFrames: Int = 12) -> String {
        let hiddenFragments = [
            "Thread.callStackSymbols",
            "formattedCallStack"
        ]

        let frames = symbols
            .map { compactStackFrame($0) }
            .filter { frame in
                !hiddenFragments.contains { frame.contains($0) }
            }
            .prefix(maxFrames)

        let text = frames.joined(separator: " <- ")
        return text.isEmpty ? "unavailable" : text
    }

    private static func compactStackFrame(_ frame: String) -> String {
        let compacted = frame.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        return compacted.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func currentNetworkStats() -> PerformanceNetworkStats {
        let requests = NetworkInterceptorManager.shared.getAllRequests()
        let completed = requests.filter { $0.endTime != nil }
        let failed = requests.filter {
            if $0.error != nil { return true }
            if let code = $0.statusCode { return code >= 400 }
            return false
        }
        let totalDuration = completed.reduce(0.0) { $0 + ($1.duration ?? 0) }
        let averageDurationMS = completed.isEmpty ? 0 : (totalDuration / Double(completed.count)) * 1000
        let uploadBytes = requests.reduce(0) { total, item in
            total + (item.body?.count ?? 0) + item.headers.reduce(0) { $0 + $1.key.count + $1.value.count }
        }
        let downloadBytes = requests.reduce(0) { total, item in
            total + (item.responseData?.count ?? 0) + (item.responseHeaders ?? [:]).reduce(0) { $0 + $1.key.count + $1.value.count }
        }

        return PerformanceNetworkStats(
            requestCount: requests.count,
            failureCount: failed.count,
            averageDurationMS: averageDurationMS,
            uploadBytes: uploadBytes,
            downloadBytes: downloadBytes
        )
    }


    private func enableBatteryMonitoringForPerformance() {
        let changes = {
            self.previousBatteryMonitoringEnabled = UIDevice.current.isBatteryMonitoringEnabled
            UIDevice.current.isBatteryMonitoringEnabled = true
        }

        if Thread.isMainThread {
            changes()
        } else {
            DispatchQueue.main.sync(execute: changes)
        }
    }

    private func restoreBatteryMonitoringState() {
        let shouldKeepEnabled = previousBatteryMonitoringEnabled
        let changes = {
            UIDevice.current.isBatteryMonitoringEnabled = shouldKeepEnabled
        }

        if Thread.isMainThread {
            changes()
        } else {
            DispatchQueue.main.sync(execute: changes)
        }
    }

    private func currentBatteryInfo() -> (levelText: String, stateText: String) {
        var result = (levelText: "--", stateText: "未知")
        let readBattery = {
            let level = UIDevice.current.batteryLevel
            let levelText: String
            if level >= 0 {
                levelText = "\(Int(round(level * 100)))%"
            } else {
                levelText = "--"
            }

            let stateText: String
            switch UIDevice.current.batteryState {
            case .charging:
                stateText = "充电中"
            case .full:
                stateText = "已充满"
            case .unplugged:
                stateText = "未充电"
            case .unknown:
                stateText = "未知"
            @unknown default:
                stateText = "未知"
            }

            result = (levelText, stateText)
        }

        if Thread.isMainThread {
            readBattery()
        } else {
            DispatchQueue.main.sync(execute: readBattery)
        }

        return result
    }

    private func currentThermalStateText() -> String {
        if #available(iOS 11.0, *) {
            switch ProcessInfo.processInfo.thermalState {
            case .nominal:
                return "正常"
            case .fair:
                return "略热"
            case .serious:
                return "很热"
            case .critical:
                return "严重"
            @unknown default:
                return "未知"
            }
        }
        return "不支持"
    }

    private func currentViewControllerName() -> String {
        var result = "Unknown"
        let semaphore = DispatchSemaphore(value: 0)

        DispatchQueue.main.async {
            result = Self.topViewControllerName() ?? "Unknown"
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 0.2)
        return result
    }

    private static func topViewControllerName() -> String? {
        guard let root = appRootViewController(),
              let top = visibleViewController(from: root) else {
            return nil
        }
        return String(describing: type(of: top))
    }

    private static func appRootViewController() -> UIViewController? {
        let windows: [UIWindow]
        if #available(iOS 13.0, *) {
            windows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
        } else {
            windows = UIApplication.shared.windows
        }

        return windows
            .filter { !$0.isHidden && $0.alpha > 0 && $0.windowLevel == .normal }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
            ?? windows
                .filter { !$0.isHidden && $0.alpha > 0 && $0.windowLevel == .normal }
                .first?
                .rootViewController
    }

    private static func visibleViewController(from controller: UIViewController?) -> UIViewController? {
        guard let controller = controller else { return nil }

        if let presented = controller.presentedViewController,
           !presented.isBeingDismissed {
            return visibleViewController(from: presented)
        }

        if let navigation = controller as? UINavigationController {
            return visibleViewController(from: navigation.visibleViewController ?? navigation.topViewController)
        }

        if let tab = controller as? UITabBarController {
            return visibleViewController(from: tab.selectedViewController)
        }

        if let page = controller as? UIPageViewController,
           let current = page.viewControllers?.first {
            return visibleViewController(from: current)
        }

        for child in controller.children.reversed() {
            if child.viewIfLoaded?.window != nil {
                return visibleViewController(from: child)
            }
        }

        return controller
    }

    private func currentMemoryMB() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        return Double(info.resident_size) / 1024.0 / 1024.0
    }

    private func currentCPUUsage() -> Double {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t(0)
        let result = task_threads(mach_task_self_, &threadList, &threadCount)
        guard result == KERN_SUCCESS, let threadList = threadList else { return 0 }

        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(UInt(bitPattern: threadList)),
                vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride)
            )
        }

        var totalUsage: Double = 0
        for index in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var count = mach_msg_type_number_t(THREAD_INFO_MAX)
            let infoResult = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threadList[index], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                }
            }

            guard infoResult == KERN_SUCCESS else { continue }
            if (info.flags & TH_FLAGS_IDLE) == 0 {
                totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
            }
        }

        return totalUsage
    }

    private func prepareLogFile() {
        fileQueue.async { [weak self] in
            guard let self = self else { return }
            let directory = self.logDirectoryURL()
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            self.removeOldLogFiles(in: directory)

            let fileName = "performance_\(self.fileNameFormatter.string(from: Date())).txt"
            let fileURL = directory.appendingPathComponent(fileName)
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            self.logFileURL = fileURL
            self.fileHandle = try? FileHandle(forWritingTo: fileURL)
            self.fileHandle?.seekToEndOfFile()
        }
    }

    private func closeLogFile() {
        fileQueue.async { [weak self] in
            self?.fileHandle?.closeFile()
            self?.fileHandle = nil
        }
    }

    private func appendLogLine(_ line: String) {
        fileQueue.async { [weak self] in
            guard let self = self,
                  let data = (line + "\n").data(using: .utf8) else { return }
            self.fileHandle?.seekToEndOfFile()
            self.fileHandle?.write(data)
        }
    }

    private func makeEventLine(type: String, detail: String) -> String {
        return "\(dateFormatter.string(from: Date())) | \(type) | \(detail)"
    }

    private func logDirectoryURL() -> URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return (caches ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("ZWBLogTap", isDirectory: true)
            .appendingPathComponent("Performance", isDirectory: true)
    }

    private func removeOldLogFiles(in directory: URL) {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        let sorted = files
            .filter { $0.pathExtension == "txt" }
            .sorted {
                let left = (try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                let right = (try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                return left > right
            }

        for file in sorted.dropFirst(5) {
            try? FileManager.default.removeItem(at: file)
        }
    }
}

public struct PerformanceSnapshot {
    public let timestamp: Date
    public let fpsCurrent: Int
    public let fpsAverage: Int
    public let fpsMin: Int
    public let cpuCurrent: Double
    public let cpuPeak: Double
    public let memoryCurrentMB: Double
    public let memoryPeakMB: Double
    public let memoryDeltaMB: Double
    public let network: PerformanceNetworkStats
    public let jankCount: Int
    public let lastJankDurationMS: Double
    public let lastJankDroppedFrames: Int
    public let stallCount: Int
    public let lastStallDurationMS: Double
    public let batteryLevelText: String
    public let batteryStateText: String
    public let thermalStateText: String
    public let uptime: TimeInterval

    static let empty = PerformanceSnapshot(
        timestamp: Date(),
        fpsCurrent: 0,
        fpsAverage: 0,
        fpsMin: 0,
        cpuCurrent: 0,
        cpuPeak: 0,
        memoryCurrentMB: 0,
        memoryPeakMB: 0,
        memoryDeltaMB: 0,
        network: .empty,
        jankCount: 0,
        lastJankDurationMS: 0,
        lastJankDroppedFrames: 0,
        stallCount: 0,
        lastStallDurationMS: 0,
        batteryLevelText: "--",
        batteryStateText: "未知",
        thermalStateText: "未知",
        uptime: 0
    )

    func displayText() -> String {
        return [
            String(format: "帧率(FPS)  当前:%2d  平均:%2d  最低:%2d", fpsCurrent, fpsAverage, fpsMin),
            String(format: "CPU(App)   当前:%3.0f%%  峰值:%3.0f%%", cpuCurrent, cpuPeak),
            String(format: "内存(MEM)  当前:%4.0fMB  峰值:%4.0fMB", memoryCurrentMB, memoryPeakMB),
            String(format: "           增量:%+4.0fMB", memoryDeltaMB),
            String(format: "网络(NET)  请求:%3d  失败:%2d", network.requestCount, network.failureCount),
            String(format: "           均耗时:%4.0fms", network.averageDurationMS),
            "流量(FLOW) 上行:\(Self.formatBytes(network.uploadBytes))  下行:\(Self.formatBytes(network.downloadBytes))",
            String(format: "UI卡顿(JANK) 次数:%2d  最近:%4.0fms  掉帧:%2d", jankCount, lastJankDurationMS, lastJankDroppedFrames),
            String(format: "阻塞(STALL)  次数:%2d  最近:%4.0fms", stallCount, lastStallDurationMS),
            "电量(BAT)  \(batteryLevelText)  \(batteryStateText)",
            "热状态     \(thermalStateText)"
        ].joined(separator: "\n")
    }

    func attributedDisplayText() -> NSAttributedString {
        let result = NSMutableAttributedString()
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 10.2, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.86)
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 10.2, weight: .semibold),
            .foregroundColor: UIColor.systemYellow
        ]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1

        func appendLine(_ parts: [(String, Bool)]) {
            for part in parts {
                var attributes = part.1 ? valueAttributes : labelAttributes
                attributes[.paragraphStyle] = paragraphStyle
                result.append(NSAttributedString(string: part.0, attributes: attributes))
            }
            result.append(NSAttributedString(string: "\n", attributes: [.paragraphStyle: paragraphStyle]))
        }

        appendLine([
            ("帧率(FPS)  当前:", false), (String(format: "%2d", fpsCurrent), true),
            ("  平均:", false), (String(format: "%2d", fpsAverage), true),
            ("  最低:", false), (String(format: "%2d", fpsMin), true)
        ])
        appendLine([
            ("CPU(App)   当前:", false), (String(format: "%3.0f%%", cpuCurrent), true),
            ("  峰值:", false), (String(format: "%3.0f%%", cpuPeak), true)
        ])
        appendLine([
            ("内存(MEM)  当前:", false), (String(format: "%4.0fMB", memoryCurrentMB), true),
            ("  峰值:", false), (String(format: "%4.0fMB", memoryPeakMB), true)
        ])
        appendLine([
            ("           增量:", false), (String(format: "%+4.0fMB", memoryDeltaMB), true)
        ])
        appendLine([
            ("网络(NET)  请求:", false), (String(format: "%3d", network.requestCount), true),
            ("  失败:", false), (String(format: "%2d", network.failureCount), true)
        ])
        appendLine([
            ("           均耗时:", false), (String(format: "%4.0fms", network.averageDurationMS), true)
        ])
        appendLine([
            ("流量(FLOW) 上行:", false), (Self.formatBytes(network.uploadBytes), true),
            ("  下行:", false), (Self.formatBytes(network.downloadBytes), true)
        ])
        appendLine([
            ("UI卡顿(JANK) 次数:", false), (String(format: "%2d", jankCount), true),
            ("  最近:", false), (String(format: "%4.0fms", lastJankDurationMS), true),
            ("  掉帧:", false), (String(format: "%2d", lastJankDroppedFrames), true)
        ])
        appendLine([
            ("阻塞(STALL)  次数:", false), (String(format: "%2d", stallCount), true),
            ("  最近:", false), (String(format: "%4.0fms", lastStallDurationMS), true)
        ])
        appendLine([
            ("电量(BAT)  ", false), ("\(batteryLevelText)  \(batteryStateText)", true)
        ])
        appendLine([
            ("热状态     ", false), (thermalStateText, true)
        ])

        if result.length > 0 {
            result.deleteCharacters(in: NSRange(location: result.length - 1, length: 1))
        }
        return result
    }

    func logLine(timestamp: String) -> String {
        return "\(timestamp) | PERF(性能) | \(displayText().replacingOccurrences(of: "\n", with: " | "))"
    }

    static func formatBytes(_ bytes: Int) -> String {
        if bytes >= 1024 * 1024 {
            return String(format: "%.1fMB", Double(bytes) / 1024.0 / 1024.0)
        }
        if bytes >= 1024 {
            return String(format: "%.1fKB", Double(bytes) / 1024.0)
        }
        return "\(bytes)B"
    }
}

public struct PerformanceNetworkStats {
    public let requestCount: Int
    public let failureCount: Int
    public let averageDurationMS: Double
    public let uploadBytes: Int
    public let downloadBytes: Int

    static let empty = PerformanceNetworkStats(
        requestCount: 0,
        failureCount: 0,
        averageDurationMS: 0,
        uploadBytes: 0,
        downloadBytes: 0
    )
}
